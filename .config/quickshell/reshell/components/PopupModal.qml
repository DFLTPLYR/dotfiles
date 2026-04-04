import QtQuick
import qs.core

Popup {
    id: modalPopup
    onOpenedChanged: {
        if (!opened) {
            Global.modal = null;
            return;
        }
        if (Global.modal)
            Global.modal.close();
        Global.modal = modalPopup;
    }
    Connections {
        target: Global
        function onEditChanged() {
            if (modalPopup.opened) {
                modalPopup.close();
            }
        }
    }
}
