import QtQuick
import QtQuick.Layouts
import qs.services
import qs.components
import qs.config
import qs.assets
import qs.utils
import qs

Rectangle {
    id: root
    radius: 10
    Layout.fillWidth: true
    Layout.fillHeight: true
    color: Scripts.setOpacity(Color.color0, 0.5)

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
    property string tempIcon: "\ue1ff"

    property bool isFrequencyVisible: false
    property string freqLabel: "Frequency"
    property string freqValue: "N/A"

    // Extra
    property var extraRows: []
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
                    color: Color.color10
                    font.family: FontProvider.fontMaterialRounded
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: {
                        const minSize = 10;
                        return Math.max(minSize, Math.min(32, parent.width));
                    }
                }

                Text {
                    text: root.headerText
                    color: Color.color10
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                    font.family: FontProvider.fontSometypeMono
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: {
                        const minSize = 10;
                        return Math.max(minSize, Math.min(24, parent.width));
                    }
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
                    color: Color.color10
                    font.family: FontProvider.fontSometypeMono
                    font.pixelSize: {
                        const minSize = 10;
                        const maxWidth = parent.width * 0.5;
                        return Math.max(minSize, Math.min(16, maxWidth / 10));
                    }
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignLeft
                }

                Text {
                    text: root.usageValue
                    color: Color.color10
                    wrapMode: Text.Wrap
                    font.family: FontProvider.fontSometypeMono
                    font.pixelSize: {
                        const minSize = 10;
                        const maxWidth = parent.width * 0.5;
                        return Math.max(minSize, Math.min(16, maxWidth / 10));
                    }
                    Layout.alignment: Qt.AlignRight
                }
            }

            // Progress bar
            Rectangle {
                width: parent.width
                height: 8
                radius: 10
                color: "transparent"
                border.color: Color.color10
                border.width: 1

                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.margins: 1
                    width: Math.max(0, Math.min(parent.width - 2, (parent.width - 2) * root.usagePercent))
                    radius: 8
                    color: Color.color15
                }
            }

            // Min/Max values
            RowLayout {
                width: Math.round(parent.width)

                Text {
                    text: root.minValue
                    color: Color.color10
                    font.family: FontProvider.fontSometypeMono
                    font.pixelSize: {
                        const minSize = 10;
                        const maxWidth = parent.width * 0.5;
                        return Math.max(minSize, Math.min(16, maxWidth / 10));
                    }
                    font.bold: true
                    Layout.alignment: Qt.AlignLeft
                }

                Text {
                    text: "/"
                    color: Color.color10
                    font.family: FontProvider.fontSometypeMono
                    font.pixelSize: {
                        const minSize = 10;
                        const maxWidth = parent.width * 0.5;
                        return Math.max(minSize, Math.min(16, maxWidth / 10));
                    }
                    Layout.alignment: Qt.AlignCenter
                }

                Text {
                    text: root.maxValue
                    color: Color.color10
                    wrapMode: Text.Wrap
                    font.family: FontProvider.fontSometypeMono
                    font.bold: true
                    font.pixelSize: {
                        const minSize = 10;
                        const maxWidth = parent.width * 0.5;
                        return Math.max(minSize, Math.min(16, maxWidth / 10));
                    }
                    Layout.alignment: Qt.AlignRight
                }
            }

            // Temperature row
            RowLayout {
                width: Math.round(parent.width)
                visible: root.isTempVisible
                Text {
                    text: root.tempIcon
                    color: Color.color10
                    font.family: FontProvider.fontMaterialRounded
                    font.pixelSize: {
                        const minSize = 10;
                        const maxWidth = parent.width * 0.5;
                        return Math.max(minSize, Math.min(16, maxWidth / 10));
                    }
                    Layout.alignment: Qt.AlignLeft
                }

                Text {
                    text: root.tempLabel
                    color: Color.color10
                    font.family: FontProvider.fontSometypeMono
                    font.pixelSize: {
                        const minSize = 10;
                        const maxWidth = parent.width * 0.5;
                        return Math.max(minSize, Math.min(16, maxWidth / 10));
                    }
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignCenter
                }

                Text {
                    text: root.tempValue
                    color: Color.color10
                    wrapMode: Text.Wrap
                    font.family: FontProvider.fontSometypeMono
                    font.pixelSize: {
                        const minSize = 10;
                        const maxWidth = parent.width * 0.5;
                        return Math.max(minSize, Math.min(16, maxWidth / 10));
                    }
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
                    color: Color.color10
                    font.family: FontProvider.fontSometypeMono
                    font.pixelSize: {
                        const minSize = 10;
                        const maxWidth = parent.width * 0.5;
                        return Math.max(minSize, Math.min(16, maxWidth / 10));
                    }
                    Layout.alignment: Qt.AlignLeft
                }

                Text {
                    text: root.freqValue
                    color: Color.color10
                    wrapMode: Text.Wrap
                    font.family: FontProvider.fontSometypeMono
                    font.bold: true
                    font.pixelSize: {
                        const minSize = 10;
                        const maxWidth = parent.width * 0.5;
                        return Math.max(minSize, Math.min(16, maxWidth / 10));
                    }
                    Layout.alignment: Qt.AlignRight
                }
            }

            // Extra rows (if any)
            Repeater {
                model: root.extraRows
                RowLayout {
                    width: Math.round(parent.width)

                    Text {
                        text: modelData.icon || ""
                        visible: modelData.icon !== undefined
                        color: Color.color10
                        font.family: FontProvider.fontMaterialRounded
                        font.pixelSize: {
                            const minSize = 10;
                            const maxWidth = parent.width * 0.5;
                            return Math.max(minSize, Math.min(16, maxWidth / 10));
                        }
                        Layout.alignment: Qt.AlignLeft
                    }

                    Text {
                        text: modelData.label
                        color: Color.color10
                        font.family: FontProvider.fontSometypeMono
                        font.pixelSize: {
                            const minSize = 10;
                            const maxWidth = parent.width * 0.5;
                            return Math.max(minSize, Math.min(16, maxWidth / 10));
                        }
                        Layout.fillWidth: true
                        Layout.alignment: modelData.icon !== undefined ? Qt.AlignCenter : Qt.AlignLeft
                    }

                    Text {
                        text: modelData.value
                        color: Color.color10
                        wrapMode: Text.Wrap
                        font.family: FontProvider.fontSometypeMono
                        font.bold: true
                        font.pixelSize: {
                            const minSize = 10;
                            const maxWidth = parent.width * 0.5;
                            return Math.max(minSize, Math.min(16, maxWidth / 10));
                        }
                        Layout.alignment: Qt.AlignRight
                    }
                }
            }
        }
    }
}
