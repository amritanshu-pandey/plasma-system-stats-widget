import QtQuick
import org.kde.ksysguard.sensors as Sensors

QtObject {
    id: stats

    property int interval: 1000
    property int historyLength: 60

    readonly property Sensors.Sensor cpu: Sensors.Sensor {
        sensorId: "cpu/all/usage"
        updateRateLimit: stats.interval
    }
    readonly property Sensors.Sensor memory: Sensors.Sensor {
        sensorId: "memory/physical/usedPercent"
        updateRateLimit: stats.interval
    }
    readonly property Sensors.Sensor diskRead: Sensors.Sensor {
        sensorId: "disk/all/read"
        updateRateLimit: stats.interval
    }
    readonly property Sensors.Sensor diskWrite: Sensors.Sensor {
        sensorId: "disk/all/write"
        updateRateLimit: stats.interval
    }
    readonly property Sensors.Sensor download: Sensors.Sensor {
        sensorId: "network/all/download"
        updateRateLimit: stats.interval
    }
    readonly property Sensors.Sensor upload: Sensors.Sensor {
        sensorId: "network/all/upload"
        updateRateLimit: stats.interval
    }

    readonly property History cpuHistory: History { size: stats.historyLength }
    readonly property History memoryHistory: History { size: stats.historyLength }
    readonly property History diskReadHistory: History { size: stats.historyLength }
    readonly property History diskWriteHistory: History { size: stats.historyLength }
    readonly property History downloadHistory: History { size: stats.historyLength }
    readonly property History uploadHistory: History { size: stats.historyLength }

    readonly property Timer sampler: Timer {
        interval: stats.interval
        running: true
        repeat: true
        onTriggered: {
            stats.cpuHistory.push(stats.cpu.value);
            stats.memoryHistory.push(stats.memory.value);
            stats.diskReadHistory.push(stats.diskRead.value);
            stats.diskWriteHistory.push(stats.diskWrite.value);
            stats.downloadHistory.push(stats.download.value);
            stats.uploadHistory.push(stats.upload.value);
        }
    }

    function percent(value) {
        return Number.isFinite(value) ? Math.round(value) + "%" : "–";
    }

    function rate(value) {
        if (!Number.isFinite(value)) {
            return "–";
        }
        const units = ["B/s", "kB/s", "MB/s", "GB/s"];
        let i = 0;
        while (value >= 1000 && i < units.length - 1) {
            value /= 1000;
            i++;
        }
        const digits = i > 0 && value < 10 ? 1 : 0;
        return value.toFixed(digits) + " " + units[i];
    }
}
