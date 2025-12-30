import QtQuick 2.15
import QtQuick.Shapes 1.15

Item {
    id: root
    property Item from      // item to start from
    property Item to        // item to end at
    property color color: "red"
    property real strokeWidth: 3
    property real curvature: 0.3   // 0 = straight line, 0.5 = strong curve

    // Internal convenience bindings
    readonly property real startX: from ? from.x + from.width / 2 : 0
    readonly property real startY: from ? from.y + from.height / 2 : 0
    readonly property real endX: to ? to.x + to.width / 2 : 0
    readonly property real endY: to ? to.y + to.height / 2 : 0

    Shape {
        anchors.fill: parent

        ShapePath {
            strokeColor: root.color
            strokeWidth: root.strokeWidth
            fillColor: "transparent"

            Path {
                startX: root.startX
                startY: root.startY

                PathCubic {
                    // Control points based on curvature
                    control1X: root.startX + (root.endX - root.startX) * root.curvature
                    control1Y: root.startY - 150 * root.curvature

                    control2X: root.endX - (root.endX - root.startX) * root.curvature
                    control2Y: root.endY + 150 * root.curvature

                    x: root.endX
                    y: root.endY
                }
            }
        }
    }
}
