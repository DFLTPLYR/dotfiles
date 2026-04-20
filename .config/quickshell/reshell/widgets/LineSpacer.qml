import QtQuick
import QtQuick.Layouts

import qs.core
import qs.types
import qs.components

Wrapper {
    id: wrap
    property: Property {
        property int thickness: 2
        property color color: Colors.color.primary
    }

    width: wrap.setWidth(property.thickness)
    height: wrap.setHeight(property.thickness)

    Rectangle {
        anchors.fill: parent
        color: property.color
    }
}
