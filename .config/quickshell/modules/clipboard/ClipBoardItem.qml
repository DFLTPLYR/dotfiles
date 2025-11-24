import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell

import qs.assets
import qs.config
import qs.utils

Item {
    required property var modelData
    readonly property bool isImage: modelData.text.startsWith("[[ binary data")
    property bool isSelected: ListView.isCurrentItem
    property bool isHovered: clickableArea.containsMouse

    visible: clipboardList.count !== 0
    width: clipboardList.width
    height: 72

    Rectangle {
        id: container
        anchors.fill: parent

        border.color: isHovered || isSelected ? Color.color10 : Color.color15

        color: isHovered || isSelected ? Color.color10 : Scripts.setOpacity(Color.background, 0.2)
        radius: 4

        Behavior on border.color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }

        RowLayout {
            anchors.centerIn: parent
            width: Math.round(parent.width * 0.95)
            height: parent.height
            spacing: 8

            // First child: fills width and height
            Item {
                id: clipboardDisplay
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                Text {
                    id: clipboardText
                    color: isHovered || isSelected ? Color.color15 : Color.color10
                    width: parent.width
                    height: parent.height

                    anchors {
                        left: parent.left // Start at the left
                        verticalCenter: parent.verticalCenter // Center vertically
                    }

                    visible: false
                    font.pixelSize: 18

                    elide: Text.ElideRight
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                Component.onCompleted: {
                    var data = modelData.text;
                    if (modelData.isImage) {
                        clipboardText.text = "IMAGE";
                        clipboardText.color = Color.color15;
                        clipboardText.visible = true;
                    } else {
                        clipboardText.text = modelData.text;
                        clipboardText.visible = true;
                    }
                }

                MouseArea {
                    id: clickableArea
                    anchors.fill: parent
                    propagateComposedEvents: true

                    onClicked: {
                        toplevel.copySelectedId(modelData.id);
                    }
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                }
            }

            // Second child: example icon or placeholder
            Text {
                id: trash
                text: '\uf1f8'
                color: isHovered || isSelected ? Color.color15 : Color.color10

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        toplevel.deleteClipboardEntry(modelData.id);
                    }
                    z: 1
                }
            }

            Text {
                id: copy
                text: '\uf0c5'
                color: isHovered || isSelected ? Color.color15 : Color.color10
            }
        }
    }
}
