import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.ksysguard.sensors as Sensors

RowLayout {
    id: row

    property alias label: name.text
    property alias sensorId: sensor.sensorId
    property alias active: sensor.enabled
    property string value: sensor.formattedValue
    property bool hideWhenEmpty: false
    readonly property alias sensor: sensor

    visible: !hideWhenEmpty || (typeof sensor.value === "number" ? sensor.value > 0 : !!sensor.value)
    Layout.fillWidth: true

    Sensors.Sensor {
        id: sensor
    }

    PlasmaComponents.Label {
        id: name
        opacity: 0.7
        Layout.fillWidth: true
        elide: Text.ElideRight
    }

    PlasmaComponents.Label {
        text: row.value
    }
}
