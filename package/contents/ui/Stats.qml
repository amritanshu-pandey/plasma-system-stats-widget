import QtQuick
import org.kde.ksysguard.sensors as Sensors

QtObject {
    id: stats

    property int interval: 1000
    property int historyLength: 60
    property bool networkBits: false
    property string temperatureSensor: "cpu/all/averageTemperature"
    property bool showPublicIp: false

    readonly property Sensors.SensorTreeModel sensorTree: Sensors.SensorTreeModel {}

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
    readonly property Sensors.Sensor temperature: Sensors.Sensor {
        sensorId: stats.temperatureSensor || "cpu/all/averageTemperature"
        updateRateLimit: stats.interval
    }

    readonly property SensorSearch batterySearch: SensorSearch {
        tree: stats.sensorTree
        pattern: /^power\/[\w.:-]+\/chargePercentage$/
        interval: 60000
    }
    readonly property var batteries: batterySearch.matches.map(id => id.split("/")[1])
    readonly property bool hasBattery: batteries.length > 0

    readonly property Sensors.Sensor battery: Sensors.Sensor {
        sensorId: stats.hasBattery ? "power/%1/chargePercentage".arg(stats.batteries[0]) : ""
        updateRateLimit: stats.interval
    }
    readonly property Sensors.Sensor batteryRate: Sensors.Sensor {
        sensorId: stats.hasBattery ? "power/%1/chargeRate".arg(stats.batteries[0]) : ""
        updateRateLimit: stats.interval
    }
    readonly property bool charging: batteryRate.value > 0.05

    readonly property SensorSearch gpuSearch: SensorSearch {
        tree: stats.sensorTree
        pattern: /^gpu\/gpu\d+\/usage$/
        interval: 60000
    }
    readonly property var gpus: gpuSearch.matches.map(id => id.split("/")[1])
    readonly property bool hasGpu: gpus.length > 0

    readonly property Sensors.Sensor gpu: Sensors.Sensor {
        sensorId: stats.hasGpu ? "gpu/all/usage" : ""
        updateRateLimit: stats.interval
    }
    readonly property Sensors.Sensor gpuMemoryUsed: Sensors.Sensor {
        sensorId: stats.hasGpu ? "gpu/all/usedVram" : ""
        updateRateLimit: stats.interval
    }
    readonly property Sensors.Sensor gpuMemoryTotal: Sensors.Sensor {
        sensorId: stats.hasGpu ? "gpu/all/totalVram" : ""
        updateRateLimit: stats.interval
    }
    readonly property real gpuMemory: gpuMemoryTotal.value > 0 ? 100 * (gpuMemoryUsed.value || 0) / gpuMemoryTotal.value : NaN

    readonly property History cpuHistory: History { size: stats.historyLength }
    readonly property History memoryHistory: History { size: stats.historyLength }
    readonly property History diskReadHistory: History { size: stats.historyLength }
    readonly property History diskWriteHistory: History { size: stats.historyLength }
    readonly property History downloadHistory: History { size: stats.historyLength }
    readonly property History uploadHistory: History { size: stats.historyLength }
    readonly property History temperatureHistory: History { size: stats.historyLength }
    readonly property History gpuHistory: History { size: stats.historyLength }
    readonly property History gpuMemoryHistory: History { size: stats.historyLength }

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
            stats.temperatureHistory.push(stats.temperature.value);
            if (stats.hasGpu) {
                stats.gpuHistory.push(stats.gpu.value);
                stats.gpuMemoryHistory.push(stats.gpuMemory);
            }
        }
    }

    function percent(value) {
        return Number.isFinite(value) ? Math.round(value) + "%" : "–";
    }

    function celsius(value) {
        return Number.isFinite(value) && value > 0 ? Math.round(value) + "°C" : "–";
    }

    function rate(value, bits) {
        if (!Number.isFinite(value)) {
            return "–";
        }
        if (bits) {
            value *= 8;
        }
        const units = bits ? ["b/s", "kb/s", "Mb/s", "Gb/s"] : ["B/s", "kB/s", "MB/s", "GB/s"];
        let i = 0;
        while (value >= 1000 && i < units.length - 1) {
            value /= 1000;
            i++;
        }
        const digits = i > 0 && value < 10 ? 1 : 0;
        return value.toFixed(digits) + " " + units[i];
    }

    function networkRate(value) {
        return rate(value, networkBits);
    }

    // Short form for narrow places, like "860K" or "1.2M".
    function shortRate(value, bits) {
        if (!Number.isFinite(value)) {
            return "–";
        }
        if (bits) {
            value *= 8;
        }
        const units = bits ? ["b", "Kb", "Mb", "Gb"] : ["B", "K", "M", "G"];
        let i = 0;
        while (value >= 1000 && i < units.length - 1) {
            value /= 1000;
            i++;
        }
        const digits = i > 0 && value < 10 ? 1 : 0;
        return value.toFixed(digits) + units[i];
    }

    function networkShortRate(value) {
        return shortRate(value, networkBits);
    }

    function duration(hours) {
        if (!Number.isFinite(hours) || hours <= 0) {
            return "–";
        }
        const minutes = Math.round(hours * 60);
        return minutes >= 60
            ? i18nc("hours and minutes", "%1 h %2 min", Math.floor(minutes / 60), minutes % 60)
            : i18nc("minutes", "%1 min", minutes);
    }
}
