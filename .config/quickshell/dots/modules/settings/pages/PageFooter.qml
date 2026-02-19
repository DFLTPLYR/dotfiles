import QtQuick
import QtQuick.Layouts

import qs.config
import qs.components

Item {
    id: footer
    signal save
    signal saveAndExit
    signal exit

    property alias footerLayout: footerLayout.data
    Layout.fillWidth: true
    Layout.preferredHeight: 40
    Layout.bottomMargin: 40

    RowLayout {
        id: footerLayout
        width: parent.width

        Text {
            Layout.fillWidth: true
            text: "Save Settings"
            color: Colors.color.secondary
            font.pixelSize: 24
        }

        Row {
            spacing: 10

            StyledButton {
                text: "Cancel"

                onClicked: {
                    footer.exit();
                }
            }

            StyledButton {
                text: "Save"

                onClicked: {
                    Config.general.previewWallpaper = [];
                    Config.saveSettings();
                    footer.save();
                }
            }

            StyledButton {
                text: "Save and Exit"

                onClicked: {
                    Config.general.previewWallpaper = [];
                    Config.saveSettings();
                    footer.saveAndExit();
                }
            }
        }
    }
}
