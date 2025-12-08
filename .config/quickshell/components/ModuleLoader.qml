import QtQuick

import qs.assets
import qs.config

Loader {
    id: root
    property string moduleName
    width: parent.width
    height: parent.height
    sourceComponent: {
        return workSpacesModule;
        switch (root.moduleName) {
        default:
            return workSpacesModule;
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
