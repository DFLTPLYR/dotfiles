import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Widgets

import QtQuick
import QtQuick.Controls
import QtQuick.Shapes

import qs
import qs.utils
import qs.services
import qs.assets
import qs.components
import qs.config

PopupWindow {
    id: root

    property bool shouldBeVisible: false
    property real animProgress: 0.0
    property bool isPortrait: screen.height > screen.width
    signal hide

    implicitHeight: Math.floor(extendedBarContainer.height)
    implicitWidth: Math.floor(extendedBarContainer.width)

    visible: false
    color: 'transparent'

    mask: Region {
        item: extendedBarContainer
    }

    anchor {
        adjustment: PopupAdjustment.Slide
        rect {
            x: Math.round(parentWindow.width / 2 - width / 2)
            y: Math.round(parentWindow.height)
        }
    }

    Behavior on animProgress {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }

    onAnimProgressChanged: {
        if (animProgress > 0 && !visible)
            visible = true;
        if (!shouldBeVisible && Math.abs(animProgress) < 0.001) {
            visible = false;
            root.hide();
        }
    }
          Rectangle {
        id: extendedBarContainer

        width: Math.floor(isPortrait ? parentWindow.width : parentWindow.width / 1.75)
        height: Math.floor(isPortrait ? parentWindow.width / 2 : parentWindow.width / 4)

        color: 'transparent'
        opacity: animProgress

        y: -500 + animProgress * 500

        scale: animProgress
        transformOrigin: Item.Center

        Shape {
            anchors.fill: parent
            scale: animProgress

            ShapePath {
                id: shapeBackground
                readonly property real rounding: 10
                readonly property bool flatten: extendedBarContainer.height < rounding * 2
                readonly property real roundingY: flatten ? extendedBarContainer.height / 2 : rounding

                strokeWidth: -1
                fillColor: Scripts.setOpacity(ColorPalette.background, 0.8)

                // Top-left outward arc
                PathArc {
                    relativeX: shapeBackground.rounding
                    relativeY: shapeBackground.roundingY
                    radiusX: shapeBackground.rounding
                    radiusY: shapeBackground.roundingY
                }

                PathLine {
                    relativeX: 0
                    relativeY: extendedBarContainer.height - shapeBackground.roundingY * 2
                }

                // Bottom-left outward arc
                PathArc {
                    relativeX: shapeBackground.rounding
                    relativeY: shapeBackground.roundingY
                    radiusX: shapeBackground.rounding
                    radiusY: shapeBackground.roundingY
                    direction: PathArc.Counterclockwise
                }

                PathLine {
                    relativeX: extendedBarContainer.width - shapeBackground.rounding * 4
                    relativeY: 0
                }

                // Bottom-right outward arc
                PathArc {
                    relativeX: shapeBackground.rounding
                    relativeY: -shapeBackground.roundingY
                    radiusX: shapeBackground.rounding
                    radiusY: shapeBackground.roundingY
                    direction: PathArc.Counterclockwise
                }

                PathLine {
                    relativeX: 0
                    relativeY: -(extendedBarContainer.height - shapeBackground.roundingY * 2)
                }

                // Top-right outward arc
                PathArc {
                    relativeX: shapeBackground.rounding
                    relativeY: -shapeBackground.roundingY
                    radiusX: shapeBackground.rounding
                    radiusY: shapeBackground.roundingY
                }

                Behavior on fillColor {
                    ColorAnimation {
                        duration: 250
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }

        Row {
            id: mainContent
            width: Math.floor(parent.width - (shapeBackground.rounding * 3))
            height: Math.floor(parent.height - shapeBackground.rounding)
            anchors.centerIn: parent
            spacing: 0

            Rectangle {
                color: 'transparent'

                width: Math.floor(mainContent.width)
                height: Math.floor(mainContent.height)

                ContainerBar {}
            }
        }
    }
}
