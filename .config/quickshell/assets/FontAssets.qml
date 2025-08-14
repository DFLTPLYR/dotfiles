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

    readonly property string fontAwesomeRegular: awesomeFontReg.name
    readonly property string fontAwesomeBrands: awesomeFontBrandReg.name
    readonly property string fontAwesomeSolid: awesomeFontSolid.name
}
