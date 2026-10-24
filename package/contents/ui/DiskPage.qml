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
        id: usedPercent
        sensorId: "disk/all/usedPercent"
        enabled: page.active
    }
    Sensors.Sensor {
        id: total
        sensorId: "disk/all/total"
        enabled: page.active
    }

    PageHeader {
        title: i18n("Disk")
        subtitle: i18n("%1 of %2 used", used.value, total.formattedValue)
        value: page.stats.percent(usedPercent.value)
    }

    MiniGraph {
        Layout.fillWidth: true
        Layout.preferredHeight: Kirigami.Units.gridUnit * 4
        values: page.stats.diskReadHistory.values
        secondValues: page.stats.diskWriteHistory.values
        size: page.stats.historyLength
    }

    RowLayout {
        spacing: Kirigami.Units.largeSpacing

        Legend {
            color: Kirigami.Theme.highlightColor
            text: i18n("Read")
        }
        Legend {
            color: Kirigami.Theme.negativeTextColor
            text: i18n("Write")
        }
    }

    SensorRow {
        label: i18n("Read")
        value: page.stats.rate(page.stats.diskRead.value)
        active: false
    }
    SensorRow {
        label: i18n("Write")
        value: page.stats.rate(page.stats.diskWrite.value)
        active: false
    }
    SensorRow {
        id: used
        label: i18n("Used space")
        sensorId: "disk/all/used"
        active: page.active
    }
    SensorRow {
        label: i18n("Free space")
        sensorId: "disk/all/free"
        active: page.active
    }
}
