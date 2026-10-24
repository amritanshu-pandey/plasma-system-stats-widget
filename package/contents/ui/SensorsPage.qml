pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

import "names.js" as Names

ColumnLayout {
    id: page

    property Stats stats
    property bool active

    // Groups sensors by chip, sorted by importance. Chips with one sensor are
    // returned as single rows named after the chip; the rest as titled groups.
    function arrange(ids, names) {
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
        groups.sort((a, b) => Names.chipRank(a.chip) - Names.chipRank(b.chip)
                              || a.chip.localeCompare(b.chip, undefined, { numeric: true }));

        const chipNames = Names.chipNames(groups.map(g => g.chip));
        const singles = [];
        const multiples = [];
        groups.forEach((g, i) => {
            if (g.ids.length === 1) {
                singles.push({ id: g.ids[0], label: chipNames[i] });
            } else {
                const labels = Names.sensorNames(g.ids.map(id => names[id]));
                multiples.push({ name: chipNames[i], rows: g.ids.map((id, j) => ({ id: id, label: labels[j] })) });
            }
        });
        return { singles: singles, groups: multiples };
    }

    readonly property var temperatureLayout: arrange(temperatures.matches, temperatures.names)
    // Fans are named by sensor, with the chip name added when fans come from several chips.
    readonly property var fanRows: {
        const chips = fans.matches.map(id => id.split("/")[1]);
        const unique = chips.filter((chip, i) => chips.indexOf(chip) === i);
        const chipNames = Names.chipNames(unique);
        const rows = [];
        unique.forEach((chip, i) => {
            const ids = fans.matches.filter(id => id.split("/")[1] === chip);
            const labels = Names.sensorNames(ids.map(id => fans.names[id]));
            ids.forEach((id, j) => rows.push({
                id: id,
                label: unique.length > 1 ? chipNames[i] + " – " + labels[j] : labels[j],
            }));
        });
        return rows;
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

    SectionLabel {
        visible: page.temperatureLayout.singles.length > 0
        text: i18n("Components")
    }

    Repeater {
        model: page.temperatureLayout.singles

        TemperatureRow {
            required property var modelData

            sensorId: modelData.id
            label: modelData.label
            active: page.active
        }
    }

    Repeater {
        model: page.temperatureLayout.groups

        ColumnLayout {
            id: chipGroup

            required property var modelData

            spacing: Kirigami.Units.smallSpacing
            Layout.fillWidth: true

            SectionLabel {
                text: chipGroup.modelData.name
            }

            Repeater {
                model: chipGroup.modelData.rows

                TemperatureRow {
                    required property var modelData

                    sensorId: modelData.id
                    label: modelData.label
                    active: page.active
                }
            }
        }
    }

    SectionLabel {
        visible: fans.matches.length > 0
        text: i18n("Fans")
    }

    Repeater {
        model: page.fanRows

        TemperatureRow {
            required property var modelData

            sensorId: modelData.id
            label: modelData.label
            active: page.active
            temperature: false
        }
    }
}
