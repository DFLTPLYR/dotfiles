pragma ComponentBehavior: Bound

import QtQuick

QtObject {
    id: root
    property string color: "background"
    property Direction rounding: Direction {
        left: 0
        right: 0
        top: 0
        bottom: 0
    }
    property Direction padding: Direction {
        left: 0
        right: 0
        top: 0
        bottom: 0
    }
}
