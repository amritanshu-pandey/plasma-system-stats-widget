import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

ColumnLayout {
    id: page

    property Stats stats
    property bool active

    property string publicIpv4
    property string publicIpv6
    property real publicIpTime: 0

    spacing: Kirigami.Units.smallSpacing

    function lookUp(url, done) {
        const request = new XMLHttpRequest();
        request.onreadystatechange = () => {
            if (request.readyState === XMLHttpRequest.DONE) {
                const text = request.status === 200 ? request.responseText.trim() : "";
                done(/^[0-9a-f:.]+$/i.test(text) ? text : "");
            }
        };
        request.open("GET", url);
        request.send();
    }

    function refreshPublicIp() {
        if (Date.now() - publicIpTime < 10 * 60 * 1000) {
            return;
        }
        publicIpTime = Date.now();
        lookUp("https://api.ipify.org", ip => publicIpv4 = ip);
        lookUp("https://api6.ipify.org", ip => publicIpv6 = ip);
    }

    Timer {
        interval: 60 * 1000
        running: page.active && page.stats.showPublicIp
        repeat: true
        triggeredOnStart: true
        onTriggered: page.refreshPublicIp()
    }

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
    SensorRow {
        label: i18n("Public IPv4 address")
        value: page.publicIpv4
        active: false
        visible: page.stats.showPublicIp && page.publicIpv4 !== ""
    }
    SensorRow {
        label: i18n("Public IPv6 address")
        value: page.publicIpv6
        active: false
        visible: page.stats.showPublicIp && page.publicIpv6 !== ""
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
