import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import qs.core
import qs.modules

import qs.types

Variants {
    model: Quickshell.screens
    delegate: PanelWindow {
        id: panel
        required property ShellScreen modelData
        screen: modelData

        color: "transparent"

        anchors {
            top: Navbar.config.position === "top"
            bottom: Navbar.config.position === "bottom"
            left: Navbar.config.position === "left"
            right: Navbar.config.position === "right"
        }

        implicitHeight: screen.height
        implicitWidth: screen.width

        exclusiveZone: navbar.height
        exclusionMode: ExclusionMode.Normal

        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: `Top-${screen.name}`

        mask: Region {
            regions: [
                Region {
                    item: Global.enableSetting ? floatingWindow : null
                },
                Region {
                    item: navbar
                }
            ]
        }

        Navbar {
            id: navbar
        }

        Settings {
            id: floatingWindow
        }

        FileView {
            id: fileView
            path: Qt.resolvedUrl(`./core/${screen.name}.json`)
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
            adapter: JsonAdapter {
                id: adapter
                property int height: 40
                property int width: 40

                property string position: "top" // top, bottom, left, right
                readonly property bool side: position === "left" || position === "right"
                property StyleJson style: StyleJson {
                    color: Colors.color.background
                    border {
                        width: 1
                        color: Colors.color.primary
                    }
                }

                property list<var> layouts: []
                property list<var> widgets: []
            }

            Component.onCompleted: Global.fileManager.push({
                ref: fileView,
                subject: `${screen.name}-navbar`
            })
        }
    }
}
