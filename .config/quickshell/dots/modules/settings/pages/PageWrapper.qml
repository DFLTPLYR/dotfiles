import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

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
