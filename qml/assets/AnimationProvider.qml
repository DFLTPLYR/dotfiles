pragma Singleton
import QtQuick
import Quickshell.Io

Item {
    component ColorAnim: ColorAnimation {
        duration: 300
        easing.type: Easing.InOutQuad
    }
    component NumberAnim: NumberAnimation {
        duration: 500
        easing.type: Easing.InOutQuad
    }
}
