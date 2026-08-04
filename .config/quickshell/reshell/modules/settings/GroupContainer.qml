pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs.core
import qs.components

Rectangle {
    id: group
    default property alias container: col.data
    property alias label: textLabel.text
    property alias padding: col.padding

    Layout.fillWidth: true
    Layout.preferredHeight: col.implicitHeight
    Layout.margins: 10

    color: Colors.theme.on_primary
    radius: 5

    Column {
        id: col
        anchors.fill: parent
        padding: 10

        Label {
            id: textLabel
            text: ""
            font.pixelSize: 24
        }

        GroupSpacer {}
    }

    Behavior on height {
        NumberAnimation {
            duration: 200
            easing.type: Easing.InOutQuad
        }
    }
}
