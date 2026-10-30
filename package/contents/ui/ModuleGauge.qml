import QtQuick
import org.kde.kirigami as Kirigami

// Gauge for one panel module.
Gauge {
    id: moduleGauge

    property string module
    property Stats stats
    property bool showLabel: true

    signal clicked()

    // Activity relative to the recent peak, with a floor so idle reads near zero.
    function activity(value, history, floor) {
        const peak = Math.max(floor, ...history);
        return Math.min(1, (value || 0) / peak);
    }

    function levelColor(fraction) {
        return fraction >= 0.9 ? Kirigami.Theme.negativeTextColor
             : fraction >= 0.7 ? Kirigami.Theme.neutralTextColor
             : Kirigami.Theme.highlightColor;
    }

    value: {
        switch (module) {
        case "cpu": return (stats.cpu.value || 0) / 100;
        case "memory": return (stats.memory.value || 0) / 100;
        case "gpu": return (stats.gpu.value || 0) / 100;
        case "disk": return activity(stats.diskReadRate, stats.diskReadHistory.values, 10e6);
        case "network": return activity(stats.download.value, stats.downloadHistory.values, 1e6);
        case "sensors": return (stats.temperature.value || 0) / 100;
        case "battery": return (stats.battery.value || 0) / 100;
        }
        return 0;
    }

    secondValue: {
        switch (module) {
        case "gpu": return Number.isFinite(stats.gpuMemory) ? stats.gpuMemory / 100 : -1;
        case "disk": return activity(stats.diskWriteRate, stats.diskWriteHistory.values, 10e6);
        case "network": return activity(stats.upload.value, stats.uploadHistory.values, 1e6);
        }
        return -1;
    }

    color: {
        switch (module) {
        case "disk":
        case "network":
            return Kirigami.Theme.highlightColor;
        case "battery":
            return stats.charging ? Kirigami.Theme.positiveTextColor
                 : value <= 0.15 ? Kirigami.Theme.negativeTextColor
                 : Kirigami.Theme.highlightColor;
        }
        return levelColor(value);
    }

    secondColor: module === "gpu" ? Qt.alpha(Kirigami.Theme.textColor, 0.6) : Kirigami.Theme.negativeTextColor

    text: {
        const number = v => Number.isFinite(v) ? String(Math.round(v)) : "–";
        switch (module) {
        case "cpu": return showLabel ? i18n("CPU") : number(stats.cpu.value);
        case "memory": return showLabel ? i18n("RAM") : number(stats.memory.value);
        case "gpu": return showLabel ? i18n("GPU") : number(stats.gpu.value);
        case "disk": return showLabel ? i18n("DISK") : stats.shortRate((stats.diskReadRate || 0) + (stats.diskWriteRate || 0));
        case "network": return showLabel ? "↓↑" : stats.networkShortRate(Math.max(stats.download.value || 0, stats.upload.value || 0));
        case "sensors": return stats.temperature.value > 0 ? number(stats.temperature.value) + "°" : "–";
        case "battery": return number(stats.battery.value);
        }
        return "";
    }

    TapHandler {
        onTapped: moduleGauge.clicked()
    }
}
