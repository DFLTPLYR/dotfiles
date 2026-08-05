pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit
import qs.core

Style {
    themeName: "Default"

    CustomTheme {
        name: "Default"
        theme: Theme {

            // app window
            applicationWindow {
                background.color: Colors.theme.surface

                transition: Transition {
                    StyleAnimation {
                        animateBackgroundColors: true
                        easing.type: Easing.OutQuad
                        duration: 500
                    }
                }
            }

            button {
                background {
                    implicitWidth: 120
                    implicitHeight: 40
                    shadow {
                        opacity: 0.6
                        color: "gray"
                        verticalOffset: 2
                        horizontalOffset: 2
                    }
                    color: "cornflowerblue"
                    gradient: Gradient {
                        // The gradient is drawn on top of the 'background.color', so
                        // we use semi-transparent stops to give the button some shading
                        // while letting the base color show through. This makes it easier
                        // to change the color, but keep the shading, in the hovered state below.
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
                text.color: "white"
                hovered.background.color: "royalblue"
                pressed.background.scale: 0.95
            }
        }
    }
}
