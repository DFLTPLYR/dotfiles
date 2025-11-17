import QtQuick

QtObject {
    // generics
    property string color: "green"
    property real radius: 0
    property real opacity: 1.0
    property bool visible: true

    // Behaviour
    property bool clip: false
    property bool antialiasing: true

    // idk what to call this positioning/layout or something something
    property Anchors anchors: Anchors {}
    property Layout layout: Layout {}
}
