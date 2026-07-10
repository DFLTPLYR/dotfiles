pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick

import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property var locale: Qt.locale()
    property date currentDate: new Date()

    function getService(text) {
        var match = text.match(/^(\w+)/);
        if (!match)
            return undefined;
        var name = match[1];
        return this[name.charAt(0).toLowerCase() + name.slice(1)];
    }

    // From Ardox in Quickshell Discord
    property int contribution_number
    property string author: "DFLTPLYR"
    property var contributions: []

    Timer {
        interval: 600000
        running: true
        repeat: true
        onTriggered: getContributions.running = true
    }

    Process {
        id: getContributions
        running: true
        command: ["curl", `https://github-contributions-api.jogruber.de/v4/${root.author}`]
        stdout: StdioCollector {
            onStreamFinished: {
                if (!text)
                    return;
                const json = JSON.parse(text);
                const year = root.currentDate.getFullYear();
                // Calculate total contributions in the last 365 days
                const oneYearAgo = new Date();
                oneYearAgo.setDate(oneYearAgo.getDate() - 365);
                root.contribution_number = json.contributions.filter(c => new Date(c.date) >= oneYearAgo).reduce((sum, c) => sum + c.count, 0);

                const allContribs = json.contributions;
                const today = new Date();
                const cutoff = new Date(today);
                cutoff.setDate(cutoff.getDate() - 280);

                const recentContribs = allContribs.filter(c => new Date(c.date) >= cutoff).sort((a, b) => new Date(a.date) - new Date(b.date));

                root.contributions = recentContribs;
            }
        }
    }

    Connections {
        target: Global
        function onHasConnectionChanged() {
            if (Global.hasConnection) {
                getContributions.running = true;
            }
        }
    }
}
