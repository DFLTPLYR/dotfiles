import QtQuick
import QtQuick.Layouts
import qs.config

StyledRect {
    id: notification

    required property var modelData
    signal action

    color: Qt.rgba(0, 0, 0, 0.8)
    width: parent ? parent.width : 0
    height: 60

    RowLayout {
        anchors.fill: parent

        // icon
        Rectangle {
            visible: modelData.appIcon || modelData.image
            Layout.fillHeight: true
            Layout.preferredWidth: height
            Layout.margins: 2
            color: "transparent"
            clip: true
            Image {
                id: notificationIcon
                height: parent.height
                width: height
                fillMode: Image.PreserveAspectCrop
                source: Qt.resolvedUrl(modelData.image || modelData.appIcon)
            }
        }

        // content
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 2
            spacing: 2
            Text {
                Layout.fillWidth: true
                text: modelData.appName
                font.bold: true
                font.pointSize: 12
                color: "white"
                elide: Text.ElideRight
            }
            Text {
                Layout.fillWidth: true
                text: modelData.summary
                font.pointSize: 10
                color: "white"
                elide: Text.ElideRight
            }
            Text {
                Layout.fillWidth: true
                text: modelData.body
                font.pointSize: 9
                color: "lightgray"
                elide: Text.ElideRight
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            notification.action();
        }
    }
}
