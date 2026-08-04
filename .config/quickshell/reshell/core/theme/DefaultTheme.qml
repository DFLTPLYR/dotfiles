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
            applicationWindow.background.color: Colors.theme.surface

            // Button
            button {
                background {
                    implicitWidth: 120
                    implicitHeight: 40
                    color: Colors.theme.primary
                }
                text.color: Colors.theme.on_primary
                hovered.background.color: Colors.theme.primary
                pressed.background.scale: 0.95
            }
        }
    }
}
