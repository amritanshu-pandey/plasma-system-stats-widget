pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.ksysguard.sensors as Sensors

ColumnLayout {
    id: page

    property Stats stats
    property bool active

    spacing: Kirigami.Units.smallSpacing

    Sensors.Sensor {
        id: name
        sensorId: page.stats.gpus.length === 1 ? "gpu/%1/name".arg(page.stats.gpus[0]) : ""
        enabled: page.active
    }

    PageHeader {
        title: i18n("GPU")
        // Skip generic names like "GPU 1".
        subtitle: page.stats.gpus.length > 1 ? i18np("%1 GPU", "%1 GPUs", page.stats.gpus.length)
                : /^\S+ \d+$/.test(name.value || "") ? "" : (name.value || "")
        value: page.stats.percent(page.stats.gpu.value)
    }

    MiniGraph {
        Layout.fillWidth: true
        Layout.preferredHeight: Kirigami.Units.gridUnit * 4
        values: page.stats.gpuHistory.values
        secondValues: page.stats.gpuMemoryHistory.values
        secondColor: Qt.alpha(Kirigami.Theme.textColor, 0.6)
        size: page.stats.historyLength
        maximum: 100
    }

    RowLayout {
        spacing: Kirigami.Units.largeSpacing

        Legend {
            color: Kirigami.Theme.highlightColor
            text: i18n("Usage")
        }
        Legend {
            color: Qt.alpha(Kirigami.Theme.textColor, 0.6)
            text: i18n("Video memory")
        }
    }

    Repeater {
        model: page.stats.gpus

        GpuInfo {
            required property string modelData

            device: modelData
            active: page.active
            showName: page.stats.gpus.length > 1
            Layout.fillWidth: true
        }
    }
}
