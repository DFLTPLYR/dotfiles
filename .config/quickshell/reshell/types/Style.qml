import QtQuick
import qs.core

QtObject {
    property color color: Colors.setOpacity(Colors.theme.surface, 0.5)
    property Direction padding: Direction {}
    property Direction inset: Direction {}

    property QtObject background: QtObject {
        property Corner rounding: Corner {}
        property Direction margins: Direction {}
    }
}
