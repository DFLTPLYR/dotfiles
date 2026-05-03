import Quickshell
import QtQuick
import QtQuick.Layouts

import qs.core
import qs.components

PopupModal {
    id: modal
    property ShellScreen screen
    signal action(string action)

    width: popupContent.width + (modal.leftPadding + modal.rightPadding)
    height: popupContent.height + (modal.bottomPadding + modal.topPadding)

    ColumnLayout {
        id: popupContent
        spacing: 0

        Button {
            text: "Refresh"
            Layout.fillWidth: true
            onClicked: Quickshell.reload(false)
        }

        Button {
            text: "Add Dock"
            Layout.fillWidth: true
            onClicked: mouse => {
                var globalPos = mapToItem(null, modal.x, modal.y);
                var l = globalPos.x;
                var r = screen.width - globalPos.x;
                var t = globalPos.y;
                var b = screen.height - globalPos.y;

                var min = Math.min(l, r, t, b);
                var direction = min === l ? "left" : min === r ? "right" : min === t ? "top" : "bottom";

                var name = Math.random().toString(36).substring(2, 10);
                panel.file.adapter.docks.push(name);

                panel.dockUpdate({
                    name,
                    direction
                });
            }
        }

        Repeater {
            model: Global.settings
            delegate: Button {
                required property string name
                required property int page
                Layout.fillWidth: true
                text: `Open ${name}`
                onClicked: {
                    settingPanel.visible = true;
                    settingPanel.page = page;
                    modal.close();
                }
            }
        }
    }

    SettingPanel {
        id: settingPanel
        screen: modal.screen
    }
}
