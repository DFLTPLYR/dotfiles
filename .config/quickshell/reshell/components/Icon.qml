import QtQuick
import qs.core

Text {
    font.family: Global.icon.family
    font.weight: Global.icon.weight
    font.styleName: Global.icon.styleName
    font.pixelSize: parent ? Math.min(parent.width, parent.height) / 3 : 0
}
