import QtQuick

import qs.config

Item {
    property QtObject config: QtObject {
        property Properties main: Properties {
            color: "background"
            padding {
                left: 0
                right: 0
                bottom: 0
                top: 0
            }
            rounding {
                left: 0
                right: 0
                bottom: 0
                top: 0
            }
        }
        property Properties background: Properties {
            color: "background"

            padding {
                left: 0
                right: 0
                bottom: 0
                top: 0
            }
            rounding {
                left: 0
                right: 0
                bottom: 0
                top: 0
            }
        }
        property Properties intersection: Properties {
            color: "background"

            padding {
                left: 0
                right: 0
                bottom: 0
                top: 0
            }
            rounding {
                left: 0
                right: 0
                bottom: 0
                top: 0
            }
        }
    }

    layer.enabled: true
    Rectangle {
        id: main
    }

    Rectangle {
        id: background
    }

    Rectangle {
        id: intersection
    }
}
