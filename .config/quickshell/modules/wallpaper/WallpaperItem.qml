import QtQuick
import QtQuick.Shapes
import QtQuick.Layouts

import Qt5Compat.GraphicalEffects
import qs.components
import qs.services
import qs.assets
import qs.utils

Rectangle {
    id: wrapper
    required property var modelData
    implicitWidth: flick.width
    height: 250
    radius: 10
    clip: true
    color: Scripts.setOpacity(Assets.foreground, 0.2)
    border.color: Scripts.setOpacity(Assets.colors10, 0.2)

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8

        Rectangle {
            Layout.preferredHeight: parent.height * 0.8
            Layout.fillWidth: true
            color: 'transparent'

            MaskWrapper {
                radius: 8
                anchors.fill: parent
                sourceItem: Image {
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectCrop
                    source: Qt.resolvedUrl(modelData.path)
                    cache: true
                    asynchronous: true
                    smooth: true
                    visible: false
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Text {
                text: qsTr("Tags:")
                color: Assets.color15
            }

            RowLayout {
                id: previewTagsFlow
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 8

                Repeater {
                    id: previewTagsRepeater
                    model: modelData.tags.slice(0, 5)
                    delegate: Text {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        text: qsTr(modelData)
                        color: Assets.color10
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                        font.pixelSize: Math.max(10, Math.floor(parent.height * 0.45))
                    }
                }
            }
        }
    }

    MouseArea {
        z: 10
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            var resolvedIndex = -1;
            if (typeof index !== "undefined") {
                resolvedIndex = index;
            } else if (flick && flick.model && flick.model.values) {
                var arr = flick.model.values;
                for (var i = 0; i < arr.length; ++i) {
                    if (arr[i] === modelData || (arr[i].path && modelData.path && arr[i].path === modelData.path)) {
                        resolvedIndex = i;
                        break;
                    }
                }
            }
            if (resolvedIndex >= 0) {
                flick.currentIndex = resolvedIndex;
            } else {
                if (flick.currentItem && flick.currentItem.modelData === modelData)
                    flick.currentIndex = flick.currentIndex;
            }
        }
    }
}
