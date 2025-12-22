pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

import qs.config

Singleton {
    id: root
    property bool sessionMenuOpen: false
    property alias loaded: fileView.loaded
    property alias navbar: adapter.navbar
    property alias wallpaper: adapter.wallpaper

    property list<Workspace> workspaces: []
    property Workspace focusedWorkspace: null
    property list<Window> windows: []
    property Window focusedWindow: null
    property bool overviewOpened: false

    property bool openWallpaperPicker: false

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

    Socket {
        path: root.niriSocket
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
                            root.focusedWorkspace = ws;
                        }
                        for (const win of root.windows) {
                            if (win.workspaceId === ws.workspaceId) {
                                ws.windows.push(win);
                            }
                        }
                        workspaces.push(ws);
                    }
                    root.workspaces = workspaces.sort((a, b) => a.idx - b.idx);
                    return root.workspaces = workspaces;
                case EventType.WindowsChanged:
                    for (let workspace of root.workspaces) {
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
                            root.focusedWindow = winObj;
                        }
                        windows.push(winObj);
                        for (let workspace of root.workspaces) {
                            if (workspace.workspaceId === winObj.workspaceId && winObj.workspaceId !== -1) {
                                workspace.windows.push(winObj);
                                break;
                            }
                        }
                    }
                    return root.windows = windows;
                case EventType.WindowClosed:
                    const id = event.WindowClosed.id;
                    for (const win of root.windows) {
                        if (win.windowId === id) {
                            root.windows.splice(root.windows.indexOf(win), 1);
                            break;
                        }
                    }
                    for (const ws of root.workspaces) {
                        for (const win of ws.windows) {
                            if (win === null)
                                return;
                            if (win.windowId === id) {
                                ws.windows.splice(ws.windows.indexOf(win), 1);
                            }
                        }
                    }
                    break;
                case EventType.KeyboardLayoutsChanged:
                    break;
                case EventType.OverviewOpenedOrClosed:
                    root.overviewOpened = event.OverviewOpenedOrClosed.is_open;
                    break;
                case EventType.WorkspaceActivated:
                    break;
                case EventType.WindowFocusChanged:
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
                    for (let window of root.windows) {
                        if (window.id === winObj) {
                            window = winObj;
                        }
                    }
                    root.windows.push(winObj);
                    root.windows.push(winObj);
                    for (let ws of root.workspaces) {
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
                default:
                    break;
                }
            }
        }
    }

    IpcHandler {
        target: "root"
        function toggleWallpaperPicker() {
            root.openWallpaperPicker = !root.openWallpaperPicker;
        }
    }
}
