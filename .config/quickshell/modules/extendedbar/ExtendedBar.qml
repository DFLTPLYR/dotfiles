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


        adjustment: PopupAdjustment.All

        rect {
            x: {
                if (Config.navbar.position === "right") {
                  return -parentWindow.width + parentWindow.width;
                } else if (Config.navbar.position === "left") {
                  return parentWindow.width;
                } else {
                    return Math.round(parentWindow.width * Config.navbar.popup.x / 100 - width / 2);
                }
            }

            y: {
                if (Config.navbar.position === "top") {
                    return parentWindow.height;
                } else if (Config.navbar.position === "bottom") {
                    return -parentWindow.height + parentWindow.height;
                } else {
                    return Math.round(parentWindow.height * Config.navbar.popup.y / 100 - height / 2);
                }
            }
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

    Item {
        id: extendedBarContainer

        width: {
          if(!Config.navbar.side) {
            return 400
          } else {
            return parentWindow.screen.width - parentWindow.width
          }
        }
        height: {
          if(Config.navbar.side) {
            return 400
          } else {
            return  parentWindow.screen.height - parentWindow.height
          }
        }

        y: {
            if (Config.navbar.position === "top") {
                return -parentWindow.screen.height + animProgress * parentWindow.screen.height;
            } else if (Config.navbar.position === "bottom") {
                return +parentWindow.screen.height + animProgress * -parentWindow.screen.height;
            } else {
                return 0;
            }
          }

          x: {
            if(Config.navbar.position === "left") {
              return -parentWindow.screen.width + animProgress * parentWindow.screen.width;
            } else if (Config.navbar.position === "right") {
              return +parentWindow.screen.width + animProgress * -parentWindow.screen.width;
            } else {
              return 0;
            }
          }

          StyledRect {
            anchors.fill: parent
        }
  
        opacity: animProgress

    

        scale: animProgress

        // Shape {
        //     anchors.fill: parent
        //     scale: animProgress
        //
        //     ShapePath {
        //         id: shapeBackground
        //         readonly property real rounding: 10
        //         readonly property bool flatten: extendedBarContainer.height < rounding * 2
        //         readonly property real roundingY: flatten ? extendedBarContainer.height / 2 : rounding
        //
        //         strokeWidth: -1
        //         fillColor: Scripts.setOpacity(Color.background, 0.8)
        //
        //         // Top-left outward arc
        //         PathArc {
        //             relativeX: shapeBackground.rounding
        //             relativeY: shapeBackground.roundingY
        //             radiusX: shapeBackground.rounding
        //             radiusY: shapeBackground.roundingY
        //         }
        //
        //         PathLine {
        //             relativeX: 0
        //             relativeY: extendedBarContainer.height - shapeBackground.roundingY * 2
        //         }
        //
        //         // Bottom-left outward arc
        //         PathArc {
        //             relativeX: shapeBackground.rounding
        //             relativeY: shapeBackground.roundingY
        //             radiusX: shapeBackground.rounding
        //             radiusY: shapeBackground.roundingY
        //             direction: PathArc.Counterclockwise
        //         }
        //
        //         PathLine {
        //             relativeX: extendedBarContainer.width - shapeBackground.rounding * 4
        //             relativeY: 0
        //         }
        //
        //         // Bottom-right outward arc
        //         PathArc {
        //             relativeX: shapeBackground.rounding
        //             relativeY: -shapeBackground.roundingY
        //             radiusX: shapeBackground.rounding
        //             radiusY: shapeBackground.roundingY
        //             direction: PathArc.Counterclockwise
        //         }
        //
        //         PathLine {
        //             relativeX: 0
        //             relativeY: -(extendedBarContainer.height - shapeBackground.roundingY * 2)
        //         }
        //
        //         // Top-right outward arc
        //         PathArc {
        //             relativeX: shapeBackground.rounding
        //             relativeY: -shapeBackground.roundingY
        //             radiusX: shapeBackground.rounding
        //             radiusY: shapeBackground.roundingY
        //         }
        //
        //         Behavior on fillColor {
        //             ColorAnimation {
        //                 duration: 250
        //                 easing.type: Easing.InOutQuad
        //             }
        //         }
        //     }
        // }
        //
        // Row {
        //     id: mainContent
        //     width: Math.floor(parent.width - (shapeBackground.rounding * 3))
        //     height: Math.floor(parent.height - shapeBackground.rounding)
        //     anchors.centerIn: parent
        //     spacing: 0
        //
        //     Rectangle {
        //         color: 'transparent'
        //
        //         width: Math.floor(mainContent.width)
        //         height: Math.floor(mainContent.height)
        //
        //         ContainerBar {}
        //     }
        // }
    }
}
