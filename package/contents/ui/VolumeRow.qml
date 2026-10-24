import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.ksysguard.sensors as Sensors

ColumnLayout {
    id: volume

    property string device
    property bool active

    spacing: 2

    Sensors.Sensor {
        id: name
        sensorId: "disk/%1/name".arg(volume.device)
        enabled: volume.active
    }
    Sensors.Sensor {
        id: usedPercent
        sensorId: "disk/%1/usedPercent".arg(volume.device)
        enabled: volume.active
    }
    Sensors.Sensor {
        id: used
        sensorId: "disk/%1/used".arg(volume.device)
        enabled: volume.active
    }
    Sensors.Sensor {
        id: total
        sensorId: "disk/%1/total".arg(volume.device)
        enabled: volume.active
    }

    RowLayout {
        Layout.fillWidth: true

        PlasmaComponents.Label {
            text: name.value || volume.device
            elide: Text.ElideRight
            Layout.fillWidth: true
        }
        PlasmaComponents.Label {
            text: i18n("%1 of %2", used.formattedValue, total.formattedValue)
            opacity: 0.7
        }
    }

    UsageBar {
        value: usedPercent.value || 0
    }
}
