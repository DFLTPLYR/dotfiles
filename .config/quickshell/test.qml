import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Services.Greetd

import qs.assets

import Qt5Compat.GraphicalEffects

// FloatingWindow {
//     maximumSize: Qt.size(400, 600)
//     minimumSize: Qt.size(200, 300)
//     color: 'transparent'
//     ColumnLayout {
//         anchors.fill: parent
//         Button {
//             Layout.fillWidth: true
//             onClicked: Greetd.createSession("dfltplyr")
//         }
//         Button {
//             Layout.fillWidth: true
//             onClicked: Greetd.cancelSession()
//         }
//         Button {
//             Layout.fillWidth: true
//             onClicked: Greetd.respond("0711")
//         }
//         Button {
//             Layout.fillWidth: true
//             onClicked: {
//                 console.log(GreetdState.toString(Greetd.state));
//             }
//         }
//     }

//     Connections {
//         target: Greetd
//         function onAuthMessage(message, error, responseRequired, echoResponse) {
//             console.log(message, error, responseRequired, echoResponse);
//         }
//         function onReadyToLaunch() {
//             console.log("SYBAU");
//         }
//     }

//     Component.onCompleted: {
//         var obj = Greetd;
//         obj.cancelSession();
//         console.log(GreetdState.toString(obj.state));
//         console.log(obj.user);
//         console.log(obj.available);
//     }
// }
ShellRoot {
    Variants {
        model: Quickshell.screens
        delegate: PanelWindow {
            required property ShellScreen modelData
            screen: modelData
            anchors {
                left: true
                bottom: true
                right: true
                top: true
            }
            color: 'transparent'
            exclusiveZone: ExclusionMode.Ignore
            aboveWindows: false

            Rectangle {
                anchors.fill: parent
                color: 'transparent'
            }
        }
    }
}
