import QtQuick
import Quickshell
import QtQuick.Shapes
import QtQuick.Controls
import Quickshell.Widgets
import Quickshell.Hyprland

import qs
import qs.services
import qs.modules.components.commons
import qs.modules.components.AppMenu

PopupWindow {
    id: resourceSection

    property bool isPortrait: screen.height > screen.width

    anchor.adjustment: PopupAdjustment.Slide
    anchor.window: screenRoot

    anchor.rect.x: screen.width / 2 - width / 2
    anchor.rect.y: screen.height

    implicitHeight: playerBackground.height
    implicitWidth: playerBackground.width

    mask: Region {
        item: playerBackground
    }

    visible: false

    color: 'transparent'

    property bool shouldBeVisible: false
    property real animProgress: 0.0

    Behavior on animProgress {
        NumberAnimation {
            duration: 400
            easing.type: Easing.InOutQuad
        }
    }

    onAnimProgressChanged: {
        if (animProgress > 0 && !visible)
            visible = true;
        if (!shouldBeVisible && Math.abs(animProgress) < 0.001) {
            visible = false;
            const drawerKey = `AppMenu-${screen.name}`;
            GlobalState.removeDrawer(drawerKey);
        }
    }

    ClippingRectangle {
        id: playerBackground
        width: isPortrait ? parentWindow.width / 1.5 : parentWindow.width / 2.5
        height: isPortrait ? parentWindow.width / 2.25 : parentWindow.width / 4

        color: 'transparent'
        opacity: animProgress

        y: 500 + animProgress * -500

        scale: animProgress
        transformOrigin: Item.Center

        Shape {
            anchors.fill: parent
            scale: -1 * animProgress
            ShapePath {
                id: root

                // All values defined locally
                readonly property real rounding: 30
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
            width: parent.width - 80
            height: parent.height - 20
            anchors.centerIn: parent
            spacing: 0

            ClippingRectangle {
                anchors.fill: parent
                color: 'transparent'
                topLeftRadius: 20
                topRightRadius: 20
                bottomLeftRadius: 20
                bottomRightRadius: 20

                ListContent {}
            }
        }
    }

    // MouseArea {
    //     anchors.fill: parent
    //     onClicked: {
    //         GlobalState.toggleDrawer("appMenu");
    //     }
    //     hoverEnabled: true
    // }

    Connections {
        target: GlobalState
        function onShowAppMenuChangedSignal(value, monitorName) {
            if (monitorName === parentWindow.screen.name) {
                shouldBeVisible = value;
                animProgress = value ? 1 : 0;
            } else {
                if (shouldBeVisible) {
                    shouldBeVisible = false;
                    animProgress = 0;
                }
            }
        }
    }
}
