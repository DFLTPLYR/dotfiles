use niri_ipc::{Event, Response, socket::Socket};
use serde_json;
use std::io::{BufRead, BufReader, Write};
use std::os::unix::net::UnixStream;
use std::sync::Arc;
use std::sync::atomic::{AtomicBool, Ordering};

pub fn niri_ipc_listener(mut stream: UnixStream, running: Arc<AtomicBool>) {
    let mut socket = Socket::connect().expect("Error Occured");

    let reply = socket
        .send(niri_ipc::Request::EventStream)
        .expect("Socket not found");

    if matches!(reply, Ok(Response::Handled)) {
        let mut read_event = socket.read_events();
        while running.load(Ordering::SeqCst) {
            match read_event() {
                Ok(event) => {
                    handle_niri_event(&event, &mut stream);
                    if matches!(
                        event,
                        Event::WorkspaceActivated { .. }
                            | Event::WindowFocusChanged { .. }
                            | Event::WindowFocusTimestampChanged { .. }
                    ) {
                        if let Some(focused) = get_focused_output() {
                            let _ = writeln!(stream, "{}", focused);
                        }
                    }
                }
                Err(_) => break,
            }
        }
    }
}

fn get_focused_output() -> Option<String> {
    let mut socket = Socket::connect().ok()?;
    let reply = socket.send(niri_ipc::Request::FocusedOutput).ok()?;
    match reply {
        Ok(Response::FocusedOutput(output)) => Some(
            serde_json::json!({
                "FocusedMonitor": {
                    "name": output.as_ref().map(|o| &o.name)
                }
            })
            .to_string(),
        ),
        _ => None,
    }
}

fn handle_niri_event(event: &Event, stream: &mut UnixStream) {
    let json = match event {
        Event::WorkspacesChanged { workspaces } => serde_json::json!({
            "WorkspacesChanged": {
                "workspaces": workspaces.iter().map(|ws| {
                    serde_json::json!({
                        "id": ws.id,
                        "idx": ws.idx,
                        "name": ws.name,
                        "output": ws.output,
                        "is_urgent": ws.is_urgent,
                        "is_active": ws.is_active,
                        "is_focused": ws.is_focused,
                        "active_window_id": ws.active_window_id
                    })
                }).collect::<Vec<_>>()
            }
        })
        .to_string(),
        Event::WindowsChanged { windows } => serde_json::json!({
            "WindowsChanged": {
                "windows": windows.iter().map(|w| {
                    serde_json::json!({
                        "id": w.id,
                        "title": w.title,
                        "app_id": w.app_id,
                        "pid": w.pid,
                        "workspace_id": w.workspace_id,
                        "is_focused": w.is_focused,
                        "is_floating": w.is_floating,
                        "is_urgent": w.is_urgent
                    })
                }).collect::<Vec<_>>()
            }
        })
        .to_string(),
        Event::WindowOpenedOrChanged { window } => serde_json::json!({
            "WindowOpenedOrChanged": {
                "window": {
                    "id": window.id,
                    "title": window.title,
                    "app_id": window.app_id,
                    "pid": window.pid,
                    "workspace_id": window.workspace_id,
                    "is_focused": window.is_focused,
                    "is_floating": window.is_floating,
                    "is_urgent": window.is_urgent
                }
            }
        })
        .to_string(),
        Event::WindowClosed { id } => serde_json::json!({
            "WindowClosed": { "id": id }
        })
        .to_string(),
        Event::WorkspaceActivated { id, focused } => serde_json::json!({
            "WorkspaceActivated": { "id": id, "focused": focused }
        })
        .to_string(),
        Event::WindowFocusChanged { id } => serde_json::json!({
            "WindowFocusChanged": { "id": id }
        })
        .to_string(),
        Event::WindowFocusTimestampChanged {
            id,
            focus_timestamp,
        } => serde_json::json!({
            "WindowFocusTimestampChanged": { "id": id, "focus_timestamp": focus_timestamp }
        })
        .to_string(),
        Event::KeyboardLayoutsChanged { .. } => serde_json::json!({
            "KeyboardLayoutsChanged": {}
        })
        .to_string(),
        Event::OverviewOpenedOrClosed { is_open } => serde_json::json!({
            "OverviewOpenedOrClosed": { "is_open": is_open }
        })
        .to_string(),
        _ => return,
    };
    let _ = writeln!(stream, "{}", json);
}

