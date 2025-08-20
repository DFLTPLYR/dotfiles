import QtQuick
import QtQuick.Layouts

import qs.services
import qs.utils

Item {
    width: flick.delegateWidth
    height: flick.delegateHeight
    anchors.verticalCenter: parent ? parent.verticalCenter : undefined

    property bool isFocused: ListView.isCurrentItem
    required property var modelData

    Rectangle {
        id: container
        anchors.fill: parent
        anchors.margins: 8
        radius: 12
        clip: true

        property real targetScale: isFocused || itemMouse.hovered ? 1.05 : 1.0
        property color targetColor: isFocused || itemMouse.hovered ? Scripts.hexToRgba(Colors.color14, 0.5) : Scripts.hexToRgba(Colors.color12, 0.2)

        scale: targetScale
        color: targetColor

        Behavior on scale {
            NumberAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }

        ColumnLayout {
            anchors.fill: parent

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height * 0.10
                Item {
                    Layout.fillWidth: true
                }
                Repeater {
                    model: modelData.colors.slice(0, 7)
                    Rectangle {
                        width: 24
                        height: width
                        color: modelData.color
                        radius: height
                        border.color: "#444"
                        border.width: 1
                    }
                }
                Item {
                    Layout.fillWidth: true
                }
            }

            Image {
                Layout.fillWidth: true
                Layout.fillHeight: true
                anchors.margins: 8
                fillMode: Image.PreserveAspectCrop
                source: Qt.resolvedUrl(modelData.path)
                cache: true
                asynchronous: true
                smooth: true
                mipmap: true
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height * 0.10
                Item {
                    Layout.fillWidth: true
                }
                Repeater {
                    model: modelData.colors.slice(8, 16)

                    Rectangle {
                        width: 24
                        height: width
                        color: modelData.color
                        radius: height
                        border.color: modelData.color
                        border.width: 1
                    }
                }
                Item {
                    Layout.fillWidth: true
                }
            }
        }

        MouseArea {
            id: itemMouse
            anchors.fill: parent
            hoverEnabled: true
            property bool hovered: containsMouse

            onClicked: {
                const screenName = toplevel.screen.name;
                WallpaperStore.setWallpaper(screenName, modelData.path);
            }

            onEntered: hovered = true
            onExited: hovered = false
        }
    }
}
