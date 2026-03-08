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
    property var focusedMonitor: Quickshell.screens[0].name
    property var focusedWindow: null
    property bool overviewOpened: false
    property bool ready: false
    readonly property string daemonSocket: Quickshell.env("XDG_RUNTIME_DIR") + "/pdaemon.sock"

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
            property string address: ""
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
        id: compositorSocket
        path: config.daemonSocket
        connected: true
        onConnectedChanged: {
            if (connected)
                write("compositor\n");
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
                    FocusedMonitor: "FocusedMonitor",
                    WindowFocusChanged: "WindowFocusChanged",
                    Fullscreen: "Fullscreen",
                    WindowPinned: "WindowPinned",
                    WindowFloating: "WindowFloating",
                    MonitorChanged: "MonitorChanged"
                };
                switch (key) {
                case EventType.WorkspacesChanged:
                    let temp = [];
                    const wsList = event.WorkspacesChanged.workspaces;
                    for (const workspace of wsList) {
                        if (!workspace.idx)
                            break;
                        const ws = workspaceComponent.createObject(null, {
                            workspaceId: workspace.id,
                            idx: workspace.idx,
                            name: workspace.name,
                            output: workspace.output || "",
                            isUrgent: workspace.is_urgent || false,
                            isActive: workspace.is_active || false,
                            isFocused: workspace.is_focused || false,
                            activeWindowID: workspace.active_window_id || -1
                        });
                        if (ws.isFocused) {
                            config.focusedWorkspace = ws;
                        }
                        for (const win of config.windows) {
                            if (win.workspaceId === ws.workspaceId) {
                                ws.windows.push(win);
                            }
                        }
                        temp.push(ws);
                    }
                    config.workspaces = temp.sort((a, b) => a.idx - b.idx);
                    if (!config.ready && config.workspaces.length > 0) {
                        config.ready = true;
                    }
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
                            isUrgent: win.is_urgent,
                            address: win.address || ""
                        });
                        if (winObj.isFocused) {
                            config.focusedWindow = winObj;
                        }
                        for (let workspace of config.workspaces) {
                            if (workspace.workspaceId === winObj.workspaceId && winObj.workspaceId !== -1) {
                                workspace.windows.push(winObj);
                            }
                        }
                        windows.push(winObj);
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
                            if (win && win.windowId === id) {
                                ws.windows.splice(ws.windows.indexOf(win), 1);
                            }
                        }
                    }
                    break;
                case EventType.FocusedMonitor:
                    config.focusedMonitor = event.FocusedMonitor.name;
                    if (!config.ready) {
                        config.ready = true;
                    }
                    break;
                case EventType.WindowFocusChanged:
                    const winChanged = event.WindowFocusChanged.window;
                    const addr = event.WindowFocusChanged.address;
                    for (const win of config.windows) {
                        if (win.address === addr || (winChanged && win.appId === winChanged.class)) {
                            win.isFocused = true;
                            config.focusedWindow = win;
                        } else {
                            win.isFocused = false;
                        }
                    }
                    break;
                case EventType.WindowOpenedOrChanged:
                    const winNew = event.WindowOpenedOrChanged.window;
                    let existingWindow = config.windows.find(w => w.address === winNew.address);
                    if (existingWindow) {
                        existingWindow.title = winNew.title;
                        existingWindow.appId = winNew.class;
                        existingWindow.workspaceId = winNew.workspace || -1;
                        existingWindow.isFocused = winNew.is_focused;
                        existingWindow.isFloating = winNew.is_floating;
                    } else {
                        const winObj = windowComponent.createObject(null, {
                            windowId: 0,
                            title: winNew.title,
                            appId: winNew.class,
                            pid: 0,
                            workspaceId: winNew.workspace || -1,
                            isFocused: winNew.is_focused || true,
                            isFloating: winNew.is_floating || false,
                            isUrgent: false,
                            address: winNew.address
                        });
                        config.windows.push(winObj);
                    }
                    return;
                case EventType.Fullscreen:
                case EventType.WindowPinned:
                case EventType.WindowFloating:
                case EventType.MonitorChanged:
                    break;
                default:
                    break;
                }
            }
        }
    }
}
