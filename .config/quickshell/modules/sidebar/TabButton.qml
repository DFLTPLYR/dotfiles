import QtQuick
import QtQuick.Layouts

Rectangle {
    property string label: ""
    property int tabIndex: 0
    property int currentIndex: 0

    color: tabIndex === currentIndex ? "#448aff" : "teal"
    radius: 6
    Layout.fillHeight: true
    Layout.fillWidth: true

    Text {
        anchors.centerIn: parent
        text: label
        color: tabIndex === currentIndex ? "white" : "#eee"
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            container.currentIndex = tabIndex;
        }
    }
}
