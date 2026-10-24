import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    property alias cfg_showCpu: showCpu.checked
    property alias cfg_showMemory: showMemory.checked
    property alias cfg_showDisk: showDisk.checked
    property alias cfg_showNetwork: showNetwork.checked
    property alias cfg_compactMode: compactMode.checked
    property alias cfg_showGraphs: showGraphs.checked
    property alias cfg_showLabels: showLabels.checked
    property alias cfg_updateInterval: updateInterval.value

    Kirigami.FormLayout {
        QQC2.CheckBox {
            id: showCpu
            Kirigami.FormData.label: i18n("Show in panel:")
            text: i18n("CPU")
        }
        QQC2.CheckBox {
            id: showMemory
            text: i18n("Memory")
        }
        QQC2.CheckBox {
            id: showDisk
            text: i18n("Disk")
        }
        QQC2.CheckBox {
            id: showNetwork
            text: i18n("Network")
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        QQC2.CheckBox {
            id: compactMode
            Kirigami.FormData.label: i18n("Style:")
            text: i18n("Compact mode")
        }
        QQC2.CheckBox {
            id: showGraphs
            enabled: !compactMode.checked
            text: i18n("Show graphs")
        }
        QQC2.CheckBox {
            id: showLabels
            text: i18n("Show labels")
        }

        QQC2.SpinBox {
            id: updateInterval
            Kirigami.FormData.label: i18n("Update interval:")
            from: 1
            to: 10
            textFromValue: (value, locale) => i18np("%1 second", "%1 seconds", value)
            valueFromText: (text, locale) => parseInt(text)
        }
    }
}
