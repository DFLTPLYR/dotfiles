pragma ComponentBehavior: Bound
import Quickshell
import QtQuick
import QtQuick.Layouts

import qs.core
import qs.components
import qs.modules.settings

PopupModal {
    id: modal
    property ShellScreen screen
    signal action(string action)

    width: popupContent.width + (modal.leftPadding + modal.rightPadding)
    height: popupContent.height + (modal.bottomPadding + modal.topPadding)

    Behavior on y {
        NumberAnimation {
            easing.type: Easing.InOutQuad
            duration: 100
        }
    }

    Behavior on x {
        NumberAnimation {
            easing.type: Easing.InOutQuad
            duration: 100
        }
    }

    enter: Transition {
        NumberAnimation {
            property: "opacity"
            from: 0.0
            to: 1.0
            easing.type: Easing.InOutQuad
            duration: 300
        }
    }

    exit: Transition {
        NumberAnimation {
            property: "opacity"
            from: 1.0
            to: 0.0
            easing.type: Easing.InOutQuad
            duration: 300
        }
    }

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
                    settingLoader.active = true;
                    settingLoader.page = page;
                    modal.close();
                }
            }
        }
    }

    LazyLoader {
        id: settingLoader
        property int page: 0
        active: false
        SettingPanel {
            id: settingPanel
            screen: modal.screen
            visible: settingLoader.active
            page: settingLoader.page
            onClosed: settingLoader.active = false
        }
    }
}
