import QtQuick

import qs.core
import qs.components

PopupModal {
    id: propertiesModal
    x: screen.width / 2 - propertiesModal.width / 2
    y: screen.height / 2 - propertiesModal.height / 2

    Loader {
        active: propertiesModal.opened
        sourceComponent: Rectangle {
            color: Colors.color.background

            width: screen.width / 1.5
            height: screen.height / 1.5

            border {
                width: 1
                color: Colors.color.primary
            }

            Component.onCompleted: {
                Global.bindRadii(this);
                Global.properties = true;
            }
            Component.onDestruction: Global.properties = false
        }
    }
}
