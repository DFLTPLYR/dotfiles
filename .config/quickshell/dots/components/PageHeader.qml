import QtQuick
import QtQuick.Layouts

import qs.config

Item {
    property alias title: titleText.text
    Layout.fillWidth: true
    Layout.preferredHeight: 40
    Text {
        id: titleText
        anchors.centerIn: parent
        color: Colors.color.primary
    }
}
