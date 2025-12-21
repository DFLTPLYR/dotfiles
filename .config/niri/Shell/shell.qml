import QtQuick
import Quickshell

import qs.modules.navbar

ShellRoot {
    id: root
    bar {}

    Component.onCompleted: {
        console.log("Shell loaded");
    }
}
