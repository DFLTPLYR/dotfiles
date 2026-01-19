import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs.config
import qs.components

PageWrapper {
    PageHeader {
        title: "Navbar"
    }
    Spacer {}

    PageFooter {
        onSave: {
            Config.saveSettings();
        }
        onSaveAndExit: {
            Config.general.previewWallpaper = [];
            Config.saveSettings();
            Qt.callLater(() => {
                Config.openSettingsPanel = false;
            });
        }
        onExit: {
            Config.general.previewWallpaper = [];
            Qt.callLater(() => {
                Config.openSettingsPanel = false;
            });
        }
    }
}
