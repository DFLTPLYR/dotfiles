import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import QtQuick
import QtQuick.Shapes
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Services.Mpris

// quickshell
import qs.services
import qs.modules.components.commons
import qs.animations
import qs.modules
import qs.assets
import qs
import QtQuick.Effects

Rectangle {
    id: layoutWrapper
    anchors.fill: parent
    color: 'transparent'

    function formatSpeed(bytesPerSec) {
        const units = ["B", "KB", "MB", "GB", "TB"];
        let value = bytesPerSec;
        let i = 0;
        while (value >= 1024 && i < units.length - 1) {
            value /= 1024;
            i++;
        }
        return value.toFixed(1) + " " + units[i] + "/s";
    }

    GridLayout {
        id: grid
        columns: 2
        anchors.fill: parent

        property bool isPortrait: screen.height > screen.width

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 20
                Layout.preferredWidth: 150

                Item {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredHeight: parent.height * 0.4
                    Layout.fillWidth: true

                    Image {
                        anchors.centerIn: parent
                        width: 32
                        height: 32
                        source: Assets.iconPaths.cpu
                        cache: true
                        smooth: true
                        mipmap: true
                    }
                }

                ColumnLayout {
                    spacing: 10
                    Layout.alignment: Qt.AlignHCenter

                    Text {
                        font.family: "FiraCode"
                        text: `Cpu Usage: ${HardwareStats.cpuUsage.toFixed(1)}%`
                        color: Colors.color10
                        font.pixelSize: 12
                    }
                    Text {
                        font.family: "FiraCode"
                        text: `Temp: ${HardwareStats.cpuTemperature.toFixed(0)}°`
                        color: Colors.color10
                        font.pixelSize: 12
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 20
                Layout.preferredWidth: 150

                Item {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredHeight: parent.height * 0.4
                    Layout.fillWidth: true

                    Image {
                        anchors.centerIn: parent
                        width: 32
                        height: 32
                        source: Assets.iconPaths.gpu
                        cache: true
                        smooth: true
                        mipmap: true
                    }
                }

                ColumnLayout {
                    spacing: 10
                    Layout.alignment: Qt.AlignHCenter

                    Text {
                        font.family: "FiraCode"
                        text: `Gpu Usage: ${HardwareStats.gpuProcUsage.toFixed(1)}%`
                        color: Colors.color10
                        font.pixelSize: 12
                    }

                    Text {
                        font.family: "FiraCode"
                        text: `Temp: ${HardwareStats.gpuTemp.toFixed(0)}°`
                        color: Colors.color10
                        font.pixelSize: 12
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 20
                Layout.preferredWidth: 150

                Item {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredHeight: parent.height * 0.4
                    Layout.fillWidth: true

                    Image {
                        anchors.centerIn: parent
                        width: 32
                        height: 32
                        source: Assets.iconPaths.network
                        cache: true
                        smooth: true
                        mipmap: true
                    }
                }

                ColumnLayout {
                    spacing: 10
                    Layout.alignment: Qt.AlignHCenter

                    Text {
                        text: `${formatSpeed(HardwareStats.downloadSpeed)}`
                        color: Colors.color10
                        font.pixelSize: 12
                    }
                    Text {
                        text: `${formatSpeed(HardwareStats.uploadSpeed)}`
                        color: Colors.color10
                        font.pixelSize: 12
                    }
                }
            }
        }
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            AnimatedImage {
                anchors.centerIn: parent
                width: parent.width
                height: width
                source: Assets.iconPaths.kurukuru
                cache: true
                smooth: true
                mipmap: true
            }
        }
    }
}
