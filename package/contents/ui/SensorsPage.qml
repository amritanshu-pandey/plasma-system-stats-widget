import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

ColumnLayout {
    id: page

    property Stats stats
    property bool active

    // Sensors grouped by chip: [{ chip, ids }]
    function group(ids) {
        const groups = [];
        for (const id of ids) {
            const chip = id.split("/")[1];
            let entry = groups.find(g => g.chip === chip);
            if (!entry) {
                entry = { chip: chip, ids: [] };
                groups.push(entry);
            }
            entry.ids.push(id);
        }
        return groups;
    }

    spacing: Kirigami.Units.smallSpacing

    SensorSearch {
        id: temperatures
        tree: page.stats.sensorTree
        pattern: /^(lmsensors\/[\w.:-]+\/temp\d+|gpu\/gpu\d+\/temperature)$/
        active: page.active
        interval: 30000
    }
    SensorSearch {
        id: fans
        tree: page.stats.sensorTree
        pattern: /^lmsensors\/[\w.:-]+\/fan\d+$/
        active: page.active
        interval: 30000
    }

    PageHeader {
        title: i18n("Sensors")
        subtitle: i18n("CPU temperature")
        value: page.stats.celsius(page.stats.temperature.value)
    }

    MiniGraph {
        Layout.fillWidth: true
        Layout.preferredHeight: Kirigami.Units.gridUnit * 4
        values: page.stats.temperatureHistory.values
        size: page.stats.historyLength
        maximum: 100
    }

    Repeater {
        model: page.group(temperatures.matches)

        ColumnLayout {
            required property var modelData

            spacing: Kirigami.Units.smallSpacing
            Layout.fillWidth: true

            SectionLabel {
                text: modelData.chip
            }

            Repeater {
                model: modelData.ids

                SensorRow {
                    id: row
                    required property string modelData

                    sensorId: modelData
                    label: row.sensor.name
                    active: page.active
                    hideWhenEmpty: true
                }
            }
        }
    }

    SectionLabel {
        visible: fans.matches.length > 0
        text: i18n("Fans")
    }

    Repeater {
        model: fans.matches

        SensorRow {
            id: fan
            required property string modelData

            sensorId: modelData
            label: fan.sensor.name
            active: page.active
        }
    }
}
