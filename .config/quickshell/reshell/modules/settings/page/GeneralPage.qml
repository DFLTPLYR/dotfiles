pragma ComponentBehavior: Bound

import QtCore
import Quickshell
import Qt.labs.folderlistmodel
import System

import QtQuick
import QtQuick.Layouts

import qs.core
import qs.components
import qs.modules.settings

Page {
    property var screen

    GreeterSection {}

    DisplayTemp {}

    component GreeterSection: GroupContainer {
        label: "Greeter"

        Toggle {
            property bool greeter: Global.general.greeter
            text: greeter ? "Enable" : "Disable"
            checked: greeter
            onCheckedChanged: {
                Global.general.greeter = checked;
                Global.save();
            }
        }
    }

    component DisplayTemp: GroupContainer {
        label: "Screen Temp"
        Row {
            Button {
                text: "Increase"
                onClicked: {
                    Quickshell.execDetached(["busctl", "--user", "call", "--", "rs.wl-gammarelay", "/", "rs.wl.gammarelay", "UpdateTemperature", "n", "500"]);
                }
            }

            Button {
                text: "Decrease"
                onClicked: {
                    Quickshell.execDetached(["busctl", "--user", "call", "--", "rs.wl-gammarelay", "/", "rs.wl.gammarelay", "UpdateTemperature", "n", "-500"]);
                }
            }
        }
    }
}
