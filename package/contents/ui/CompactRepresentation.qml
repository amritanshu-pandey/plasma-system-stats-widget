import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

Item {
    id: compact

    property Stats stats
    readonly property bool vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
    readonly property bool compactMode: Plasmoid.configuration.compactMode
    readonly property int spacing: Plasmoid.configuration.moduleSpacing
    readonly property int padding: Plasmoid.configuration.verticalPadding
    readonly property var modules: Array.from(Plasmoid.configuration.panelModules)
        .filter(module => module !== "battery" || stats.hasBattery)
    readonly property bool showGraph: Plasmoid.configuration.showGraphs && !vertical
    readonly property bool showLabel: Plasmoid.configuration.showLabels

    signal activated(string module)

    Layout.minimumWidth: vertical ? 0 : grid.implicitWidth + spacing
    Layout.preferredWidth: vertical ? -1 : grid.implicitWidth + spacing
    Layout.maximumWidth: vertical ? Infinity : grid.implicitWidth + spacing
    Layout.minimumHeight: vertical ? grid.implicitHeight + spacing : 0
    Layout.preferredHeight: vertical ? grid.implicitHeight + spacing : -1
    Layout.maximumHeight: vertical ? grid.implicitHeight + spacing : Infinity

    GridLayout {
        id: grid
        anchors.fill: parent
        anchors.leftMargin: compact.vertical ? compact.padding : compact.spacing / 2
        anchors.rightMargin: compact.vertical ? compact.padding : compact.spacing / 2
        anchors.topMargin: compact.vertical ? compact.spacing / 2 : 0
        anchors.bottomMargin: compact.vertical ? compact.spacing / 2 : 0
        flow: compact.vertical ? GridLayout.TopToBottom : GridLayout.LeftToRight
        rows: compact.vertical ? -1 : 1
        columns: compact.vertical ? 1 : -1
        columnSpacing: compact.spacing
        rowSpacing: compact.spacing

        Repeater {
            model: compact.modules

            Loader {
                required property string modelData

                Layout.fillHeight: !compact.vertical
                Layout.fillWidth: compact.vertical
                sourceComponent: ({
                    cpu: cpuItem,
                    memory: memoryItem,
                    disk: diskItem,
                    network: networkItem,
                    sensors: sensorsItem,
                    battery: batteryItem,
                })[modelData] ?? null

                Connections {
                    target: item
                    ignoreUnknownSignals: true
                    function onClicked() {
                        compact.activated(modelData);
                    }
                }
            }
        }

        Kirigami.Icon {
            visible: compact.modules.length === 0
            source: Plasmoid.icon
            Layout.fillWidth: compact.vertical
            Layout.fillHeight: !compact.vertical
            Layout.preferredWidth: compact.vertical ? -1 : height
            Layout.preferredHeight: compact.vertical ? width : -1

            TapHandler {
                onTapped: compact.activated("cpu")
            }
        }
    }

    Component {
        id: cpuItem
        CompactItem {
            label: i18n("CPU")
            text: compact.stats.percent(compact.stats.cpu.value)
            sample: "100%"
            values: compact.stats.cpuHistory.values
            maximum: 100
            size: compact.stats.historyLength
            compactMode: compact.compactMode
            showLabel: compact.showLabel
            showGraph: compact.showGraph
            graphPadding: compact.vertical ? 0 : compact.padding
        }
    }

    Component {
        id: memoryItem
        CompactItem {
            label: i18n("RAM")
            text: compact.stats.percent(compact.stats.memory.value)
            sample: "100%"
            values: compact.stats.memoryHistory.values
            maximum: 100
            size: compact.stats.historyLength
            compactMode: compact.compactMode
            showLabel: compact.showLabel
            showGraph: compact.showGraph
            graphPadding: compact.vertical ? 0 : compact.padding
        }
    }

    Component {
        id: diskItem
        CompactItem {
            label: i18n("DISK")
            text: "R " + compact.stats.rate(compact.stats.diskRead.value)
            secondText: "W " + compact.stats.rate(compact.stats.diskWrite.value)
            sample: "W 999 kB/s"
            values: compact.stats.diskReadHistory.values
            secondValues: compact.stats.diskWriteHistory.values
            size: compact.stats.historyLength
            compactMode: compact.compactMode
            showLabel: compact.showLabel
            showGraph: compact.showGraph
            graphPadding: compact.vertical ? 0 : compact.padding
        }
    }

    Component {
        id: networkItem
        CompactItem {
            label: i18n("NET")
            text: "↓ " + compact.stats.networkRate(compact.stats.download.value)
            secondText: "↑ " + compact.stats.networkRate(compact.stats.upload.value)
            sample: compact.stats.networkBits ? "↓ 999 Mb/s" : "↓ 999 kB/s"
            values: compact.stats.downloadHistory.values
            secondValues: compact.stats.uploadHistory.values
            size: compact.stats.historyLength
            compactMode: compact.compactMode
            showLabel: compact.showLabel
            showGraph: compact.showGraph
            graphPadding: compact.vertical ? 0 : compact.padding
        }
    }

    Component {
        id: sensorsItem
        CompactItem {
            label: i18n("TEMP")
            text: compact.stats.celsius(compact.stats.temperature.value)
            sample: "100°C"
            values: compact.stats.temperatureHistory.values
            maximum: 100
            size: compact.stats.historyLength
            compactMode: compact.compactMode
            showLabel: compact.showLabel
            showGraph: compact.showGraph
            graphPadding: compact.vertical ? 0 : compact.padding
        }
    }

    Component {
        id: batteryItem
        CompactItem {
            readonly property int level: Math.round(compact.stats.battery.value || 0)

            label: i18n("BAT")
            text: compact.stats.percent(compact.stats.battery.value)
            sample: "100%"
            iconName: "battery-%1%2".arg(String(Math.round(level / 10) * 10).padStart(3, "0"))
                                    .arg(compact.stats.charging ? "-charging" : "")
            compactMode: compact.compactMode
            showLabel: compact.showLabel && compact.compactMode
            showGraph: false
        }
    }
}
