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

    property RectProperties mainrect: RectProperties {
        color: "background"
        padding {
            left: 0
            right: 0
            bottom: 0
            top: 0
        }
        rounding {
            left: 0
            right: 0
            bottom: 0
            top: 0
        }
    }

    property RectProperties backingrectconf: RectProperties {
        color: "background"
        padding {
            left: 0
            right: 0
            bottom: 0
            top: 0
        }
        rounding {
            left: 0
            right: 0
            bottom: 0
            top: 0
        }
    }

    property QtObject backingrect: QtObject {
        property bool enabled: true
        property string color: "background"
        property int x: 0
        property int y: 0
        property real opacity: 1
    }

    property QtObject intersection: QtObject {
        property bool enabled: true
        property real opacity: 1
        property string color: "background"
        property QtObject border: QtObject {
            property string color: "background"
            property int width: 2
        }
    }

    FileView {
        id: settingsWatcher
        path: Qt.resolvedUrl("./config.json")
        watchChanges: true
        onFileChanged: settingsWatcher.reload()
        onLoaded: {
            const settings = JSON.parse(settingsWatcher.text());
            // main rect conf
            root.mainrect.color = settings.mainrect.color || root.mainrect.color;

            root.mainrect.padding.left = settings.mainrect.padding.left;
            root.mainrect.padding.right = settings.mainrect.padding.right;
            root.mainrect.padding.top = settings.mainrect.padding.top;
            root.mainrect.padding.bottom = settings.mainrect.padding.bottom;

            root.mainrect.rounding.left = settings.mainrect.rounding.left;
            root.mainrect.rounding.right = settings.mainrect.rounding.right;
            root.mainrect.rounding.top = settings.mainrect.rounding.top;
            root.mainrect.rounding.bottom = settings.mainrect.rounding.bottom;

            // Assign backingrect properties
            root.backingrect.enabled = settings.backingrect?.enabled || root.backingrect.enabled;
            root.backingrect.color = settings.backingrect?.color || root.backingrect.color;
            root.backingrect.x = settings.backingrect?.x || root.backingrect.x;
            root.backingrect.y = settings.backingrect?.y || root.backingrect.y;
            root.backingrect.opacity = settings.backingrect?.opacity || root.backingrect.opacity;

            // Assign intersection properties
            root.intersection.enabled = settings.intersection?.enabled || root.intersection.enabled;
            root.intersection.opacity = settings.intersection?.opacity || root.intersection.opacity;
            root.intersection.color = settings.intersection?.color || root.intersection.color;
            root.intersection.border.color = settings.intersection?.border?.color || root.intersection.border.color;
            root.intersection.border.width = settings.intersection?.border?.width || root.intersection.border.width;
        }
        onLoadFailed: root.saveSettings()
    }

    function saveSettings() {
        const settings = {
            // mainrect
            mainrect: {
                color: root.mainrect.color,
                rounding: {
                    left: root.mainrect.rounding.left,
                    right: root.mainrect.rounding.right,
                    top: root.mainrect.rounding.top,
                    bottom: root.mainrect.rounding.bottom
                },
                padding: {
                    left: root.mainrect.padding.left,
                    right: root.mainrect.padding.right,
                    top: root.mainrect.padding.top,
                    bottom: root.mainrect.padding.bottom
                }
            },
            // backingrect
            backingrect: {
                enabled: root.backingrect.enabled,
                color: root.backingrect.color,
                x: root.backingrect.x,
                y: root.backingrect.y,
                opacity: root.backingrect.opacity,
                rounding: {
                    left: root.mainrect.rounding.left,
                    right: root.mainrect.rounding.right,
                    top: root.mainrect.rounding.top,
                    bottom: root.mainrect.rounding.bottom
                },
                padding: {
                    left: root.mainrect.padding.left,
                    right: root.mainrect.padding.right,
                    top: root.mainrect.padding.top,
                    bottom: root.mainrect.padding.bottom
                }
            },
            //container rect
            intersection: {
                enabled: root.intersection.enabled,
                opacity: root.intersection.opacity,
                color: root.intersection.color,
                border: {
                    color: root.intersection.border.color,
                    width: root.intersection.border.width
                },
                rounding: {
                    left: root.mainrect.rounding.left,
                    right: root.mainrect.rounding.right,
                    top: root.mainrect.rounding.top,
                    bottom: root.mainrect.rounding.bottom
                },
                padding: {
                    left: root.mainrect.padding.left,
                    right: root.mainrect.padding.right,
                    top: root.mainrect.padding.top,
                    bottom: root.mainrect.padding.bottom
                }
            }
        };
        settingsWatcher.setText(JSON.stringify(settings, null, 2));
    }

    // component Container: StyledRectangle {
    //     anchors.fill: parent
    //
    //     // mainrect
    //     transparency: 1
    //
    //     bgColor: root.mainrect.color
    //
    //     paddingLeft: 10
    //     paddingRight: 10
    //     paddingTop: 10
    //     paddingBottom: 10
    //
    //     roundingTopLeft: 10
    //     roundingTopRight: 10
    //     roundingBottomLeft: 10
    //     roundingBottomRight: 10
    //
    //     backingVisible: backingrect.enabled
    //     backingrectX: backingrect.x
    //     backingrectY: backingrect.y
    //     backingrectOpacity: backingrect.opacity
    //
    //     intersectionOpacity: intersection.opacity
    //     intersectionColor: intersection.color
    // }
    //
    // Item {
    //     id: extendedBarContainer
    //     width: Math.floor(isPortrait ? parentWindow.width : parentWindow.width / 1.75)
    //     height: Math.floor(isPortrait ? parentWindow.width / 2 : parentWindow.width / 4)
    //     Container {
    //         opacity: animProgress
    //     }
    // }
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
