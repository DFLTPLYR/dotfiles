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

            ListView {
                id: upperListView
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height * 0.10
                orientation: ListView.Horizontal
                model: modelData.colors.slice(0, 9)

                delegate: Rectangle {
                    width: upperListView.width / 8
                    height: upperListView.height

                    color: Scripts.hexToRgba(modelData.color, 0.8)
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

            ListView {
                id: bottomListView
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height * 0.10
                orientation: ListView.Horizontal
                model: modelData.colors.slice(10, 18)

                delegate: Rectangle {
                    width: bottomListView.width / 8
                    height: bottomListView.height
                    color: Scripts.hexToRgba(modelData.color, 0.8)
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
