use std::process::Command;

use clap::Subcommand;

pub mod modules;

pub enum DesktopEnvironment {
    Niri,
    Hyprland,
    Unknown,
}

#[allow(dead_code)]
impl DesktopEnvironment {
    pub fn from_env() -> Self {
        match std::env::var("XDG_CURRENT_DESKTOP") {
            Ok(val) if val == "Niri" => DesktopEnvironment::Niri,
            Ok(val) if val == "Hyprland" => DesktopEnvironment::Hyprland,
            _ => DesktopEnvironment::Unknown,
        }
    }
}

// Check if 'qs' process is running
fn is_qs_running() -> bool {
    Command::new("pgrep")
        .arg("-x")
        .arg("qs")
        .output()
        .map(|output| output.status.success())
        .unwrap_or(false)
}

// Cli
#[derive(Subcommand)]
pub enum Commands {
    /// Get hardware information
    Hardware,
    Compositor,
    /// Shell actions
    Launch {
        target: String,
    },
    GeneratePalette {
        #[clap(long)]
        type_: String,
        #[clap(value_name = "PATH")]
        paths: Vec<String>,
    },
    Rules,
    Weather,
    FilePicker,
}

impl Commands {
    pub fn to_request_string(&self) -> String {
        match self {
            Commands::Hardware => "hardware".to_string(),
            Commands::Compositor => "compositor".to_string(),
            Commands::Rules => "window_manager_rules".to_string(),
            Commands::Weather => "weather".to_string(),
            Commands::FilePicker => "file_picker".to_string(),
            Commands::GeneratePalette { type_, paths } => {
                format!("generate_palette {} {}", type_, paths.join(" "))
            }
            Commands::Launch { target } => {
                format!("launch {:?}", target)
            }
        }
    }
}

#[derive(Debug)]
pub enum Request {
    HardwareInfo,
    CompositorData,
    GeneratePalette { type_: String, paths: Vec<String> },
    WindowManagerRules,
    Weather { use_curl: Option<bool> },
    FilePicker,
}

impl Request {
    pub fn from_string(s: &str) -> Option<Self> {
        let parts: Vec<&str> = s.trim().split_whitespace().collect();
        match parts.as_slice() {
            ["hardware"] => Some(Request::HardwareInfo),
            ["compositor"] => Some(Request::CompositorData),
            ["file_picker"] => Some(Request::FilePicker),
            ["generate_palette", type_, rest @ ..] => Some(Request::GeneratePalette {
                type_: type_.to_string(),
                paths: rest.iter().map(|s| s.to_string()).collect(),
            }),
            ["window_manager_rules"] => Some(Request::WindowManagerRules),
            ["weather"] => Some(Request::Weather { use_curl: None }),
            ["weather", s] => {
                let val = match s.to_lowercase().as_str() {
                    "true" => Some(true),
                    "false" => Some(false),
                    _ => None,
                };
                Some(Request::Weather { use_curl: val })
            }
            _ => None,
        }
    }
}
