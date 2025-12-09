import QtQuick
import qs.assets
import qs.config

Singleton {
    function testFunc() {
        return "ModuleLoader testFunc called";
    }
    function returnModule(comp) {
        switch (comp) {
        case "powerButton":
            return powerButtonModule;
        case "workSpaces":
            return workSpacesModule;
        case "clock":
            return clockModule;
        default:
            return null;
        }
    }
    Component {
        id: powerButtonModule
        PowerButton {}
    }
    Component {
        id: workSpacesModule
        WorkSpaces {}
    }
    Component {
        id: clockModule
        Clock {}
    }
}
