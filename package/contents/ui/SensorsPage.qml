import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

import "names.js" as Names

ColumnLayout {
    id: page

    property Stats stats
    property bool active

    // Sensors grouped by chip: [{ chip, name, ids, labels }]
    function group(ids, names) {
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
        const chipNames = Names.chipNames(groups.map(g => g.chip));
        groups.forEach((g, i) => {
            g.name = chipNames[i];
            g.labels = Names.sensorNames(g.ids.map(id => names[id]));
        });
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
        subtitle: Names.sensorName(page.stats.temperature.name)
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
        model: page.group(temperatures.matches, temperatures.names)

        ColumnLayout {
            id: chipGroup
            required property var modelData

            spacing: Kirigami.Units.smallSpacing
            Layout.fillWidth: true

            SectionLabel {
                text: modelData.name
            }

            Repeater {
                model: modelData.ids

                SensorRow {
                    required property string modelData
                    required property int index

                    sensorId: modelData
                    label: chipGroup.modelData.labels[index]
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
            required property string modelData
            required property int index

            sensorId: modelData
            label: Names.sensorNames(fans.matches.map(id => fans.names[id]))[index]
            active: page.active
        }
    }
}
