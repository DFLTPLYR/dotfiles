pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs.core

Rectangle {
    id: group
    default property alias container: col.data
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
    }

    Behavior on height {
        NumberAnimation {
            duration: 200
            easing.type: Easing.InOutQuad
        }
    }
}
