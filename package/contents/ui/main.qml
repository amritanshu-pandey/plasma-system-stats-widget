import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore

PlasmoidItem {
    id: root

    property string currentModule: "cpu"

    function toggle(module) {
        if (expanded && currentModule === module) {
            expanded = false;
        } else {
            currentModule = module;
            expanded = true;
        }
    }

    Plasmoid.icon: "utilities-system-monitor"
    preferredRepresentation: Plasmoid.formFactor === PlasmaCore.Types.Planar ? fullRepresentation : compactRepresentation

    toolTipSubText: [
        i18n("CPU: %1", monitor.percent(monitor.cpu.value)),
        i18n("Memory: %1", monitor.percent(monitor.memory.value)),
        i18n("Disk: %1 read, %2 write", monitor.rate(monitor.diskRead.value), monitor.rate(monitor.diskWrite.value)),
        i18n("Network: %1 down, %2 up", monitor.rate(monitor.download.value), monitor.rate(monitor.upload.value)),
    ].join("\n")

    Stats {
        id: monitor
        interval: Plasmoid.configuration.updateInterval * 1000
    }

    compactRepresentation: CompactRepresentation {
        stats: monitor
        onActivated: module => root.toggle(module)
    }

    fullRepresentation: FullRepresentation {
        stats: monitor
        currentModule: root.currentModule
        active: root.expanded || Plasmoid.formFactor === PlasmaCore.Types.Planar
        onModuleSelected: module => root.currentModule = module
    }
}
