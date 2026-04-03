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
                    item: settingloader.item
                },
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
                // Navbar
                // Top {
                //     screen: reshell.screen
                // }
                // background
                Background {
                    screen: reshell.screen
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
                        onAddDock: item => {
                            fileview.docklist = fileview.docklist.concat([item]);
                        }
                    }
                    onObjectAdded: (obj, idx) => {
                        obj.parent = display;
                    }
                }
            }
        }

        // settings
        Loader {
            id: settingloader
            property bool shouldShow: Global.enableSetting && Compositor.focusedMonitor === screen.name
            active: false
            sourceComponent: Settings {
                onHidden: {
                    settingloader.active = false;
                }
            }
            onShouldShowChanged: {
                if (shouldShow) {
                    active = true;
                    Global.settingpanel = settingloader.item;
                } else if (item) {
                    item.state = 'hide';
                }
            }
            onLoaded: {
                item.state = 'show';
            }
        }

        FileView {
            id: fileview
            path: Qt.resolvedUrl(`./core/data/${screen.name}.json`)
            watchChanges: true
            preload: true

            property list<var> docklist: []

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
