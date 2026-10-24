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
        i18n("Network: %1 down, %2 up", monitor.networkRate(monitor.download.value), monitor.networkRate(monitor.upload.value)),
    ].concat(monitor.temperature.value > 0 ? [i18n("Temperature: %1", monitor.celsius(monitor.temperature.value))] : [])
     .concat(monitor.hasBattery ? [i18n("Battery: %1", monitor.percent(monitor.battery.value))] : [])
     .join("\n")

    Stats {
        id: monitor
        interval: Plasmoid.configuration.updateInterval * 1000
        networkBits: Plasmoid.configuration.networkBits
        temperatureSensor: Plasmoid.configuration.temperatureSensor
        showPublicIp: Plasmoid.configuration.showPublicIp
    }

    compactRepresentation: CompactRepresentation {
        stats: monitor
        onActivated: module => root.toggle(module)
    }

    fullRepresentation: FullRepresentation {
        stats: monitor
        currentModule: root.currentModule === "battery" && !monitor.hasBattery ? "cpu" : root.currentModule
        active: root.expanded || Plasmoid.formFactor === PlasmaCore.Types.Planar
        onModuleSelected: module => root.currentModule = module
    }
}
