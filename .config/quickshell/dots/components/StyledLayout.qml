import QtQuick
import QtQuick.Layouts

Item {
    id: styledLayoutRoot
    property bool isPortrait: false
    property real spacing: layout.spacing

    default property alias content: layout.children

    GridLayout {
        id: layout
        anchors.fill: parent
        flow: styledLayoutRoot.isPortrait ? GridLayout.TopToBottom : GridLayout.LeftToRight
    }
}
