import QtQuick
import QtQuick.Layouts

Item {
    required property var settings
    property bool side: settings ? (settings.position === "left" || settings.position === "right") : false
    Layout.fillWidth: true
    Layout.fillHeight: true
}
