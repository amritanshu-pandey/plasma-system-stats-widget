import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

Item {
    id: compact

    property Stats stats
    readonly property bool vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical

    signal activated(string module)

    Layout.minimumWidth: vertical ? 0 : grid.implicitWidth
    Layout.preferredWidth: vertical ? -1 : grid.implicitWidth
    Layout.maximumWidth: vertical ? Infinity : grid.implicitWidth
    Layout.minimumHeight: vertical ? grid.implicitHeight : 0
    Layout.preferredHeight: vertical ? grid.implicitHeight : -1
    Layout.maximumHeight: vertical ? grid.implicitHeight : Infinity

    GridLayout {
        id: grid
        anchors.fill: parent
        flow: compact.vertical ? GridLayout.TopToBottom : GridLayout.LeftToRight
        rows: compact.vertical ? -1 : 1
        columns: compact.vertical ? 1 : -1
        columnSpacing: Kirigami.Units.largeSpacing
        rowSpacing: Kirigami.Units.smallSpacing

        CompactItem {
            visible: Plasmoid.configuration.showCpu
            label: i18n("CPU")
            text: compact.stats.percent(compact.stats.cpu.value)
            sample: "100%"
            values: compact.stats.cpuHistory.values
            maximum: 100
            size: compact.stats.historyLength
            showLabel: Plasmoid.configuration.showLabels
            showGraph: Plasmoid.configuration.showGraphs && !compact.vertical
            onClicked: compact.activated("cpu")
        }

        CompactItem {
            visible: Plasmoid.configuration.showMemory
            label: i18n("RAM")
            text: compact.stats.percent(compact.stats.memory.value)
            sample: "100%"
            values: compact.stats.memoryHistory.values
            maximum: 100
            size: compact.stats.historyLength
            showLabel: Plasmoid.configuration.showLabels
            showGraph: Plasmoid.configuration.showGraphs && !compact.vertical
            onClicked: compact.activated("memory")
        }

        CompactItem {
            visible: Plasmoid.configuration.showDisk
            label: i18n("DISK")
            text: "R " + compact.stats.rate(compact.stats.diskRead.value)
            secondText: "W " + compact.stats.rate(compact.stats.diskWrite.value)
            sample: "W 999 kB/s"
            values: compact.stats.diskReadHistory.values
            secondValues: compact.stats.diskWriteHistory.values
            size: compact.stats.historyLength
            showLabel: Plasmoid.configuration.showLabels
            showGraph: Plasmoid.configuration.showGraphs && !compact.vertical
            onClicked: compact.activated("disk")
        }

        CompactItem {
            visible: Plasmoid.configuration.showNetwork
            label: i18n("NET")
            text: "↓ " + compact.stats.rate(compact.stats.download.value)
            secondText: "↑ " + compact.stats.rate(compact.stats.upload.value)
            sample: "↓ 999 kB/s"
            values: compact.stats.downloadHistory.values
            secondValues: compact.stats.uploadHistory.values
            size: compact.stats.historyLength
            showLabel: Plasmoid.configuration.showLabels
            showGraph: Plasmoid.configuration.showGraphs && !compact.vertical
            onClicked: compact.activated("network")
        }
    }
}
