import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

ColumnLayout {
    id: full

    property Stats stats
    property var modules: []
    property string currentModule
    property bool active

    readonly property var allModules: ["cpu", "memory", "disk", "network"]
    readonly property var titles: ({
        cpu: i18n("CPU"),
        memory: i18n("Memory"),
        disk: i18n("Disk"),
        network: i18n("Network"),
    })

    signal moduleSelected(string module)

    Layout.minimumWidth: Kirigami.Units.gridUnit * 20
    Layout.preferredWidth: Kirigami.Units.gridUnit * 20
    Layout.minimumHeight: implicitHeight
    Layout.preferredHeight: implicitHeight
    spacing: Kirigami.Units.largeSpacing

    PlasmaComponents.TabBar {
        id: tabs
        visible: full.modules.length > 1
        Layout.fillWidth: true

        Binding on currentIndex {
            value: full.modules.indexOf(full.currentModule)
        }

        Repeater {
            model: full.modules

            PlasmaComponents.TabButton {
                required property string modelData
                text: full.titles[modelData]
                onClicked: full.moduleSelected(modelData)
            }
        }
    }

    StackLayout {
        Layout.fillWidth: true
        currentIndex: full.allModules.indexOf(full.currentModule)

        CpuPage {
            stats: full.stats
            active: full.active && StackLayout.isCurrentItem
        }
        MemoryPage {
            stats: full.stats
            active: full.active && StackLayout.isCurrentItem
        }
        DiskPage {
            stats: full.stats
            active: full.active && StackLayout.isCurrentItem
        }
        NetworkPage {
            stats: full.stats
            active: full.active && StackLayout.isCurrentItem
        }
    }
}
