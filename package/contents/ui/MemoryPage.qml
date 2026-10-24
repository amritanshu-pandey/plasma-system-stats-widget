import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.ksysguard.sensors as Sensors

ColumnLayout {
    id: page

    property Stats stats
    property bool active

    spacing: Kirigami.Units.smallSpacing

    Sensors.Sensor {
        id: total
        sensorId: "memory/physical/total"
        enabled: page.active
    }
    Sensors.Sensor {
        id: swapTotal
        sensorId: "memory/swap/total"
        enabled: page.active
    }

    PageHeader {
        title: i18n("Memory")
        subtitle: i18n("%1 of %2", used.value, total.formattedValue)
        value: page.stats.percent(page.stats.memory.value)
    }

    MiniGraph {
        Layout.fillWidth: true
        Layout.preferredHeight: Kirigami.Units.gridUnit * 4
        values: page.stats.memoryHistory.values
        size: page.stats.historyLength
        maximum: 100
    }

    SensorRow {
        id: used
        label: i18n("Used")
        sensorId: "memory/physical/used"
        active: page.active
    }
    SensorRow {
        label: i18n("Application")
        sensorId: "memory/physical/application"
        active: page.active
    }
    SensorRow {
        label: i18n("Cache")
        sensorId: "memory/physical/cache"
        active: page.active
    }
    SensorRow {
        label: i18n("Buffers")
        sensorId: "memory/physical/buffer"
        active: page.active
    }
    SensorRow {
        label: i18n("Free")
        sensorId: "memory/physical/free"
        active: page.active
    }
    SensorRow {
        id: swap
        label: i18n("Swap")
        sensorId: "memory/swap/used"
        active: page.active
        value: i18n("%1 of %2", swap.sensor.formattedValue, swapTotal.formattedValue)
    }

    TopProcesses {
        attribute: "vmPSS"
        active: page.active
        interval: page.stats.interval
        Layout.fillWidth: true
    }
}
