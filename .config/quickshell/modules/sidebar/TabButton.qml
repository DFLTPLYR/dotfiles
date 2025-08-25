import QtQuick
import QtQuick.Layouts

import qs.services
import qs.utils

Rectangle {
    property string label: ""
    property int tabIndex: 0
    property int currentIndex: 0

    color: tabIndex === currentIndex ? Colors.color2 : Colors.color1
    radius: 6
    Layout.fillHeight: true
    Layout.fillWidth: true

    // Column {
    //     anchors.centerIn: parent
    //     Repeater {
    //         model: label.length
    //         Text {
    //             text: label[index]
    //             color: tabIndex === currentIndex ? Colors.color10 : Colors.color12
    //         }
    //     }
    // }

    Text {
        anchors.centerIn: parent
        text: label
        color: tabIndex === currentIndex ? Colors.color10 : Colors.color12
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            container.currentIndex = tabIndex;
        }
    }
}
