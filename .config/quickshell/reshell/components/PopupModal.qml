import QtQuick
import qs.core

Popup {
    id: modalPopup

    Connections {
        target: Global
        function onEnableSettingChanged() {
            if (modalPopup.opened) {
                modalPopup.close();
            }
        }
    }
}
