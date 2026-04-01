import QtQuick
import QtQuick.Layouts

Flickable {
    required property var windowconfig
    Layout.fillWidth: true
    Layout.fillHeight: true

    clip: true
    contentHeight: contentItem.implicitHeight
}
