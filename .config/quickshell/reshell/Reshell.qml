import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import qs.core
import qs.types
import qs.modules

Variants {
    model: Quickshell.screens
    delegate: PanelWindow {
        id: reshell
        required property ShellScreen modelData
        implicitWidth: screen.width
        implicitHeight: screen.height

        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: `Reshell-${screen.name}`

        screen: modelData
        color: "transparent"

        mask: Region {
            regions: [
                Region {
                    item: content.item
                }
            ]
        }

        // Wayland Layers
        LazyLoader {
            id: content
            active: fileview.loaded
            component: Item {
                id: display
                // background
                Background {
                    screen: reshell.screen
                    file: fileview
                    onDockUpdate: dock => fileview.updateQueue.push(dock)
                }
                // overlay
                Overlay {
                    screen: reshell.screen
                }
                // docks
                Instantiator {
                    model: adapter.docks
                    delegate: Dock {
                        screen: reshell.screen
                        onAddDock: item => fileview.docklist = fileview.docklist.concat([item])
                    }
                    onObjectAdded: (obj, idx) => {
                        obj.parent = display;
                    }
                }
            }
        }

        FileView {
            id: fileview
            path: Qt.resolvedUrl(`./core/data/${screen.name}.json`)
            watchChanges: true
            preload: true

            property list<var> docklist: []
            property list<var> updateQueue: []

            onDocklistChanged: {
                for (let i = 0; i < docklist.length; i++) {
                    const panelObj = docklist[i].panel;
                    if (panelObj && panelObj.objectName !== null) {
                        const matched = updateQueue.find(obj => obj.name === panelObj.objectName);
                        if (matched) {
                            const config = docklist[i].config;
                            const direction = matched.direction;
                            config.setUp(direction);
                            const idx = updateQueue.indexOf(matched);
                            if (idx !== -1)
                                updateQueue.splice(idx, 1);
                        }
                    }
                }
            }

            onFileChanged: {
                reload();
            }

            onLoadFailed: error => {
                if (error === FileViewError.FileNotFound) {
                    fileview.setText("{}");
                    fileview.writeAdapter();
                    Quickshell.reload(true);
                }
            }

            adapter: JsonAdapter {
                id: adapter
                property list<var> docks: []
            }

            function save() {
                fileview.writeAdapter();
            }

            Component.onCompleted: {
                Global.fileManager.push({
                    ref: fileview,
                    subject: `${screen.name}-dock`
                });
            }
        }
    }
}
