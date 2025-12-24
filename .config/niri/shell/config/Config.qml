pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

import qs.config

Singleton {
    id: config
    property bool sessionMenuOpen: false
    property alias loaded: fileView.loaded
    property alias navbar: adapter.navbar
    property alias wallpaper: adapter.wallpaper

    property list<Workspace> workspaces: []
    property Workspace focusedWorkspace: null
    property list<Window> windows: []
    property var focusedMonitor: null
    property Window focusedWindow: null
    property bool overviewOpened: false

    property bool openWallpaperPicker: false
    property bool openAppLauncher: false
    property bool openSessionMenu: false

    FileView {
        id: fileView
        path: Qt.resolvedUrl("./config.json")
        watchChanges: true
        preload: true
        onFileChanged: {
            reload();
        }
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound) {
                fileView.setText("{}");
                fileView.writeAdapter();
            }
        }
        JsonAdapter {
            id: adapter
            property NavbarConfig navbar: NavbarConfig {}
            property var wallpaper: []
        }
    }

    function saveSettings() {
        fileView.writeAdapter();
    }

    // Credits to this Chad
    // https://github.com/tpaau/dots/blob/main/private_dot_config/quickshell/services/niri/Niri.qml
    readonly property string niriSocket: Quickshell.env("NIRI_SOCKET")

    Component {
        id: windowComponent
        Window {}
    }

    Component {
        id: workspaceComponent
        Workspace {}
    }

    function requestFocusedMonitor() {
        niriSocket.write('"FocusedOutput"\n');
    }

    Socket {
        id: niriSocket
        path: config.niriSocket
        connected: true
        onConnectionStateChanged: {
            write('"FocusedOutput"\n');
        }
        parser: SplitParser {
            onRead: line => {
                const response = JSON.parse(line);
                const status = Object.keys(response)[0];

                if (status === "Err")
                    return;

                const key = Object.keys(response.Ok)[0];

                const EventType = {
                    FocusedOutput: "FocusedOutput"
                };

                switch (key) {
                case EventType.FocusedOutput:
                    const focusedMonitor = response.Ok.FocusedOutput;
                    config.focusedMonitor = focusedMonitor;
                    break;
                default:
                    break;
                }
            }
        }
    }

    Socket {
        path: config.niriSocket
        connected: true
        onConnectedChanged: {
            write('"EventStream"\n');
        }
        parser: SplitParser {
            onRead: line => {
                const event = JSON.parse(line);
                const key = Object.keys(event)[0];

                const EventType = {
                    WorkspacesChanged: "WorkspacesChanged",
                    WindowOpenedOrChanged: "WindowOpenedOrChanged",
                    WindowsChanged: "WindowsChanged",
                    WindowClosed: "WindowClosed",
                    KeyboardLayoutsChanged: "KeyboardLayoutsChanged",
                    OverviewOpenedOrClosed: "OverviewOpenedOrClosed",
                    WorkspaceActivated: "WorkspaceActivated",
                    WindowFocusChanged: "WindowFocusChanged",
                    WindowFocusTimestampChanged: "WindowFocusTimestampChanged"
                };

                switch (key) {
                case EventType.WorkspacesChanged:
                    let workspaces = [];
                    for (const workspace of event.WorkspacesChanged.workspaces) {
                        const ws = workspaceComponent.createObject(null, {
                            workspaceId: workspace.id,
                            idx: workspace.idx,
                            name: workspace.name,
                            output: workspace.output,
                            isUrgent: workspace.is_urgent,
                            isActive: workspace.is_active,
                            isFocused: workspace.is_focused,
                            activeWindowID: workspace.active_window_id ? workspace.active_window_id : -1
                        });

                        if (ws.isFocused) {
                            config.focusedWorkspace = ws;
                        }
                        for (const win of config.windows) {
                            if (win.workspaceId === ws.workspaceId) {
                                ws.windows.push(win);
                            }
                        }
                        workspaces.push(ws);
                    }
                    config.workspaces = workspaces.sort((a, b) => a.idx - b.idx);
                    break;
                case EventType.WindowsChanged:
                    for (let workspace of config.workspaces) {
                        workspace.windows = [];
                    }
                    const eventWindows = event.WindowsChanged.windows;
                    let windows = [];
                    for (const win of eventWindows) {
                        const winObj = windowComponent.createObject(null, {
                            windowId: win.id,
                            title: win.title,
                            appId: win.app_id,
                            pid: win.pid,
                            workspaceId: win.workspace_id ?? -1,
                            isFocused: win.is_focused,
                            isFloating: win.is_floating,
                            isUrgent: win.is_urgent
                        });
                        if (winObj.isFocused) {
                            config.focusedWindow = winObj;
                        }
                        // windows.push(winObj);
                        for (let workspace of config.workspaces) {
                            if (workspace.workspaceId === winObj.workspaceId && winObj.workspaceId !== -1) {
                                workspace.windows.push(winObj);
                            }
                        }
                    }
                    return config.windows = windows;
                case EventType.WindowClosed:
                    const id = event.WindowClosed.id;
                    for (const win of config.windows) {
                        if (win.windowId === id) {
                            config.windows.splice(config.windows.indexOf(win), 1);
                            break;
                        }
                    }
                    // for (const ws of config.workspaces) {
                    //     for (const win of ws.windows) {
                    //         if (win === null)
                    //             return;
                    //         if (win.windowId === id) {
                    //             ws.windows.splice(ws.windows.indexOf(win), 1);
                    //         }
                    //     }
                    // }
                    break;
                case EventType.KeyboardLayoutsChanged:
                    break;
                case EventType.OverviewOpenedOrClosed:
                    config.overviewOpened = event.OverviewOpenedOrClosed.is_open;
                    break;
                case EventType.WorkspaceActivated:
                    break;
                case EventType.WindowFocusChanged:
                    config.requestFocusedMonitor();
                    break;
                case EventType.WindowOpenedOrChanged:
                    const win = event.WindowOpenedOrChanged.window;
                    const winObj = windowComponent.createObject(null, {
                        windowId: win.id,
                        title: win.title,
                        appId: win.app_id,
                        pid: win.pid,
                        workspaceId: win.workspace_id ?? -1,
                        isFocused: win.is_focused,
                        isFloating: win.is_floating,
                        isUrgent: win.is_urgent
                    });
                    for (let window of config.windows) {
                        if (window.id === winObj) {
                            window = winObj;
                        }
                    }
                    config.windows.push(winObj);
                    config.windows.push(winObj);
                    for (let ws of config.workspaces) {
                        if (ws.workspaceId === winObj.workspaceId) {
                            for (let win of ws.windows) {
                                if (win === null)
                                    return;
                                if (win.windowId === winObj.windowId) {
                                    win = winObj;
                                    return;
                                }
                            }
                            ws.windows.push(winObj);
                            return;
                        }
                    }
                    break;
                default:
                    break;
                }
            }
        }
    }

    IpcHandler {
        target: "config"
        function toggleWallpaperPicker() {
            config.openWallpaperPicker = !config.openWallpaperPicker;
        }

        function toggleAppLauncher() {
            config.openAppLauncher = !config.openAppLauncher;
        }

        function toggleSessionMenu() {
            config.sessionMenuOpen = !config.sessionMenuOpen;
        }
    }
}
