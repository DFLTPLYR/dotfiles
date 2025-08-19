pragma Singleton
import QtQuick

import Quickshell
import Quickshell.Io

Item {
    function start() {
        backendSocket.connected = true;
    }

    Socket {
        id: backendSocket
        path: "/tmp/bun.sock"
        connected: false

        onConnectedChanged: {
            if (connected) {
                backendSocket.write("GET / HTTP/1.1\r\nHost: localhost\r\n\r\n");
                backendSocket.flush();
            }
        }

        parser: SplitParser {
            onRead: message => {
                console.log("Response from Bun:", message);
            }
        }

        onError: {
            Quickshell.execDetached({
                command: ["bun", "run", "--hot", "src/index.ts"],
                workingDirectory: Qt.resolvedUrl('./').toString().replace("file://", "")
            });
            backendSocket.connected = true;
        }
    }
}
