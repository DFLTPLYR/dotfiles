import QtQuick
import qs.core

Text {
    font.family: Components.icon.family
    font.weight: Components.icon.weight
    font.styleName: Components.icon.styleName
    font.pixelSize: parent ? Math.min(parent.width, parent.height) / 3 : 0
}
