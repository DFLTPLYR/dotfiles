import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import QtCore

import qs.core
import qs.components

PanelWindow {
    id: panel
    property var file
    readonly property var path: Wallpaper.config.source.filter(s => s && s.monitor === screen.name) || []
    color: "transparent"
    signal dockUpdate(var data)

    implicitHeight: screen.height
    implicitWidth: screen.width

    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: Global.edit ? WlrLayer.Bottom : WlrLayer.Background
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
            active: true
            sourceComponent: MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: mouse => {
                    switch (mouse.button) {
                    case Qt.RightButton:
                        if (!modal.opened) {
                            modal.x = mouseX + modal.width > screen.width ? mouseX - modal.width : mouseX;
                            modal.y = mouseY + modal.height > screen.height ? mouseY - modal.height : mouseY;
                        }
                        modal.opened ? modal.close() : modal.open();
                        return;
                    case Qt.LeftButton:
                        if (modal.opened)
                            modal.close();
                        return;
                    default:
                        return;
                    }
                }
            }
        }
    }

    PopupModal {
        id: modal
        width: 100
        height: container.height + (modal.bottomPadding + modal.topPadding)
        ColumnLayout {
            id: container
            spacing: 0

            width: parent.width

            Button {
                text: "Add Dock"
                Layout.fillWidth: true
                onClicked: mouse => {
                    var globalPos = mapToItem(null, modal.x, modal.y);
                    var l = globalPos.x;
                    var r = screen.width - globalPos.x;
                    var t = globalPos.y;
                    var b = screen.height - globalPos.y;

                    var min = Math.min(l, r, t, b);
                    var direction = min === l ? "left" : min === r ? "right" : min === t ? "top" : "bottom";

                    var name = Math.random().toString(36).substring(2, 10);
                    panel.file.adapter.docks.push(name);

                    panel.dockUpdate({
                        name,
                        direction
                    });
                }
            }
        }
    }
}
