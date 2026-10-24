import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.ksysguard.process as Process

ColumnLayout {
    id: list

    // Process attribute used for sorting and display, for example "usage" or "vmPSS".
    property string attribute
    property bool active
    property int count: 5
    property int interval: 2000

    property var rows: []

    spacing: Kirigami.Units.smallSpacing

    function refresh() {
        const nameColumn = processes.enabledAttributes.indexOf("name");
        const valueColumn = processes.enabledAttributes.indexOf(list.attribute);
        if (nameColumn < 0 || valueColumn < 0) {
            return;
        }

        const ranked = [];
        for (let row = 0; row < processes.rowCount(); row++) {
            const value = processes.data(processes.index(row, valueColumn), Process.ProcessDataModel.Value);
            if (value > 0) {
                ranked.push({ row: row, value: value });
            }
        }
        ranked.sort((a, b) => b.value - a.value);

        rows = ranked.slice(0, list.count).map(entry => ({
            // Some programs, like Chrome, put their arguments in the process name.
            name: String(processes.data(processes.index(entry.row, nameColumn), Qt.DisplayRole)).split(" --")[0],
            value: processes.data(processes.index(entry.row, valueColumn), Process.ProcessDataModel.FormattedValue),
        }));
    }

    Process.ProcessDataModel {
        id: processes
        enabled: list.active
        flatList: true
        enabledAttributes: ["name", list.attribute]
    }

    Timer {
        interval: list.interval
        running: list.active
        repeat: true
        triggeredOnStart: true
        onTriggered: list.refresh()
    }

    PlasmaComponents.Label {
        text: i18n("Top processes")
        opacity: 0.7
        Layout.topMargin: Kirigami.Units.smallSpacing
    }

    Repeater {
        model: list.rows

        RowLayout {
            required property var modelData

            spacing: Kirigami.Units.smallSpacing
            Layout.fillWidth: true

            PlasmaComponents.Label {
                text: modelData.name
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
            PlasmaComponents.Label {
                text: modelData.value
            }
        }
    }
}
