import QtQuick
import QtQuick.Layouts

import qs.components
import qs.core

ColumnLayout {
    id: general
    required property var settings
    property bool side: settings ? (settings.position === "left" || settings.position === "right") : false
    Layout.fillWidth: true
    Layout.fillHeight: true

    Range {}
}
