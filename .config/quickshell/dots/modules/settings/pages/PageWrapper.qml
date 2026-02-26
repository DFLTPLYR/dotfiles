import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

ScrollView {
    default property alias contentLayout: contentLayout.data
    Layout.fillHeight: true
    Layout.fillWidth: true
    contentWidth: width
    clip: true

    ColumnLayout {
        id: contentLayout
        anchors {
            fill: parent
            rightMargin: 8
        }
    }
}
