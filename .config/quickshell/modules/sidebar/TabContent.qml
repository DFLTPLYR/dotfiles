import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs.services
import qs.utils

StackLayout {
    currentIndex: 1

    ContentWrapper {
        index: 0
        Layout.fillHeight: true
        Layout.fillWidth: true
        Text {
            id: calendar
            text: qsTr("text")
        }
    }
    ContentWrapper {
        index: 1
        Layout.fillHeight: true
        Layout.fillWidth: true

        anchors.leftMargin: 30
        anchors.rightMargin: 30
        RowLayout {
            Layout.fillWidth: true

            TextField {
                id: singleline
                text: "asdasd"
                color: Colors.color13
                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                Layout.margins: 5
                Layout.fillWidth: true
                background: Rectangle {
                    radius: 5
                    implicitHeight: 24
                    border.color: singleline.focus ? Colors.color12 : Colors.color10
                    color: "transparent"
                }
            }

            Text {
                text: qsTr("\uf0fe")
                color: Colors.color12
                font.pixelSize: 24
            }
        }
    }

    opacity: animProgress
}
