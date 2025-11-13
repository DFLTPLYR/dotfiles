import QtQuick

QtObject {
    // Sizing
    property real minimumWidth: -1
    property real minimumHeight: -1
    property real preferredWidth: -1
    property real preferredHeight: -1
    property real maximumWidth: -1
    property real maximumHeight: -1

    // Fill behavior
    property bool fillWidth: false
    property bool fillHeight: false

    // Alignment
    property int alignment: Qt.AlignLeft | Qt.AlignTop

    // Margins
    property real leftMargin: 0
    property real rightMargin: 0
    property real topMargin: 0
    property real bottomMargin: 0
}
