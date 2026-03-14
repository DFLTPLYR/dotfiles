import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import QtCore

import qs.core

Variants {
    model: Quickshell.screens
    delegate: PanelWindow {
        id: panel
        required property ShellScreen modelData
        readonly property var path: Wallpaper.config.source.filter(s => s && s.monitor === screen.name) || []
        screen: modelData
        color: "transparent"

        implicitHeight: screen.height
        implicitWidth: screen.width

        exclusionMode: ExclusionMode.Ignore

        WlrLayershell.layer: WlrLayer.Background
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace: `Background-${screen.name}`

        Item {
            id: layered
            width: parent.width
            height: parent.width

            Process {
                id: cmdGenerateColor
            }

            Connections {
                target: Wallpaper
                function onGeneratecolor() {
                    layered.onSaveCustomWallpaper();
                }
            }
            function onSaveCustomWallpaper() {
                layered.grabToImage(function (result) {
                    result.saveToFile(`${StandardPaths.writableLocation(StandardPaths.CacheLocation)}/cropped_${panel.screen.name}.jpg`);
                    Qt.callLater(() => {
                        Quickshell.execDetached({
                            command: ["pcli", "generate-palette", "--type", "scheme-content", ...Wallpaper.config.layers.map(image => image.source)]
                        });
                    });
                }, Qt.size(panel.screen.width, panel.screen.height));
            }

            Instantiator {
                model: ScriptModel {
                    values: [...Wallpaper.config.layers].filter(item => item && item.screens.some(s => s && s.name === panel.screen.name))
                }
                delegate: Image {
                    id: wallpaperImage
                    required property var modelData
                    property var relative: modelData.screens.find(s => s.name === panel.screen.name)
                    parent: layered

                    width: modelData.width
                    height: modelData.height
                    x: relative.x
                    y: relative.y

                    source: modelData.source
                    opacity: 0

                    states: State {
                        name: "visible"
                        PropertyChanges {
                            target: wallpaperImage
                            opacity: 1
                        }
                    }

                    transitions: [
                        Transition {
                            from: "*"
                            to: "*"
                            NumberAnimation {
                                properties: "opacity,scale"
                                duration: 300
                                easing.type: Easing.InOutSine
                            }
                        }
                    ]
                }
                onObjectAdded: (idx, obj) => obj.state = "visible"
            }
        }
    }
}
