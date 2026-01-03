// CustomIcon.qml
import QtQuick
import qs.config

Text {
    font.family: Config.iconFont.family
    font.weight: Config.iconFont.weight
    font.styleName: Config.iconFont.styleName
    font.pixelSize: parent ? parent.height : 0
}
