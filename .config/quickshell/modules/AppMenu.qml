import QtQuick
import Quickshell
import QtQuick.Shapes
import QtQuick.Controls
import Quickshell.Widgets
import Quickshell.Hyprland
import Quickshell.Wayland

import qs
import qs.services
import qs.modules.components.commons
import qs.modules.components.AppMenu

PopupWindow {
    id: appMenu

    property bool isPortrait: screen.height > screen.width

    anchor.adjustment: PopupAdjustment.Slide
    anchor.window: screenRoot

    implicitHeight: screen.height
    implicitWidth: screen.width

    mask: Region {
        item: playerBackground
    }
    anchor.edges: Edges.Bottom | Edges.Right
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

        width: Math.round(isPortrait ? parentWindow.width / 1.5 : parentWindow.width / 2.5)
        height: Math.round(isPortrait ? parentWindow.width / 2.25 : parentWindow.width / 4)

        x: Math.round(screen.width / 2 - width / 2)
        y: Math.round(screen.height - height + (1 - animProgress) * height)

        color: 'transparent'
        opacity: animProgress

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

        Column {
            id: mainContent
            width: parent.width - 80
            height: parent.height - 20
            anchors.centerIn: parent
            spacing: 10

            property string searchValue: ""

            Rectangle {
                width: Math.round(parent.width)
                height: Math.round(parent.height / 10)
                color: 'transparent'
                radius: 20

                TextField {
                    id: searchField
                    anchors.fill: parent
                    anchors.margins: 5
                    placeholderText: "Search..."
                    text: mainContent.searchValue
                    font.pixelSize: 12
                    font.family: "Ubuntu" // or "Noto Sans", "DejaVu Sans", "Inter", etc.
                    font.weight: Font.DemiBold
                    renderType: Text.NativeRendering
                    color: Colors.color15

                    background: Rectangle {
                        color: Colors.color0
                        radius: parent.parent.radius
                    }

                    onTextChanged: mainContent.searchValue = text
                }
            }

            ClippingRectangle {
                width: Math.round(parent.width)
                height: Math.round(parent.height - 60)
                color: 'transparent'
                topLeftRadius: 5
                topRightRadius: 5
                bottomLeftRadius: 5
                bottomRightRadius: 5

                AppListView {
                    searchText: mainContent.searchValue
                }
            }
        }
    }

    Component.onCompleted: {
        if (this.WlrLayershell != null) {
            this.WlrLayershell.layer = WlrLayer.Overlay;
            this.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive;
        }
    }

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
