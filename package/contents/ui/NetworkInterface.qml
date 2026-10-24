import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.ksysguard.sensors as Sensors

ColumnLayout {
    id: iface

    property string device
    property Stats stats
    property bool active

    spacing: Kirigami.Units.smallSpacing

    Sensors.Sensor {
        id: networkName
        sensorId: "network/%1/network".arg(iface.device)
        enabled: iface.active
    }

    PlasmaComponents.Label {
        text: networkName.value && networkName.value !== iface.device
            ? i18nc("network name (device)", "%1 (%2)", networkName.value, iface.device)
            : iface.device
        font.bold: true
        elide: Text.ElideRight
        Layout.fillWidth: true
        Layout.topMargin: Kirigami.Units.smallSpacing
    }

    SensorRow {
        id: download
        label: i18n("Download")
        sensorId: "network/%1/download".arg(iface.device)
        value: iface.stats.rate(download.sensor.value)
        active: iface.active
    }
    SensorRow {
        id: upload
        label: i18n("Upload")
        sensorId: "network/%1/upload".arg(iface.device)
        value: iface.stats.rate(upload.sensor.value)
        active: iface.active
    }
    SensorRow {
        label: i18n("Signal")
        sensorId: "network/%1/signal".arg(iface.device)
        active: iface.active
        hideWhenEmpty: true
    }
    SensorRow {
        label: i18n("IPv4 address")
        sensorId: "network/%1/ipv4withPrefixLength".arg(iface.device)
        active: iface.active
        hideWhenEmpty: true
    }
    SensorRow {
        label: i18n("Gateway")
        sensorId: "network/%1/ipv4gateway".arg(iface.device)
        active: iface.active
        hideWhenEmpty: true
    }
    SensorRow {
        label: i18n("IPv6 address")
        sensorId: "network/%1/ipv6address".arg(iface.device)
        active: iface.active
        hideWhenEmpty: true
    }
}
