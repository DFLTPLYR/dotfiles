//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma DropExpensiveFonts
//@ pragma IconTheme Papirus-Dark
//@ pragma Env QSG_RENDER_LOOP=threaded
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000
//@ pragma AppId 69420
//@ pragma ShellId 69420

import QtQuick
import Quickshell
import qs.core
import qs.modules.overlay.polkit
import qs.modules.overlay.greeter
import qs.modules.settings
import System

ShellRoot {
    id: root

    LazyLoader {
        active: Global.general.greeter && Background.ready
        component: Greeter {}
    }

    Polkit {}

    Reshell {}

    LazyLoader {
        active: Global.setting.visible
        component: SettingPanel {
            id: settingPanel
            page: Global.setting.page
            onClosed: {
                Global.setting.visible = false;
                Background.save();
                Global.save();
            }
        }
    }

    Connections {
        target: SysFont
        function onCurrentChanged() {
            print(SysFont.current);
        }
    }

    Component.onDestruction: {
        ScreenRec.pkill();
    }

    Component.onCompleted: {
        ColorGen.configPath = Quickshell.shellPath('core/theme');
    }
}
