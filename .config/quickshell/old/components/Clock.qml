import QtQuick
import Quickshell

import qs.config
import qs.utils
import qs.assets
import qs.services

Item {
    id: root
    property bool isSlotted: false
    width: (Navbar.config.side && root.isSlotted && loader) ? (parent ? parent.width : 0) : loader.implicitWidth
    height: (Navbar.config.side && root.isSlotted && loader) ? loader.implicitHeight : (parent ? parent.height : 0)

    Loader {
        id: loader
        width: parent.width
        height: parent.height
        sourceComponent: Navbar.config.side ? portrait : landscape
    }

    Component {
        id: portrait
        Column {
            Text {
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: Qt.formatDateTime(TimeService.clock.date, "HH mm AP")
                color: Color.color2
                width: parent.width
                font {
                    pixelSize: parent.width * 0.8
                }
                style: Text.Outline
                styleColor: Color.color15
                wrapMode: Text.WordWrap
            }
        }
    }

    Component {
        id: landscape
        Row {
            Text {
                text: Qt.formatDateTime(TimeService.clock.date, "hh:mm AP")
                color: Color.color14
                font {
                    pixelSize: Math.max(10, Math.min(parent.width, parent.height))
                }
            }
        }
    }
}
