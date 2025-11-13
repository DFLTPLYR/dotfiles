import QtQuick

QtObject {
    id: root
    // anchor position
    property Item fill
    property Item left
    property Item right
    property Item bottom
    property Item top
    property Item horizontalCenter
    property Item verticalCenter
    property Item centerIn

    // Padding
    property real margins: 0
    property real leftMargin: 0
    property real rightMargin: 0
    property real topMargin: 0
    property real bottomMargin: 0
}
