import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

ColumnLayout {
    id: page

    property Stats stats
    property bool active

    spacing: Kirigami.Units.smallSpacing

    SensorSearch {
        id: interfaces
        tree: page.stats.sensorTree
        pattern: /^network\/(?!all\/)[\w.:-]+\/network$/
        active: page.active
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
        value: page.stats.networkRate(page.stats.download.value)
        active: false
    }
    SensorRow {
        label: i18n("Upload")
        value: page.stats.networkRate(page.stats.upload.value)
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
        model: interfaces.matches

        NetworkInterface {
            required property string modelData

            device: modelData.split("/")[1]
            stats: page.stats
            active: page.active
            Layout.fillWidth: true
        }
    }
}
