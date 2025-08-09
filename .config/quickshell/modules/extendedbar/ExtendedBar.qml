import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Shapes

import qs
import qs.utils
import qs.services

PopupWindow {
    id: resourceSection

    property bool isPortrait: screen.height > screen.width

    anchor.adjustment: PopupAdjustment.Slide
    anchor.window: screenRoot

    anchor.rect.x: Math.round(parentWindow.width / 2 - width / 2)
    anchor.rect.y: Math.round(parentWindow.height)

    implicitHeight: Math.floor(playerBackground.height)
    implicitWidth: Math.floor(playerBackground.width)

    mask: Region {
        item: playerBackground
    }

    visible: false
    color: 'transparent'
    property bool shouldBeVisible: false
    property real animProgress: 0.0

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
            const drawerKey = `MprisDashboard-${screen.name}`;
            Qt.callLater(() => GlobalState.removeDrawer(drawerKey));
        }
    }

    ClippingRectangle {
        id: playerBackground
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
                readonly property real rounding: 20
                readonly property bool flatten: playerBackground.height < rounding * 2
                readonly property real roundingY: flatten ? playerBackground.height / 2 : rounding

                strokeWidth: -1
                fillColor: Scripts.hexToRgba(Colors.background, 0.8)

                // Top-left outward arc
                PathArc {
                    relativeX: shapeBackground.rounding
                    relativeY: shapeBackground.roundingY
                    radiusX: shapeBackground.rounding
                    radiusY: shapeBackground.roundingY
                }

                PathLine {
                    relativeX: 0
                    relativeY: playerBackground.height - shapeBackground.roundingY * 2
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
                    relativeX: playerBackground.width - shapeBackground.rounding * 4
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
                    relativeY: -(playerBackground.height - shapeBackground.roundingY * 2)
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

            ClippingRectangle {
                color: 'transparent'

                width: Math.floor(mainContent.width)
                height: Math.floor(mainContent.height)

                Dashboard {}
            }
        }
    }

    Connections {
        target: GlobalState
        ignoreUnknownSignals: true

        function onShowMprisChangedSignal(value, monitorName) {
            if (!resourceSection || resourceSection.destroyed)
                return;
            if (monitorName === parentWindow.screen.name) {
                shouldBeVisible = value;
                animProgress = value ? 1 : 0;
            } else if (shouldBeVisible) {
                shouldBeVisible = false;
                animProgress = 0;
            }
        }
    }
}
