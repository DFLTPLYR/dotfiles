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

    readonly property string niriSocket: Quickshell.env("NIRI_SOCKET")

    property list<Workspace> workspaces: []
    property Workspace focusedWorkspace: null
    property list<Window> windows: []
    property Window focusedWindow: null
    property bool overviewOpened: false

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
                    WindowsChanged: "WindowsChanged",
                    KeyboardLayoutsChanged: "KeyboardLayoutsChanged",
                    OverviewOpenedOrClosed: "OverviewOpenedOrClosed",
                    WorkspaceActivated: "WorkspaceActivated",
                    WindowFocusChanged: "WindowFocusChanged",
                    WindowFocusTimestampChanged: "WindowFocusTimestampChanged"
                };

                switch (key) {
                case EventType.WorkspacesChanged:
                    break;
                case EventType.WindowsChanged:
                    break;
                case EventType.KeyboardLayoutsChanged:
                    break;
                case EventType.OverviewOpenedOrClosed:
                    break;
                case EventType.WorkspaceActivated:
                    break;
                case EventType.WindowFocusChanged:
                    break;
                default:
                    break;
                }
            }
        }
    }
}
