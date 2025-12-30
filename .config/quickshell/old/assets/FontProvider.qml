// FontAssets.qml
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

    FontLoader {
        id: materialOutlined
        source: fontPath + "material-outlined.ttf"
    }
    FontLoader {
        id: materialRounded
        source: fontPath + "material-rounded.ttf"
    }
    FontLoader {
        id: materialSharp
        source: fontPath + "material-sharp.ttf"
    }

    FontLoader {
        id: sometypeItalic
        source: fontPath + "sometype-italic.ttf"
    }
    FontLoader {
        id: sometypeMono
        source: fontPath + "SometypeMono-VariableFont_wght.ttf"
    }

    readonly property string fontAwesomeRegular: awesomeFontReg.name
    readonly property string fontAwesomeBrands: awesomeFontBrandReg.name
    readonly property string fontAwesomeSolid: awesomeFontSolid.name

    readonly property string fontMaterialOutlined: materialOutlined.name
    readonly property string fontMaterialRounded: materialRounded.name
    readonly property string fontMaterialSharp: materialSharp.name

    readonly property string fontSometypeItalic: sometypeItalic.name
    readonly property string fontSometypeMono: sometypeMono.name
}
