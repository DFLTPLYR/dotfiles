// Assets.qml
pragma Singleton
import QtQuick

QtObject {
    readonly property url icons: Qt.resolvedUrl("icons/")
    readonly property url gifs: Qt.resolvedUrl("gifs/")

    readonly property var iconPaths: ({
            //Test
            test: icons + "test.svg",

            // Icons
            magic: icons + "Magic.json",
            menu: icons + "Menu.json",
            play: icons + "play.json",
            setting: icons + "Setting.json",
            wallpaper: icons + "Wallpaper.json",
            restart: icons + "Restart.json",
            cpu: icons + "cpu.svg",
            gpu: icons + "gpu.svg",
            network: icons + "network.svg",

            // Gifs
            bongo_cat: gifs + "bongocat.gif",
            kurukuru: gifs + "kurukuru.gif"
        })
}
