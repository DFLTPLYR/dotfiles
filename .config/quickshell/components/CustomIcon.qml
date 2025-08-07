// CustomIcon.qml
import QtQuick
import qs.assets

Text {
    id: icon

    // Custom properties
    property string name: "\uf04b"
    property int size: 24
    property color iconColor: "white"

    text: name
    font.family: Font.fontAwesomeRegular
    font.pixelSize: size
    color: iconColor
}
