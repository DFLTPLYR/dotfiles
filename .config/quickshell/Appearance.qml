// Appearance.qml
pragma Singleton
import QtQuick

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

import qs.services

Singleton {
    id: root

    property var filePath: './appearance.json'
    property var settings: {}

    function stringifySettings() {
        return JSON.stringify(root.settings, null, 2);
    }
    function getSetting(section, key) {
        return settings[section][key];
    }

    function saveChanges() {
        notifFileView.setText(stringifySettings());
    }

    FileView {
        id: notifFileView
        path: Qt.resolvedUrl(filePath)
        onLoaded: {
            try {
                const fileContents = notifFileView.text();
                if (fileContents && fileContents.length > 0) {
                    root.settings = JSON.parse(fileContents);
                }
                console.log("[Settings] File load");
            } catch (e) {
                console.log("[Settings] Error parsing appearance file: " + e);
            }
        }
        onLoadFailed: error => {
            if (error == FileViewError.FileNotFound) {
                root.settings = {
                    Navbar: {
                        background: "#222",
                        foreground: "#fff",
                        fontSize: 14,
                        iconSize: 24
                    },
                    Appmenu: {
                        background: "#222",
                        foreground: "#fff",
                        fontSize: 14,
                        iconSize: 24
                    }
                };
                notifFileView.setText(stringifySettings());
            } else {
                console.log("[Settings] Error loading file: " + error);
            }
        }
    }
}
