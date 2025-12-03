import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

import QtQuick
import QtQuick.Layouts
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
                    return Math.round((parentWindow.width - width) * (Config.navbar.popup.x / 100));
                }
            }

            y: {
                if (Config.navbar.position === "top") {
                    return parentWindow.height;
                } else if (Config.navbar.position === "bottom") {
                    return -parentWindow.height + parentWindow.height;
                } else {
                    return Math.round((parentWindow.height - height) * Config.navbar.popup.y / 100);
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
            let percent = Math.max(10, Math.min(Config.navbar.popup.width, 100)) / 100;
            let baseWidth = isPortrait ? parentWindow.screen.width * percent * 1.5 : parentWindow.screen.width * percent;
            return Math.min(Math.floor(baseWidth), parentWindow.screen.width);
        }

        height: {
            let percent = Math.max(10, Math.min(Config.navbar.popup.height, 100)) / 100;
            if (isPortrait) {
                return Math.floor(parentWindow.screen.height * percent / 2);
            } else {
                return Math.floor(parentWindow.screen.height * percent);
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
            if (Config.navbar.position === "left") {
                return -parentWindow.screen.width + animProgress * parentWindow.screen.width;
            } else if (Config.navbar.position === "right") {
                return +parentWindow.screen.width + animProgress * -parentWindow.screen.width;
            } else {
                return 0;
            }
        }

        StyledRect {
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
                right: parent.right
                margins: 10
            }
            GridLayout {
              anchors.fill: parent
              columns: 1
              rows: 1
            }
        }

        opacity: animProgress

        scale: animProgress
    }
}
