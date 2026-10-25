import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.ksysguard.sensors as Sensors

ColumnLayout {
    id: gpu

    property string device
    property bool active
    property bool showName: false

    function sensorId(name) {
        return "gpu/%1/%2".arg(device).arg(name);
    }

    spacing: Kirigami.Units.smallSpacing

    Sensors.Sensor {
        id: name
        sensorId: gpu.sensorId("name")
        enabled: gpu.active
    }
    Sensors.Sensor {
        id: total
        sensorId: gpu.sensorId("totalVram")
        enabled: gpu.active
    }
    Sensors.Sensor {
        id: power
        sensorId: gpu.sensorId("power")
        enabled: gpu.active
    }

    SectionLabel {
        visible: gpu.showName
        text: name.value || gpu.device
    }

    SensorRow {
        visible: gpu.showName
        label: i18n("Usage")
        sensorId: gpu.sensorId("usage")
        active: gpu.active
    }
    SensorRow {
        id: memory
        label: i18n("Video memory")
        sensorId: gpu.sensorId("usedVram")
        active: gpu.active
        value: i18n("%1 of %2", memory.sensor.formattedValue, total.formattedValue)
    }
    UsageBar {
        value: total.value > 0 ? 100 * (memory.sensor.value || 0) / total.value : 0
    }
    SensorRow {
        label: i18n("Temperature")
        sensorId: gpu.sensorId("temperature")
        active: gpu.active
        hideWhenEmpty: true
    }
    SensorRow {
        label: i18n("Power")
        sensorId: gpu.sensorId(Number.isFinite(power.value) ? "power" : "power1")
        active: gpu.active
        hideWhenEmpty: true
    }
    SensorRow {
        label: i18n("Core clock")
        sensorId: gpu.sensorId("coreFrequency")
        active: gpu.active
    }
    SensorRow {
        label: i18n("Memory clock")
        sensorId: gpu.sensorId("memoryFrequency")
        active: gpu.active
    }
}
