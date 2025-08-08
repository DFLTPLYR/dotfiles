import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Shapes

import qs
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
        width: Math.floor(isPortrait ? parentWindow.width / 1.5 : parentWindow.width / 2)
        height: Math.floor(isPortrait ? parentWindow.width / 2.25 : parentWindow.width / 4)

        color: 'transparent'
        opacity: animProgress

        // bottomLeftRadius: 100
        // bottomRightRadius: 100
        y: -500 + animProgress * 500

        scale: animProgress
        transformOrigin: Item.Center

        Shape {
            anchors.fill: parent
            scale: animProgress
            ShapePath {
                id: root

                // All values defined locally
                readonly property real rounding: 40
                readonly property bool flatten: playerBackground.height < rounding * 2
                readonly property real roundingY: flatten ? playerBackground.height / 2 : rounding

                strokeWidth: -1
                fillColor: Colors.background

                // Top-left outward arc
                PathArc {
                    relativeX: root.rounding
                    relativeY: root.roundingY
                    radiusX: root.rounding
                    radiusY: root.roundingY
                }

                PathLine {
                    relativeX: 0
                    relativeY: playerBackground.height - root.roundingY * 2
                }

                // Bottom-left outward arc
                PathArc {
                    relativeX: root.rounding
                    relativeY: root.roundingY
                    radiusX: root.rounding
                    radiusY: root.roundingY
                    direction: PathArc.Counterclockwise
                }

                PathLine {
                    relativeX: playerBackground.width - root.rounding * 4
                    relativeY: 0
                }

                // Bottom-right outward arc
                PathArc {
                    relativeX: root.rounding
                    relativeY: -root.roundingY
                    radiusX: root.rounding
                    radiusY: root.roundingY
                    direction: PathArc.Counterclockwise
                }

                PathLine {
                    relativeX: 0
                    relativeY: -(playerBackground.height - root.roundingY * 2)
                }

                // Top-right outward arc
                PathArc {
                    relativeX: root.rounding
                    relativeY: -root.roundingY
                    radiusX: root.rounding
                    radiusY: root.roundingY
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
            width: Math.floor(parent.width - 120)
            height: Math.floor(parent.height - 40)
            anchors.centerIn: parent
            spacing: 0

            ClippingRectangle {
                color: 'transparent'

                width: Math.floor(mainContent.width * 0.55)
                height: Math.floor(mainContent.height)

                MainContent {}
            }

            ClippingRectangle {
                id: testing
                color: 'transparent'
                width: Math.floor(mainContent.width * 0.45 - 40)
                height: Math.floor(mainContent.height)

                SystemStats {}
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
