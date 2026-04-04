import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import QtCore

import qs.core
import qs.components

PanelWindow {
    id: panel
    readonly property var path: Wallpaper.config.source.filter(s => s && s.monitor === screen.name) || []
    color: "transparent"

    implicitHeight: screen.height
    implicitWidth: screen.width

    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: Global.enableSetting ? WlrLayer.Bottom : WlrLayer.Background
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.namespace: `Background-${screen.name}`

    mask: Region {
        item: mask
    }

    Item {
        id: layered
        width: parent.width
        height: parent.width

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
                    Global.updateColor();
                });
            }, Qt.size(panel.screen.width, panel.screen.height));
        }

        Instantiator {
            model: ScriptModel {
                values: [...Wallpaper.config.layers].filter(item => item && item.screens && item.screens.some(s => s && s.name === panel.screen.name))
            }
            delegate: Image {
                id: wallpaperImage
                required property var modelData
                property var relative: modelData.screens.find(s => s && s.name === panel.screen.name)
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

    Item {
        id: mask
        width: parent.width
        height: parent.width

        Loader {
            anchors.fill: parent
            active: Global.edit
            sourceComponent: MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: mouse => {
                    if (mouse.button === Qt.RightButton) {
                        if (!modal.opened) {
                            modal.x = mouseX + modal.width > screen.width ? mouseX - modal.width : mouseX;
                            modal.y = mouseY + modal.height > screen.height ? mouseY - modal.height : mouseY;
                        }
                        modal.opened ? modal.close() : modal.open();
                    }
                }
            }
        }
    }

    PopupModal {
        id: modal
        width: 200
        height: screen.height / 2
    }
}
