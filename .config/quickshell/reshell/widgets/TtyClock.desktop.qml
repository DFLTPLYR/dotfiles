import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets

import qs.components
import qs.core
import qs.types

Wrapper {
    id: wrap

    property: Property {
        property int size: 20
        property string color: "primary"
    }

    RowLayout {
        id: row
        readonly property var pattern: [[1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1,], [0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1,], [1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1,], [1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1,], [1, 0, 1, 1, 0, 1, 1, 1, 1, 0, 0, 1, 0, 0, 1,], [1, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 1,], [1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 1, 1, 1, 1,], [1, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1,], [1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1,], [1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1,], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0,],]

        spacing: 12

        Repeater {
            model: Qt.formatDateTime(Global.clock.date, "hh:mm")

            delegate: GridLayout {
                id: digit

                required property string modelData

                columns: 3
                columnSpacing: 0
                rowSpacing: 0

                Repeater {
                    model: 15

                    delegate: Rectangle {
                        required property int modelData

                        width: wrap.property.size
                        height: wrap.property.size
                        color: {
                            const p = digit.modelData === ':' ? 10 : Number(digit.modelData);
                            return row.pattern[p][modelData] === 1 ? Colors.theme[wrap.property.color] : 'transparent';
                        }
                    }
                }
            }
        }
    }
}
