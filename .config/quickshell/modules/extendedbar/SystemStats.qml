import QtQuick
import QtQuick.Layouts

import qs.services
import qs.components
import qs.assets
import qs.utils
import qs

GridLayout {
    anchors.centerIn: parent
    width: parent.width
    height: parent.height
    columns: Math.max(1, Math.floor(width / 100))

    Rectangle {
        radius: 10
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: Scripts.setOpacity(Assets.color0, 0.5)

        // function formatGB(value) {
        //     return (value / (1024 * 1024)).toFixed(2) + " GB";
        // }

        // ColumnLayout {
        //     anchors.centerIn: parent

        //     Text {
        //         font.family: FontAssets.fontAwesomeRegular
        //         text: "\uf0ec"
        //         font.pixelSize: 24
        //         color: Assets.color14
        //         Layout.alignment: Qt.AlignHCenter
        //     }

        //     Text {
        //         color: Assets.color14
        //         text: (SystemResource.swapUsedPercentage * 100).toFixed(1) + "%"
        //     }
        // }

        // Text {
        //     anchors.horizontalCenter: parent.horizontalCenter
        //     anchors.bottom: parent.bottom
        //     anchors.bottomMargin: 4

        //     wrapMode: Text.Wrap
        //     horizontalAlignment: Text.AlignHCenter
        //     font.pixelSize: 10
        //     color: Assets.color14
        //     text: parent.formatGB(SystemResource.swapUsed) + " / " + parent.formatGB(SystemResource.swapTotal)
        // }

        // Gauge {
        //     value: SystemResource.swapUsedPercentage * 100
        //     backgroundColor: Assets.color2
        //     foregroundColor: Assets.color15
        //     smoothRepaint: parentGrid.visible
        // }
    }

    Rectangle {
        radius: 10
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: Scripts.setOpacity(Assets.color0, 0.5)

        ColumnLayout {
            anchors.fill: parent

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height * 0.3

                Text {
                    text: qsTr("\ue322") // make this a property
                    color: Assets.color14
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.family: FontAssets.fontMaterialRounded
                    font.pixelSize: Math.min(parent.height, parent.width) * 0.8
                }

                Text {
                    text: "Cpu Usage" // make this a property
                    color: Assets.color14
                    Layout.fillWidth: true
                    verticalAlignment: Text.AlignVCenter
                    width: parent.width
                    wrapMode: Text.Wrap
                    font.family: FontAssets.fontSometypeItalic
                    font.pixelSize: {
                        const baseSize = parent.height * 0.4;
                        const maxWidth = width;
                        const textLength = text.length;
                        const scaleFactor = textLength > 10 ? Math.max(0.5, maxWidth / (textLength * 8)) : 1.0;
                        return Math.min(baseSize, baseSize * scaleFactor);
                    }
                }
            }

            // additional data
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: 'transparent'

                RowLayout {
                    width: parent.width
                    Text {
                        text: qsTr("Usage") // make this a property
                        color: Assets.color14
                        font.family: FontAssets.fontMaterialRounded
                        font.pixelSize: 12

                        Layout.alignment: Qt.AlignLeft // Align to the left
                    }

                    Text {
                        text: qsTr("10%") // make this a property
                        color: Assets.color14
                        font.family: FontAssets.fontMaterialRounded
                        font.pixelSize: 12
                        Layout.alignment: Qt.AlignRight // Align to the right
                    }
                }
            }
        }
    }
    Rectangle {
        radius: 10
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: Scripts.setOpacity(Assets.color0, 0.5)
    }
    Rectangle {
        radius: 10
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: Scripts.setOpacity(Assets.color0, 0.5)
    }
    // Rectangle {
    //     radius: 10
    //     Layout.fillWidth: true
    //     Layout.fillHeight: true
    //     color: "transparent"

    //     function formatGB(value) {
    //         return (value / (1024 * 1024)).toFixed(2) + " GB";
    //     }

    //     ColumnLayout {
    //         anchors.centerIn: parent

    //         Text {
    //             font.family: FontAssets.fontAwesomeRegular
    //             text: "\uf2d1"
    //             font.pixelSize: 24
    //             color: Assets.color14
    //             Layout.alignment: Qt.AlignHCenter
    //         }

    //         Text {
    //             color: Assets.color14
    //             text: (SystemResource.memoryUsedPercentage * 100).toFixed(1) + "%"
    //         }
    //     }

    //     Text {
    //         anchors.horizontalCenter: parent.horizontalCenter
    //         anchors.bottom: parent.bottom
    //         anchors.bottomMargin: 4

    //         wrapMode: Text.Wrap
    //         horizontalAlignment: Text.AlignHCenter
    //         font.pixelSize: 10
    //         color: Assets.color14
    //         text: parent.formatGB(SystemResource.memoryUsed) + " / " + parent.formatGB(SystemResource.memoryTotal)
    //     }

    //     Gauge {
    //         value: SystemResource.memoryUsedPercentage * 100
    //         backgroundColor: Assets.color2
    //         foregroundColor: Assets.color15
    //         smoothRepaint: parentGrid.visible
    //     }
    // }

    // Rectangle {
    //     radius: 10
    //     Layout.fillWidth: true
    //     Layout.fillHeight: true
    //     color: "transparent"

    //     function formatGB(value) {
    //         return (value / (1024 * 1024)).toFixed(2) + " GB";
    //     }

    //     ColumnLayout {
    //         anchors.centerIn: parent

    //         Text {
    //             font.family: FontAssets.fontAwesomeRegular
    //             text: "\uf2db"
    //             font.pixelSize: 24
    //             color: Assets.color14
    //             Layout.alignment: Qt.AlignHCenter
    //         }

    //         Text {
    //             color: Assets.color14
    //             text: (SystemResource.cpuUsage * 100).toFixed(1) + "%"
    //         }
    //     }

    //     Text {
    //         anchors.horizontalCenter: parent.horizontalCenter
    //         anchors.bottom: parent.bottom
    //         anchors.bottomMargin: 4

    //         wrapMode: Text.Wrap
    //         horizontalAlignment: Text.AlignHCenter
    //         font.pixelSize: 10
    //         color: Assets.color14
    //         text: 'Cpu Usage'
    //     }

    //     Gauge {
    //         value: SystemResource.cpuUsage * 100
    //         backgroundColor: Assets.color2
    //         foregroundColor: Assets.color15
    //         smoothRepaint: parentGrid.visible
    //     }
    // }

    // Rectangle {
    //     radius: 10
    //     Layout.fillWidth: true
    //     Layout.fillHeight: true
    //     color: "transparent"
    //     ColumnLayout {
    //         anchors.centerIn: parent

    //         Text {
    //             text: qsTr(`\uf093 ${SystemResource.netUpload}`)
    //             color: Assets.color14
    //         }

    //         Text {
    //             text: qsTr(`\uf019 ${SystemResource.netDownload}`)
    //             color: Assets.color14
    //         }
    //     }
    // }
}
