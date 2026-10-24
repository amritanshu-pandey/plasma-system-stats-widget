import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.ksysguard.sensors as Sensors

ColumnLayout {
    id: battery

    property string device
    property Stats stats
    property bool active
    property bool showName: false

    readonly property real level: percentage.value || 0
    readonly property bool charging: rate.value > 0.05
    readonly property bool discharging: rate.value < -0.05

    spacing: Kirigami.Units.smallSpacing

    Sensors.Sensor {
        id: name
        sensorId: "power/%1/name".arg(battery.device)
        enabled: battery.active
    }
    Sensors.Sensor {
        id: percentage
        sensorId: "power/%1/chargePercentage".arg(battery.device)
        enabled: battery.active
    }
    Sensors.Sensor {
        id: rate
        sensorId: "power/%1/chargeRate".arg(battery.device)
        enabled: battery.active
    }
    Sensors.Sensor {
        id: charge
        sensorId: "power/%1/charge".arg(battery.device)
        enabled: battery.active
    }
    Sensors.Sensor {
        id: capacity
        sensorId: "power/%1/capacity".arg(battery.device)
        enabled: battery.active
    }

    SectionLabel {
        visible: battery.showName
        text: name.value || battery.device
    }

    UsageBar {
        value: battery.level
        warning: battery.level <= 15 && !battery.charging
        Layout.preferredHeight: Kirigami.Units.smallSpacing * 2
    }

    SensorRow {
        label: i18n("Status")
        value: battery.charging ? i18n("Charging")
             : battery.discharging ? i18n("Discharging")
             : battery.level >= 99 ? i18n("Full")
             : i18n("Not charging")
        active: false
    }
    SensorRow {
        label: battery.charging ? i18n("Time to full") : i18n("Time remaining")
        visible: battery.charging || battery.discharging
        value: battery.stats.duration(battery.charging
            ? (capacity.value - charge.value) / rate.value
            : charge.value / -rate.value)
        active: false
    }
    SensorRow {
        label: battery.charging ? i18n("Charging power") : i18n("Power draw")
        visible: battery.charging || battery.discharging
        value: i18nc("power in watts", "%1 W", Math.abs(rate.value || 0).toFixed(1))
        active: false
    }
    SensorRow {
        label: i18n("Charge")
        value: i18n("%1 of %2", charge.formattedValue, capacity.formattedValue)
        active: false
    }
    SensorRow {
        label: i18n("Health")
        sensorId: "power/%1/health".arg(battery.device)
        active: battery.active
    }
    SensorRow {
        label: i18n("Design capacity")
        sensorId: "power/%1/design".arg(battery.device)
        active: battery.active
    }
}
