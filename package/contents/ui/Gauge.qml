import QtQuick
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

// A ring that fills clockwise from the top. An optional second value is drawn as an inner ring.
Item {
    id: gauge

    property real value: 0
    property real secondValue: -1
    property string text
    property color color: Kirigami.Theme.highlightColor
    property color secondColor: Kirigami.Theme.negativeTextColor

    readonly property real lineWidth: Math.max(2, Math.round(width * 0.11))

    onValueChanged: canvas.requestPaint()
    onSecondValueChanged: canvas.requestPaint()
    onColorChanged: canvas.requestPaint()
    onSecondColorChanged: canvas.requestPaint()

    Canvas {
        id: canvas
        anchors.fill: parent

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        function ring(ctx, radius, fraction, color) {
            const center = width / 2;
            ctx.lineWidth = gauge.lineWidth;
            ctx.lineCap = "round";

            ctx.beginPath();
            ctx.arc(center, center, radius, 0, 2 * Math.PI);
            ctx.globalAlpha = 0.15;
            ctx.strokeStyle = Kirigami.Theme.textColor;
            ctx.stroke();
            ctx.globalAlpha = 1;

            const clamped = Math.max(0, Math.min(fraction, 1));
            if (clamped > 0.02) {
                ctx.beginPath();
                ctx.arc(center, center, radius, -Math.PI / 2, -Math.PI / 2 + clamped * 2 * Math.PI);
                ctx.strokeStyle = color;
                ctx.stroke();
            }
        }

        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();
            const outer = width / 2 - gauge.lineWidth / 2;
            ring(ctx, outer, gauge.value, gauge.color);
            if (gauge.secondValue >= 0) {
                ring(ctx, outer - gauge.lineWidth * 1.4, gauge.secondValue, gauge.secondColor);
            }
        }
    }

    PlasmaComponents.Label {
        anchors.centerIn: parent
        width: parent.width - gauge.lineWidth * (gauge.secondValue >= 0 ? 5 : 3)
        height: parent.height * 0.5
        text: gauge.text
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        fontSizeMode: Text.Fit
        minimumPixelSize: 5
        font.pixelSize: Math.max(5, Math.round(parent.height * 0.32))
        font.bold: true
    }
}
