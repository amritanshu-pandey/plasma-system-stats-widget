import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.ksysguard.sensors as Sensors

ColumnLayout {
    id: page

    property Stats stats
    property bool active
    property var devices: []

    spacing: Kirigami.Units.smallSpacing

    // Find network devices by walking the sensor tree for network/<device>/network sensors.
    function findDevices() {
        const found = [];
        const walk = parent => {
            for (let row = 0; row < sensorTree.rowCount(parent); row++) {
                const index = sensorTree.index(row, 0, parent);
                const match = /^network\/([\w.:-]+)\/network$/.exec(sensorTree.data(index, Sensors.SensorTreeModel.SensorId) || "");
                if (match && match[1] !== "all") {
                    found.push(match[1]);
                }
                walk(index);
            }
        };
        walk(sensorTree.index(-1, -1));
        found.sort();
        if (found.join() !== devices.join()) {
            devices = found;
        }
    }

    Sensors.SensorTreeModel {
        id: sensorTree
    }

    Timer {
        interval: 5000
        running: page.active
        repeat: true
        triggeredOnStart: true
        onTriggered: page.findDevices()
    }

    PageHeader {
        title: i18n("Network")
    }

    MiniGraph {
        Layout.fillWidth: true
        Layout.preferredHeight: Kirigami.Units.gridUnit * 4
        values: page.stats.downloadHistory.values
        secondValues: page.stats.uploadHistory.values
        size: page.stats.historyLength
    }

    RowLayout {
        spacing: Kirigami.Units.largeSpacing

        Legend {
            color: Kirigami.Theme.highlightColor
            text: i18n("Download")
        }
        Legend {
            color: Kirigami.Theme.negativeTextColor
            text: i18n("Upload")
        }
    }

    SensorRow {
        label: i18n("Download")
        value: page.stats.rate(page.stats.download.value)
        active: false
    }
    SensorRow {
        label: i18n("Upload")
        value: page.stats.rate(page.stats.upload.value)
        active: false
    }
    SensorRow {
        label: i18n("Total downloaded")
        sensorId: "network/all/totalDownload"
        active: page.active
    }
    SensorRow {
        label: i18n("Total uploaded")
        sensorId: "network/all/totalUpload"
        active: page.active
    }

    Repeater {
        model: page.devices

        NetworkInterface {
            required property string modelData

            device: modelData
            stats: page.stats
            active: page.active
            Layout.fillWidth: true
        }
    }
}
