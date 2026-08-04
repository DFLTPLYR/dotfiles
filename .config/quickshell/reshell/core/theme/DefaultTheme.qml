pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit
import qs.core

Style {
    themeName: "Default"

    control {
        padding: 6
        background {
            radius: 4
            implicitWidth: 100
            implicitHeight: 36
        }
        indicator {
            implicitWidth: 20
            implicitHeight: 20
            border.width: 1
        }
        handle {
            implicitWidth: 20
            implicitHeight: 20
            radius: 10
        }
    }

    button {
        background {
            implicitWidth: 120
            shadow.opacity: 0.6
            shadow.verticalOffset: 2
            shadow.horizontalOffset: 2
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: Qt.alpha("black", 0.0)
                }
                GradientStop {
                    position: 1.0
                    color: Qt.alpha("black", 0.2)
                }
            }
        }
        pressed.background.scale: 0.95
    }

    slider {
        indicator.implicitWidth: Style.Stretch
        indicator.implicitHeight: 6
        indicator.radius: 3
    }

    CustomTheme {
        name: "Default"
        theme: Theme {
            control {
                text.color: "black"
                text.bold: true
                background.color: Colors.theme.surface
                background.border.color: "black"
                background.border.width: 3
                background.shadow.visible: false
                hovered.background.border.width: 5
            }
            applicationWindow.background.color: Colors.theme.surface
            itemDelegate.hovered.text.color: "white"
            itemDelegate.hovered.background.color: "black"
            itemDelegate.background.border.width: 0
            button.hovered.background.color: "black"
            button.hovered.text.color: "white"
            radioButton.indicator.foreground.color: "white"
            radioButton.checked.indicator.foreground.color: "black"
            switchControl.indicator.foreground.color: "white"
            switchControl.handle.color: "white"
            switchControl.handle.border.color: "black"
            switchControl.handle.border.width: 2
            switchControl.checked.handle.color: "black"
        }
    }
}
