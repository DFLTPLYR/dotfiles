import QtQuick
import Quickshell.Io
import qs.components
import qs.core

Wrapper {
    id: wrap

    property bool recording: false

    width: wrap.setSize()
    height: wrap.setSize()

    Button {
        id: button

        enabled: Global.normal
        text: "camcorder"
        anchors.fill: parent
        content.color: Colors.color.primary
        onClicked: proc.running = true

        font {
            family: Components.icon.family
            weight: Components.icon.weight
            styleName: Components.icon.styleName
            pixelSize: parent ? Math.min(parent.width, parent.height) / 3 : 0
        }
    }

    Process {
        id: proc

        command: ["sh", "-c", "slurp"]
        onRunningChanged: {
            print(command);
        }
    }
}
