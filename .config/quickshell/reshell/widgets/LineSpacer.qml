import QtQuick
import QtQuick.Layouts
import qs.components
import qs.core
import qs.types

Wrapper {
    id: wrap

    width: wrap.setWidth(property.thickness)
    height: wrap.setHeight(property.thickness)

    Rectangle {
        anchors.fill: parent
        color: property.color
    }

    property: Property {
        property int thickness: 2
        property color color: Colors.color.primary
    }

}
