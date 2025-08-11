pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Scope {
    id: root

    property var desktopApp: []

    Process {
        id: openAppInTerminal
        running: false
    }

    function loadApplications() {
        try {
            const Applications = DesktopEntries.applications?.values ?? [];
            const apps = [];

            for (let i = 0; i < Applications.length; i++) {
                const entry = Applications[i];
                if (!entry || !entry.icon || entry.icon === "lsp-plugins")
                    continue;

                let iconPath = "";
                try {
                    iconPath = Quickshell.iconPath(entry.icon, true) || "";
                } catch (e) {
                    console.warn("Icon resolution failed for", entry.icon, e);
                    iconPath = "";
                }

                apps.push({
                    name: entry.name || "",
                    icon: iconPath,
                    exec: entry.execString || "",
                    execFunc: () => {
                        try {
                            if (entry.runInTerminal) {
                                openAppInTerminal.command = ["kitty", "-e", "zsh", "-c", entry.execString];
                                openAppInTerminal.running = true;
                            } else {
                                entry.execute();
                            }
                        } catch (err) {
                            console.error("Execution failed:", err);
                        }
                    },
                    categories: entry.categories || [],
                    comment: entry.comment || ""
                    // No direct reference to entry object
                });
            }

            apps.sort((a, b) => {
                const aMissing = a.icon === '' ? 1 : 0;
                const bMissing = b.icon === '' ? 1 : 0;

                // First: missing icons go last
                if (aMissing !== bMissing) {
                    return aMissing - bMissing;
                }

                // Second: alphabetical by name (case-insensitive)
                return a.name.localeCompare(b.name, undefined, {
                    sensitivity: 'base'
                });
            });

            root.desktopApp = apps;
        } catch (err) {
            console.error("Error while loading applications:", err);
            root.desktopApp = [];
        }
    }
}
