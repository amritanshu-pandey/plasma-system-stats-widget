pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.ksysguard.sensors as Sensors

ColumnLayout {
    id: page

    property Stats stats
    property bool active

    spacing: Kirigami.Units.smallSpacing

    // Show only one of the volumes that share the same usage, preferring the shortest name.
    function isPreferred(index) {
        const self = volumeRows.itemAt(index) as VolumeRow;
        if (!self || self.usageKey === "") {
            return true;
        }
        for (let i = 0; i < volumeRows.count; i++) {
            const other = volumeRows.itemAt(i) as VolumeRow;
            if (i === index || !other || other.usageKey !== self.usageKey) {
                continue;
            }
            const shorter = other.displayName.length < self.displayName.length;
            const tie = other.displayName.length === self.displayName.length && i < index;
            if (shorter || tie) {
                return false;
            }
        }
        return true;
    }

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
        value: page.stats.rate(page.stats.diskReadRate)
        active: false
    }
    SensorRow {
        label: i18n("Write")
        value: page.stats.rate(page.stats.diskWriteRate)
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

    SensorSearch {
        id: volumes
        tree: page.stats.sensorTree
        pattern: /^disk\/(?!all\/)[\w.:-]+\/usedPercent$/
        active: page.active
    }

    SectionLabel {
        visible: volumes.matches.length > 0
        text: i18n("Volumes")
    }

    Repeater {
        id: volumeRows
        model: volumes.matches

        VolumeRow {
            required property string modelData
            required property int index

            visible: page.isPreferred(index)
            device: modelData.split("/")[1]
            active: page.active
            Layout.fillWidth: true
            Layout.bottomMargin: Kirigami.Units.smallSpacing
        }
    }

    TopProcesses {
        attributes: ["ioCharactersActuallyReadRate", "ioCharactersActuallyWrittenRate"]
        format: value => page.stats.rate(value)
        active: page.active
        interval: page.stats.interval
        Layout.fillWidth: true
    }
}
