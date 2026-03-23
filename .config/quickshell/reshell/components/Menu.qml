import QtQuick
import QtQuick.Controls.Basic

import qs.core

Menu {
    id: menu

    topPadding: 2
    bottomPadding: 2

    background: Rectangle {
        implicitWidth: 100
        implicitHeight: 40
        color: Colors.setOpacity(Colors.color.background, 0.8)
        border.color: Colors.color.outline
        radius: 2
    }
}
