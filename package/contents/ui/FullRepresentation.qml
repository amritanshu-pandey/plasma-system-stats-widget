pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

ColumnLayout {
    id: full

    property Stats stats
    property string currentModule
    property bool active

    readonly property var modules: ["cpu", "memory"]
        .concat(stats.hasGpu ? ["gpu"] : [])
        .concat(["disk", "network", "sensors"])
        .concat(stats.hasBattery ? ["battery"] : [])
    readonly property var titles: ({
        cpu: i18n("CPU"),
        memory: i18n("Memory"),
        gpu: i18n("GPU"),
        disk: i18n("Disk"),
        network: i18n("Network"),
        sensors: i18n("Sensors"),
        battery: i18n("Battery"),
    })

    // Wide enough for every tab title on one line.
    readonly property real popupWidth: Math.max(Kirigami.Units.gridUnit * 24,
        modules.length * (Math.max(...modules.map(m => tabMetrics.advanceWidth(titles[m]))) + Kirigami.Units.gridUnit * 1.5))

    signal moduleSelected(string module)

    Layout.minimumWidth: popupWidth
    Layout.preferredWidth: popupWidth
    Layout.preferredHeight: tabs.implicitHeight + spacing + Math.min(pages.implicitHeight, Kirigami.Units.gridUnit * 30)
    spacing: Kirigami.Units.largeSpacing

    FontMetrics {
        id: tabMetrics
        font: Kirigami.Theme.defaultFont
    }

    PlasmaComponents.TabBar {
        id: tabs
        Layout.fillWidth: true

        Binding on currentIndex {
            value: full.modules.indexOf(full.currentModule)
        }

        Repeater {
            model: full.modules

            PlasmaComponents.TabButton {
                required property string modelData
                width: tabs.width / full.modules.length
                text: full.titles[modelData]
                onClicked: full.moduleSelected(modelData)
            }
        }
    }

    PlasmaComponents.ScrollView {
        id: scroll
        Layout.fillWidth: true
        Layout.fillHeight: true
        contentWidth: availableWidth
        PlasmaComponents.ScrollBar.horizontal.policy: PlasmaComponents.ScrollBar.AlwaysOff

        readonly property var verticalBar: PlasmaComponents.ScrollBar.vertical

        ColumnLayout {
            id: pages
            width: scroll.availableWidth - (scroll.verticalBar.visible ? scroll.verticalBar.width + Kirigami.Units.smallSpacing : 0)
            spacing: 0

            CpuPage {
                visible: full.currentModule === "cpu"
                stats: full.stats
                active: full.active && visible
                Layout.fillWidth: true
            }
            MemoryPage {
                visible: full.currentModule === "memory"
                stats: full.stats
                active: full.active && visible
                Layout.fillWidth: true
            }
            GpuPage {
                visible: full.currentModule === "gpu"
                stats: full.stats
                active: full.active && visible
                Layout.fillWidth: true
            }
            DiskPage {
                visible: full.currentModule === "disk"
                stats: full.stats
                active: full.active && visible
                Layout.fillWidth: true
            }
            NetworkPage {
                visible: full.currentModule === "network"
                stats: full.stats
                active: full.active && visible
                Layout.fillWidth: true
            }
            SensorsPage {
                visible: full.currentModule === "sensors"
                stats: full.stats
                active: full.active && visible
                Layout.fillWidth: true
            }
            BatteryPage {
                visible: full.currentModule === "battery"
                stats: full.stats
                active: full.active && visible
                Layout.fillWidth: true
            }
        }
    }
}
