import QtQuick

QtObject {
    // generics
    property string color: "transparent"
    property real radius: 0
    property real opacity: 1.0
    property bool visible: true

    // Behaviour
    property bool clip: false
    property bool antialiasing: true

    property Anchors anchors: Anchors {}
    property Layout layout: Layout {}
}
