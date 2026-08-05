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
        }
    }
}
