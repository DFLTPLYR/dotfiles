pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Singleton {
    id: root

    property var desktopApp: []

    Process {
        id: openAppInTerminal
        running: false
    }

    Component.onCompleted: {
        const Applications = DesktopEntries.applications.values;

        const apps = [];

        for (let i = 0; i < Applications.length; i++) {
            const entry = Applications[i];
            if (!entry.icon || entry.icon === "lsp-plugins")
                continue;

            let iconName = entry.icon;
            let resolved = Quickshell.iconPath(iconName, true);

            apps.push({
                name: entry.name,
                icon: resolved,
                exec: entry.execString,
                execFunc: () => {
                    if (entry.runInTerminal) {
                        openAppInTerminal.command = ["kitty", "-e", "zsh", "-c", entry.execString];
                        openAppInTerminal.running = true;
                    } else {
                        entry.execute(); // GUI app
                    }
                },
                categories: entry.categories,
                comment: entry.comment,
                ref: entry
            });
        }

        apps.sort((a, b) => {
            const aMissing = a.icon === '' ? 1 : 0;
            const bMissing = b.icon === '' ? 1 : 0;

            if (aMissing !== bMissing) {
                return aMissing - bMissing;
            }

            return 0;
        });

        root.desktopApp = apps;
    }
}
