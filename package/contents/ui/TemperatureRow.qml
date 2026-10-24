import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.ksysguard.sensors as Sensors

RowLayout {
    id: row

    property alias sensorId: sensor.sensorId
    property alias active: sensor.enabled
    property string label
    // Temperatures show a 0–100 °C bar and are hidden while they read 0.
    property bool temperature: true

    readonly property real value: sensor.value || 0
    readonly property bool hot: temperature && value >= 85
    readonly property bool warm: temperature && value >= 70

    visible: !temperature || value > 0
    spacing: Kirigami.Units.largeSpacing
    Layout.fillWidth: true

    Sensors.Sensor {
        id: sensor
    }

    PlasmaComponents.Label {
        text: row.label
        opacity: 0.7
        elide: Text.ElideRight
        Layout.fillWidth: true
    }

    UsageBar {
        visible: row.temperature
        value: row.value
        warning: row.hot
        Layout.fillWidth: false
        Layout.preferredWidth: Kirigami.Units.gridUnit * 5
        Layout.alignment: Qt.AlignVCenter
    }

    PlasmaComponents.Label {
        text: !row.temperature && row.value === 0 ? i18nc("fan is stopped", "Off") : sensor.formattedValue
        color: row.hot ? Kirigami.Theme.negativeTextColor
             : row.warm ? Kirigami.Theme.neutralTextColor
             : Kirigami.Theme.textColor
        horizontalAlignment: Text.AlignRight
        Layout.preferredWidth: metrics.advanceWidth
    }

    TextMetrics {
        id: metrics
        text: row.temperature ? "100.0 °C" : "10000 RPM"
    }
}
