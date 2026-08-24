pragma ComponentBehavior: Bound
import Quickshell
import QtQuick
import QtQuick.Layouts

import qs.core
import qs.components
import qs.modules.settings

Menu {
    id: modal
    width: 150
    property Item panel
    property Item area
    signal action(string action)

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
    Action {
        text: "Save"
        onTriggered: {
            Background.save();
        }
    }

    Action {
        text: "Refresh"
        onTriggered: Quickshell.reload(false)
    }

    Action {
        text: "Add Dock"
        onTriggered: {
            var globalPos = mapToItem(null, modal.x, modal.y);
            var l = globalPos.x;
            var r = panel.screen.width - globalPos.x;
            var t = globalPos.y;
            var b = panel.screen.height - globalPos.y;

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

    Instantiator {
        model: Global.settings
        delegate: Action {
            required property string name
            required property int page
            text: `Open ${name}`
            onTriggered: {
                settingLoader.active = true;
                settingLoader.page = page;
                modal.close();
            }
        }
        onObjectAdded: (idx, obj) => {
            modal.insertAction(modal.count, obj);
        }
    }

    LazyLoader {
        id: settingLoader
        property int page: 0
        active: false
        SettingPanel {
            id: settingPanel
            visible: settingLoader.active
            page: settingLoader.page
            onClosed: {
                settingLoader.active = false;
                Background.save();
                Global.save();
            }
        }
    }
}
