// Font.qml
pragma Singleton
import QtQuick

Item {
    readonly property url fontPath: Qt.resolvedUrl("fonts/")

    // Font loaders
    FontLoader {
        id: awesomeFontReg
        source: fontPath + "Font-Awesome-7-Free-Regular-400.otf"
    }
    FontLoader {
        id: awesomeFontBrandReg
        source: fontPath + "Font-Awesome-7-Brands-Regular-400.otf"
    }
    FontLoader {
        id: awesomeFontSolid
        source: fontPath + "Font-Awesome-7-Free-Solid-900.otf"
    }

    // Safely exposed font names with fallback
    readonly property string fontAwesomeRegular: awesomeFontReg.status === FontLoader.Ready ? awesomeFontReg.name : "Sans Serif"
    readonly property string fontAwesomeBrands: awesomeFontBrandReg.status === FontLoader.Ready ? awesomeFontBrandReg.name : "Sans Serif"
    readonly property string fontAwesomeSolid: awesomeFontSolid.status === FontLoader.Ready ? awesomeFontSolid.name : "Sans Serif"
}
