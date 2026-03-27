// cargo imports
use clap::Parser;
use rfd::FileDialog;
use std::{
    env,
    error::Error,
    fs::{self, Permissions},
    io::{BufRead, BufReader, Write},
    os::unix::{
        fs::PermissionsExt,
        net::{UnixListener, UnixStream},
    },
    sync::{
        Arc,
        atomic::{AtomicBool, Ordering},
    },
    thread,
};

// local imports
use quickcli::{
    Commands, DesktopEnvironment, Request,
    modules::{compositor, hardware, rules, shell, wallpaper, weather},
};

#[derive(Parser)]
#[command(name = "quickcli")]
#[command(about = "CLI client for system stats daemon and more for Dfltplyr and you :D")]
struct Cli {
    #[command(subcommand)]
    command: Option<Commands>,
}

fn main() -> Result<(), Box<dyn Error>> {
    let args = Cli::parse();

    match args.command {
        Some(cmd) => handle_command(cmd)?,
        None => run_daemon()?,
    }

    Ok(())
}

fn handle_command(command: Commands) -> Result<(), Box<dyn Error>> {
    if let Commands::Launch { target } = &command {
        return Ok(shell::shell_query(target));
    }
    let runtime_dir = env::var("XDG_RUNTIME_DIR").expect("XDG_RUNTIME_DIR is not set");
    let socket_path = format!("{}/quickcli.sock", runtime_dir);

    let mut stream = UnixStream::connect(&socket_path)?;
    let request = command.to_request_string();

    writeln!(stream, "{}", request)?;

    let running = Arc::new(AtomicBool::new(true));
    let running_clone = running.clone();

    ctrlc::set_handler(move || {
        running_clone.store(false, Ordering::SeqCst);
    })
    .expect("Error setting Ctrl-C handler");

    let mut reader = BufReader::new(&mut stream);
    while running.load(Ordering::SeqCst) {
        let mut response = String::new();
        match reader.read_line(&mut response) {
            Ok(0) => break,
            Ok(_) => {
                print!("{}", response);
            }
            Err(ref e) if e.kind() == std::io::ErrorKind::WouldBlock => {
                thread::sleep(std::time::Duration::from_millis(50));
            }
            Err(_) => break,
        }
    }
    Ok(())
}

fn run_daemon() -> Result<(), Box<dyn Error>> {
    let runtime_dir = env::var("XDG_RUNTIME_DIR").expect("XDG_RUNTIME_DIR is not set");
    let socket_path = format!("{}/quickcli.sock", runtime_dir);

    if let Err(e) = fs::remove_file(&socket_path) {
        if e.kind() != std::io::ErrorKind::NotFound {
            return Err(e.into());
        }
    }

    let listener = UnixListener::bind(&socket_path)?;
    fs::set_permissions(&socket_path, Permissions::from_mode(0o666))?;
    let running = Arc::new(AtomicBool::new(true));
    let running_clone = running.clone();

    ctrlc::set_handler(move || {
        running_clone.store(false, Ordering::SeqCst);
    })
    .expect("Error setting Ctrl-C handler");

    listener.set_nonblocking(true)?;

    while running.load(Ordering::SeqCst) {
        match listener.accept() {
            Ok((stream, _)) => {
                let running_clone = running.clone();
                thread::spawn(move || {
                    handle_request(stream, running_clone);
                });
            }
            Err(ref e) if e.kind() == std::io::ErrorKind::WouldBlock => {
                thread::sleep(std::time::Duration::from_millis(50));
            }
            Err(e) => {
                eprintln!("accept error: {}", e);
            }
        }
    }

    let _ = fs::remove_file(&socket_path);
    Ok(())
}

fn handle_request(mut stream: UnixStream, _running: Arc<AtomicBool>) {
    let mut reader = BufReader::new(&stream);
    let mut request_str = String::new();

    if reader.read_line(&mut request_str).is_ok() {
        if let Some(request) = Request::from_string(&request_str) {
            match request {
                Request::HardwareInfo => {
                    hardware::get_hardware_info(stream, _running);
                }
                Request::CompositorData => match DesktopEnvironment::from_env() {
                    DesktopEnvironment::Niri => compositor::niri_ipc_listener(stream, _running),
                    DesktopEnvironment::Hyprland => {
                        compositor::hyprland_ipc_listener(stream, _running)
                    }
                    DesktopEnvironment::Unknown => {
                        let _ = writeln!(stream, "unknown compositor");
                    }
                },
                Request::GeneratePalette { type_, paths } => {
                    wallpaper::generate_color_palette(type_, paths, stream);
                }
                Request::WindowManagerRules => match DesktopEnvironment::from_env() {
                    DesktopEnvironment::Niri => rules::get_rules(stream),
                    DesktopEnvironment::Hyprland => {}
                    DesktopEnvironment::Unknown => {
                        let _ = writeln!(stream, "unknown compositor");
                    }
                },
                Request::Weather { use_curl } => {
                    let use_curl = use_curl.unwrap_or(true);
                    weather::get_weather_info(stream, use_curl, _running);
                }
                Request::FilePicker => {
                    match FileDialog::new().pick_file() {
                        Some(file) => writeln!(stream, "{}", file.display()).ok(),
                        None => writeln!(stream, "error").ok(),
                    };
                }
            }
        } else {
            println!("Unknown request: {}", request_str.trim());
        }
    }
}
