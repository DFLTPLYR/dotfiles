import QtQuick
import QtQuick.Layouts
import qs.services
import qs.components
import qs.assets
import qs.utils
import qs

Rectangle {
    id: root
    radius: 10
    Layout.fillWidth: true
    Layout.fillHeight: true
    color: Scripts.setOpacity(Assets.color0, 0.5)

    // Properties for customization
    property string headerIcon: "\ue322" // Default icon
    property string headerText: "Default Title"
    property alias headerItem: headerContent // Allow access to the header for custom content
    property alias contentItem: contentArea // Allow access to the content area for custom content

    // Data properties (with bindings to be set by parent)
    property string usageLabel: "Usage"
    property string usageValue: "0%"
    property real usagePercent: 0.0 // 0.0 to 1.0 scale
    property string minValue: "0%"
    property string maxValue: "100%"

    property bool isTempVisible: false

    property string tempLabel: "Temperature"
    property string tempValue: "N/A"

    property bool isFrequencyVisible: false
    property string freqLabel: "Frequency"
    property string freqValue: "N/A"

    Item {
        anchors.fill: parent

        // Header section
        Rectangle {
            id: headerContent
            color: "transparent"
            width: parent.width
            height: Math.round(parent.height * 0.3)
            anchors.top: parent.top

            RowLayout {
                anchors.centerIn: parent
                width: Math.round(parent.width)
                anchors.margins: 100
                Text {
                    text: root.headerIcon
                    color: Assets.color14
                    font.family: FontAssets.fontMaterialRounded
                    font.pixelSize: 32
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                Text {
                    text: root.headerText
                    color: Assets.color14
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                    font.family: FontAssets.fontSometypeMono
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 24
                }
            }
        }

        // Content area with metrics
        Column {
            id: contentArea
            anchors.top: headerContent.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10
            spacing: 10

            // Usage row
            RowLayout {
                width: Math.round(parent.width)

                Text {
                    text: root.usageLabel
                    color: Assets.color14
                    font.family: FontAssets.fontSometypeMono
                    font.pixelSize: 12
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignLeft
                }

                Text {
                    text: root.usageValue
                    color: Assets.color14
                    wrapMode: Text.Wrap
                    font.family: FontAssets.fontSometypeMono
                    font.pixelSize: 12
                    Layout.alignment: Qt.AlignRight
                }
            }

            // Progress bar
            Rectangle {
                width: parent.width
                height: 8
                radius: 10
                color: "transparent"
                border.color: Assets.color14
                border.width: 1

                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.margins: 1
                    width: Math.max(0, Math.min(parent.width - 2, (parent.width - 2) * root.usagePercent))
                    radius: 8
                    color: Assets.color14
                }
            }

            // Min/Max values
            RowLayout {
                width: Math.round(parent.width)

                Text {
                    text: root.minValue
                    color: Assets.color14
                    font.family: FontAssets.fontSometypeMono
                    font.pixelSize: 12
                    font.bold: true
                    Layout.alignment: Qt.AlignLeft
                }

                Text {
                    text: "/"
                    color: Assets.color14
                    font.family: FontAssets.fontSometypeMono
                    font.pixelSize: 12
                    Layout.alignment: Qt.AlignCenter
                }

                Text {
                    text: root.maxValue
                    color: Assets.color14
                    wrapMode: Text.Wrap
                    font.family: FontAssets.fontSometypeMono
                    font.bold: true
                    font.pixelSize: 12
                    Layout.alignment: Qt.AlignRight
                }
            }

            // Temperature row
            RowLayout {
                width: Math.round(parent.width)
                visible: root.isTempVisible
                Text {
                    text: "\ue1ff"
                    color: Assets.color14
                    font.family: FontAssets.fontMaterialRounded
                    font.pixelSize: 12
                    Layout.alignment: Qt.AlignLeft
                }

                Text {
                    text: root.tempLabel
                    color: Assets.color14
                    font.family: FontAssets.fontSometypeMono
                    font.pixelSize: 12
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignCenter
                }

                Text {
                    text: root.tempValue
                    color: Assets.color14
                    wrapMode: Text.Wrap
                    font.family: FontAssets.fontSometypeMono
                    font.pixelSize: 12
                    font.bold: true
                    Layout.alignment: Qt.AlignRight
                }
            }

            // Frequency row
            RowLayout {
                width: Math.round(parent.width)
                visible: root.isFrequencyVisible
                Text {
                    text: root.freqLabel
                    color: Assets.color14
                    font.family: FontAssets.fontSometypeMono
                    font.pixelSize: 12
                    Layout.alignment: Qt.AlignLeft
                }

                Text {
                    text: root.freqValue
                    color: Assets.color14
                    wrapMode: Text.Wrap
                    font.family: FontAssets.fontSometypeMono
                    font.bold: true
                    font.pixelSize: 12
                    Layout.alignment: Qt.AlignRight
                }
            }
        }
    }
}
