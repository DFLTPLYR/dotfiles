import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Widgets

import QtQuick
import QtQuick.Controls
import QtQuick.Shapes

import qs.utils
import qs.config
import qs.assets
import qs.services
import qs.components

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

    property QtObject mainrect: QtObject {
        property int rounding: 0
        property int padding: 0
        property string color: "background"
    }

    property QtObject backingrect: QtObject {
        property string color: "background"
        property int x: 0
        property int y: 0
        property real opacity: 1
    }

    property QtObject intersection: QtObject {
        property real opacity: 1
        property string color: "background"
        property QtObject border: QtObject {
            property string color: "background"
            property int width: 2
        }
    }

    component Container: StyledRectangle {
        anchors.fill: parent

        // mainrect
        transparency: 1
        rounding: mainrect.rounding
        padding: mainrect.padding
        bgColor: Color.background

        backingVisible: backingrect.visible !== 0 ? true : false
        backingrectX: backingrect.x
        backingrectY: backingrect.y
        backingrectOpacity: backingrect.opacity

        intersectionOpacity: intersection.opacity
        intersectionColor: intersection.color
    }

    function saveSettings() {
        const settings = {
            rounding: root.mainrect.rounding || 0,
            padding: root.mainrect.padding || 0,
            backingrect: {
                color: root.backingrect.color || Color.background,
                x: root.backingrect.x || 0,
                y: root.backingrect.y || 0,
                opacity: root.backingrect.opacity || 0
            },
            intersection: {
                opacity: root.intersection.opacity || 0,
                color: root.intersection.color,
                border: {
                    color: root.intersection.border.color,
                    width: root.intersection.border.width
                }
            }
        };
        settingsWatcher.setText(JSON.stringify(settings, null, 2));
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
                fillColor: Scripts.setOpacity(Color.background, 0.8)

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

    FileView {
        id: settingsWatcher
        path: Qt.resolvedUrl("./config.json")
        watchChanges: true
        onFileChanged: settingsWatcher.reload()
        onAdapterUpdated: writeAdapter()
        JsonAdapter {
            property string contentHandler: "main"
            property StyledConfig mainrectAppearance: StyledConfig {}
            property StyledConfig backingAppearance: StyledConfig {}
            property StyledConfig intersectionAppearance: StyledConfig {}
        }
        onLoadFailed: {
            settingsWatcher.setText("{}");
            writeAdapter();
        }
    }
}
