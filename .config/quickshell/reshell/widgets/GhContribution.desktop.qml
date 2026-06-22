import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs.components
import qs.core
import qs.types

Wrapper {
    id: wrap

    property: Property {
        property int cell: 10
        property string palette: "primary"
    }

    property var contribs: Services.contributions !== undefined ? Services.contributions : []
    property string today: new Date().toISOString().slice(0, 10)
    function contributionColor(level) {
        switch (level) {
        case 0:
            return Qt.darker(Colors.theme[`${wrap.property.palette}`], 1);
        case 1:
            return Qt.darker(Colors.theme[`${wrap.property.palette}`], 1.2);
        case 2:
            return Qt.darker(Colors.theme[`${wrap.property.palette}`], 1.4);
        case 3:
            return Qt.darker(Colors.theme[`${wrap.property.palette}`], 1.6);
        case 4:
            return Qt.darker(Colors.theme[`${wrap.property.palette}`], 1.8);
        default:
            return Qt.darker(Colors.theme[`${wrap.property.palette}`], 1);
        }
    }

    FlexboxLayout {
        id: layout
        anchors.fill: parent
        direction: FlexboxLayout.Column
        wrap: FlexboxLayout.Wrap
        clip: true
        gap: 5
        Repeater {
            model: contribs
            delegate: Rectangle {
                required property int index
                required property var modelData
                readonly property bool isToday: modelData?.date === wrap.today

                Layout.preferredWidth: wrap.property.cell
                Layout.preferredHeight: wrap.property.cell
                opacity: modelData?.level || 0
                color: contributionColor(modelData?.level || 0)
                border.color: isToday ? Colors.theme.tertiary : "transparent"
                border.width: isToday ? 2 : 0

                Behavior on color {
                    ColorAnimation {
                        duration: 200
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }
    }
}
