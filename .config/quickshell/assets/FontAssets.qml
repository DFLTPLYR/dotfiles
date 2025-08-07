// Font.qml
pragma Singleton
import QtQuick

Item {
    readonly property url fontPath: Qt.resolvedUrl("fonts/")

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

    // These update automatically when .name becomes available
    readonly property string fontAwesomeRegular: awesomeFontReg.name || "Sans Serif"
    readonly property string fontAwesomeBrands: awesomeFontBrandReg.name || "Sans Serif"
    readonly property string fontAwesomeSolid: awesomeFontSolid.name || "Sans Serif"
}
