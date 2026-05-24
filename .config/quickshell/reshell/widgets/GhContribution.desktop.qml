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

    function contributionColor(level) {
        if (level === 0)
            return Colors.palette[`${wrap.property.palette}80`];
        if (level === 1)
            return Colors.palette[`${wrap.property.palette}70`];
        if (level === 2)
            return Colors.palette[`${wrap.property.palette}60`];
        if (level === 3)
            return Colors.palette[`${wrap.property.palette}50`];
        return Colors.palette[`${wrap.property.palette}80`];
    }

    GridLayout {
        anchors.fill: parent
        rows: 7
        columns: 40
        rowSpacing: 2
        columnSpacing: 2

        RowLayout {
            spacing: 2

            Repeater {
                model: 40  // weeks
                delegate: ColumnLayout {
                    spacing: 2

                    // Manually pass the week index
                    property int weekIndex: index

                    Repeater {
                        model: 7  // days
                        delegate: Rectangle {
                            width: wrap.property.cell
                            height: wrap.property.cell
                            radius: 2

                            property int realIndex: weekIndex * 7 + index
                            color: contributionColor(contribs[realIndex]?.level || 0)

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
        }
    }
}