pub fn hyprland_ipc_listener(mut stream: UnixStream, running: Arc<AtomicBool>) {
    let socket_path = std::env::var("XDG_RUNTIME_DIR")
        .map(|dir| {
            format!(
                "{}/hypr/{}/.socket2.sock",
                dir,
                std::env::var("HYPRLAND_INSTANCE_SIGNATURE").unwrap_or_default()
            )
        })
        .unwrap_or_else(|_| "/tmp/hypr/.socket2.sock".to_string());
    let socket = UnixStream::connect(&socket_path).expect("Failed to connect to Hyprland socket");
    let mut reader = BufReader::new(socket);
    while running.load(Ordering::SeqCst) {
        let mut line = String::new();
        match reader.read_line(&mut line) {
            Ok(0) => break,
            Ok(_) => {
                let line = line.trim();
                if let Some((event, data)) = line.split_once(">>") {
                    handle_hyprland_event(event, data, &mut stream);
                }
            }
            Err(_) => break,
        }
    }
}

fn handle_hyprland_event(event: &str, data: &str, stream: &mut UnixStream) {
    let json = match event {
        "workspace" | "workspacev2" => {
            let parts: Vec<&str> = data.split(',').collect();
            if parts.len() >= 2 {
                serde_json::json!({
                    "WorkspacesChanged": {
                        "workspaces": [{"id": parts[0].parse::<i32>().unwrap_or(0), "name": parts[1]}]
                    }
                }).to_string()
            } else {
                return;
            }
        }
        "focusedmon" | "focusedmonv2" => {
            let parts: Vec<&str> = data.split(',').collect();
            if parts.len() >= 2 {
                serde_json::json!({
                    "FocusedMonitor": {"name": parts[0], "workspace": parts[1]}
                })
                .to_string()
            } else {
                return;
            }
        }
        "activewindow" => {
            let parts: Vec<&str> = data.split(',').collect();
            if parts.len() >= 2 {
                serde_json::json!({
                    "WindowFocusChanged": {
                        "window": {"class": parts[0], "title": parts[1]}
                    }
                })
                .to_string()
            } else {
                return;
            }
        }
        "activewindowv2" => serde_json::json!({
            "WindowFocusChanged": {"address": data}
        })
        .to_string(),
        "openwindow" => {
            let parts: Vec<&str> = data.split(',').collect();
            if parts.len() >= 4 {
                serde_json::json!({
                    "WindowOpenedOrChanged": {
                        "window": {
                            "address": parts[0],
                            "workspace": parts[1],
                            "class": parts[2],
                            "title": parts[3]
                        }
                    }
                })
                .to_string()
            } else {
                return;
            }
        }
        "closewindow" => serde_json::json!({
            "WindowClosed": {"address": data}
        })
        .to_string(),
        "createworkspace" | "destroyworkspace" | "moveworkspace" => serde_json::json!({
            "WorkspacesChanged": {"workspaces": [{"name": data}]}
        })
        .to_string(),
        "monitoradded" | "monitorremoved" => serde_json::json!({
            "MonitorChanged": {"name": data}
        })
        .to_string(),
        "fullscreen" => serde_json::json!({
            "Fullscreen": {"state": data == "1"}
        })
        .to_string(),
        "pin" => {
            let parts: Vec<&str> = data.split(',').collect();
            serde_json::json!({
                "WindowPinned": {"address": parts.get(0).unwrap_or(&""), "pinned": *parts.get(1).unwrap_or(&"false") == "true"}
            }).to_string()
        }
        "changefloatingmode" => {
            let parts: Vec<&str> = data.split(',').collect();
            serde_json::json!({
                "WindowFloating": {"address": parts.get(0).unwrap_or(&""), "floating": *parts.get(1).unwrap_or(&"false") == "true"}
            }).to_string()
        }
        _ => return,
    };
    let _ = writeln!(stream, "{}", json);
}
