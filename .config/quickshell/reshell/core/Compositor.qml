pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick

import Quickshell
import Quickshell.Io

Singleton {
    id: config
    property var workspaces: []
    property var windows: []
    property var focusedWorkspace: null
    property var focusedMonitor: null
    property var focusedWindow: null
    property bool overviewOpened: false

    property bool ready: false

    // Credits to this Chad
    // https://github.com/tpaau/dots/blob/main/private_dot_config/quickshell/services/niri/Niri.qml
    readonly property string niriSocket: Quickshell.env("NIRI_SOCKET")

    Component {
        id: windowComponent
        QtObject {
            required property int windowId
            required property string title
            required property string appId
            required property int pid
            required property int workspaceId
            required property bool isFocused
            required property bool isFloating
            required property bool isUrgent
        }
    }

    Component {
        id: workspaceComponent
        QtObject {
            required property int workspaceId
            required property int idx
            required property string name
            required property string output
            required property bool isUrgent
            required property bool isActive
            required property bool isFocused
            required property int activeWindowID
            property list<Window> windows: []
        }
    }

    Socket {
        id: niriSocket
        path: config.niriSocket
        connected: true
        onConnectionStateChanged: {
            if (connected)
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
                    config.focusedMonitor = focusedMonitor.name;
                    if (!config.ready) {
                        config.ready = true;
                    }
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
            if (connected)
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
                    let temp = [];
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
                        config.workspaces.push(ws);
                    }
                    config.workspaces = temp.sort((a, b) => a.idx - b.idx);
                    return;
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
                    for (const ws of config.workspaces) {
                        for (const win of ws.windows) {
                            if (win.windowId === id) {
                                ws.windows.splice(ws.windows.indexOf(win), 1);
                            }
                        }
                    }
                    break;
                case EventType.KeyboardLayoutsChanged:
                    break;
                case EventType.OverviewOpenedOrClosed:
                    config.overviewOpened = event.OverviewOpenedOrClosed.is_open;
                    break;
                case EventType.WorkspaceActivated:
                    niriSocket.write('"FocusedOutput"\n');
                    break;
                case EventType.WindowFocusChanged:
                    niriSocket.write('"FocusedOutput"\n');
                    break;
                case EventType.WindowFocusTimestampChanged:
                    niriSocket.write('"FocusedOutput"\n');
                    break;
                case EventType.WindowOpenedOrChanged:
                    const win = event.WindowOpenedOrChanged.window;
                    let existingWindow = config.windows.find(w => w.windowId === win.id);
                    if (existingWindow) {
                        existingWindow.title = win.title;
                        existingWindow.appId = win.app_id;
                        existingWindow.pid = win.pid;
                        existingWindow.workspaceId = win.workspace_id ?? -1;
                        existingWindow.isFocused = win.is_focused;
                        existingWindow.isFloating = win.is_floating;
                        existingWindow.isUrgent = win.is_urgent;
                    } else {
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
                        config.windows.push(winObj);
                    }
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
                        }
                    }
                    return;
                default:
                    break;
                }
            }
        }
    }
}
