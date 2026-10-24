import QtQuick
import org.kde.kirigami as Kirigami

Canvas {
    id: graph

    property var values: []
    property var secondValues: []
    property int size: 60
    // Fixed top of the scale. When 0 the scale follows the peak value.
    property real maximum: 0
    property color color: Kirigami.Theme.highlightColor
    property color secondColor: Kirigami.Theme.negativeTextColor
    property color backgroundColor: Kirigami.Theme.textColor

    onValuesChanged: requestPaint()
    onSecondValuesChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onColorChanged: requestPaint()
    onSecondColorChanged: requestPaint()
    onBackgroundColorChanged: requestPaint()

    function drawSeries(ctx, data, top, color) {
        if (data.length < 2) {
            return;
        }
        const step = width / (size - 1);
        const start = width - (data.length - 1) * step;
        const y = v => height - Math.min(v / top, 1) * (height - 1);

        ctx.beginPath();
        ctx.moveTo(start, y(data[0]));
        for (let i = 1; i < data.length; i++) {
            ctx.lineTo(start + i * step, y(data[i]));
        }
        ctx.strokeStyle = color;
        ctx.lineWidth = 1;
        ctx.stroke();

        ctx.lineTo(width, height);
        ctx.lineTo(start, height);
        ctx.closePath();
        ctx.globalAlpha = 0.3;
        ctx.fillStyle = color;
        ctx.fill();
        ctx.globalAlpha = 1;
    }

    onPaint: {
        const ctx = getContext("2d");
        ctx.reset();

        ctx.globalAlpha = 0.06;
        ctx.fillStyle = backgroundColor;
        ctx.fillRect(0, 0, width, height);
        ctx.globalAlpha = 1;

        const top = maximum > 0 ? maximum : Math.max(1, ...values, ...secondValues) * 1.1;
        drawSeries(ctx, values, top, color);
        drawSeries(ctx, secondValues, top, secondColor);
    }
}
