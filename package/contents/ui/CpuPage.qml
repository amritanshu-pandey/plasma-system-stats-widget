import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.ksysguard.sensors as Sensors

ColumnLayout {
    id: page

    property Stats stats
    property bool active

    spacing: Kirigami.Units.smallSpacing

    Sensors.Sensor {
        id: coreCount
        sensorId: "cpu/all/coreCount"
        enabled: page.active
    }

    PageHeader {
        title: i18n("CPU")
        subtitle: coreCount.value ? i18np("%1 core", "%1 cores", coreCount.value) : ""
        value: page.stats.percent(page.stats.cpu.value)
    }

    MiniGraph {
        Layout.fillWidth: true
        Layout.preferredHeight: Kirigami.Units.gridUnit * 4
        values: page.stats.cpuHistory.values
        size: page.stats.historyLength
        maximum: 100
    }

    SensorRow {
        label: i18n("User")
        sensorId: "cpu/all/user"
        active: page.active
    }
    SensorRow {
        label: i18n("System")
        sensorId: "cpu/all/system"
        active: page.active
    }
    SensorRow {
        label: i18n("Wait")
        sensorId: "cpu/all/wait"
        active: page.active
    }
    SensorRow {
        label: i18n("Frequency")
        sensorId: "cpu/all/averageFrequency"
        active: page.active
    }
    SensorRow {
        label: i18n("Temperature")
        sensorId: "cpu/all/averageTemperature"
        active: page.active
        hideWhenZero: true
    }

    PlasmaComponents.Label {
        text: i18n("Cores")
        opacity: 0.7
        Layout.topMargin: Kirigami.Units.smallSpacing
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: Kirigami.Units.gridUnit * 3
        spacing: 2

        Repeater {
            model: page.active ? (coreCount.value || 0) : 0

            Item {
                id: bar

                required property int index

                Layout.fillWidth: true
                Layout.fillHeight: true

                Sensors.Sensor {
                    id: core
                    sensorId: "cpu/cpu%1/usage".arg(bar.index)
                }

                Rectangle {
                    anchors.fill: parent
                    radius: 2
                    color: Kirigami.Theme.textColor
                    opacity: 0.1
                }
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: parent.height * Math.min(core.value || 0, 100) / 100
                    radius: 2
                    color: Kirigami.Theme.highlightColor
                }
            }
        }
    }
}
