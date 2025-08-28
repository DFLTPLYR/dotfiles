pragma Singleton
import QtQuick

import Quickshell
import Quickshell.Io

// component
import qs
import qs.services
import qs.assets

Item {
    id: root

    function tryHttpRequest(callback) {
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                callback(xhr.status);
            }
        };
        xhr.open("GET", "http://localhost:6969/");
        xhr.send();
    }

    function loadAdditional() {
        MprisManager;
        NotificationService;
        SystemResource;
        WallpaperStore;
        WeatherFetcher;
        FontAssets;

        Quickshell.execDetached({
            command: ["sh", "-c", "pgrep -x mpdris2-rs > /dev/null || nohup mpdris2-rs > /dev/null 2>&1 &"]
        });
    }

    Component.onCompleted: {
        tryHttpRequest(function (status) {
            if (status === 200) {
                console.log('Already Cooked Buns 😀');
            } else {
                var wd = Qt.resolvedUrl('./').toString().replace("file://", "");
                Quickshell.execDetached({
                    command: ["bun", "run", "dev"],
                    workingDirectory: wd
                });
                console.log('Cooked Buns 😃');
            }
            loadAdditional();
        });
    }
}
