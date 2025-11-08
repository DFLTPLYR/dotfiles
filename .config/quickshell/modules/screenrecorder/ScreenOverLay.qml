import QtQuick
import QtQuick.Controls

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

import qs.components
import qs.assets
import qs.utils

Scope {
    id: root
    property bool isVisible: false

    GlobalShortcut {
        name: "showScreenOverLay"
        description: "Show the Custom OSD something idk still"
        onPressed: {
            root.isVisible = !root.isVisible;
        }
    }

    GlobalShortcut {
        name: "saveReplay"
        description: "save replay idk isnt this self explanatory"
        onPressed: {
            recorderProcess.running = true;
        }
    }

    Loader {
        id: overLayLoader
        active: root.isVisible
        sourceComponent: OverLayComponent {}
    }

    Process {
        id: recorderProcess
        command: ["sh", "-c", "killall -SIGUSR1 gpu-screen-recorder"]
    }

    Process {
        id: recorderStatus
        command: ["zsh", "-c", "~/.config/quickshell/modules/screenrecorder/StartReplay.zsh"]
    }

    component OverLayComponent: PanelWindow {
        id: screenOSD

        color: Scripts.setOpacity(ColorPalette.background, 0.4)

        anchors {
            top: true
            bottom: true
            right: true
            left: true
        }

        PopupWindow {
            anchor.window: screenOSD

            anchor.rect.x: parentWindow.width
            anchor.rect.y: -parentWindow.height

            implicitWidth: 300
            implicitHeight: 400

            visible: true
            color: 'transparent'

            StyledRectangle {
                anchors.fill: parent
                bgColor: ColorPalette.background
                transparency: 1
                rounding: 0
                padding: 5

                backingVisible: true
                backingrectX: 0
                backingrectY: 0
                backingrectOpacity: 1

                intersectionOpacity: 1
                intersectionPadding: 0
                intersectionColor: ColorPalette.accent
            }
        }

        Component.onCompleted: {
            if (this.WlrLayershell) {
                this.WlrLayershell.layer = WlrLayer.Overlay;
                this.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive;
                this.exclusionMode = ExclusionMode.Ignore;
            }
        }
    }

    Component.onCompleted: {
        recorderStatus.running = true;
    }
}
