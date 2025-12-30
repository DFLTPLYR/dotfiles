// Gauge.qml
import QtQuick

Item {
    id: gauge
    property real value: 0
    property color backgroundColor: "lightgray"
    property color foregroundColor: "green"
    property real strokeWidth: width / 18
    property real backgroundStrokeWidth: width / 40
    property real padding: 20
    property bool smoothRepaint: false

    anchors.fill: parent

    Canvas {
        id: gaugeBackground
        anchors.fill: parent
        onPaint: {
            const ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);

            const centerX = width / 2;
            const centerY = height / 2;
            const radius = width / 2 - gauge.padding;
            const startAngle = Math.PI * 0.75;
            const endAngle = Math.PI * 2.25;

            ctx.beginPath();
            ctx.lineWidth = gauge.backgroundStrokeWidth;
            ctx.strokeStyle = gauge.backgroundColor;
            ctx.lineCap = "round";
            ctx.arc(centerX, centerY, radius, startAngle, endAngle);
            ctx.stroke();
        }
    }

    Canvas {
        id: gaugeForeground
        anchors.fill: parent
        renderStrategy: Canvas.Cooperative

        property real progress: value

        Behavior on progress {
            NumberAnimation {
                duration: 500
                easing.type: Easing.InOutQuad
            }
        }

        FrameAnimation {
            id: repaintLoop
            running: gauge.smoothRepaint
            onTriggered: gaugeForeground.requestPaint()
        }

        onPaint: {
            const ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);

            const centerX = width / 2;
            const centerY = height / 2;
            const radius = width / 2 - gauge.padding;
            const startAngle = Math.PI * 0.75;
            const sweepAngle = Math.PI * 1.5;
            const normalizedProgress = Math.min(progress / 100, 1);
            const endAngle = startAngle + sweepAngle * normalizedProgress;

            ctx.beginPath();
            ctx.lineWidth = gauge.strokeWidth;
            ctx.strokeStyle = gauge.foregroundColor;
            ctx.lineCap = "round";
            ctx.arc(centerX, centerY, radius, startAngle, endAngle);
            ctx.stroke();
        }
    }
}
