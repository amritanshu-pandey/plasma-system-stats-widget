import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.ksysguard.sensors as Sensors

import "names.js" as Names

KCM.SimpleKCM {
    id: page

    property var cfg_panelModules: []
    property alias cfg_compactMode: compactMode.checked
    property alias cfg_showGraphs: showGraphs.checked
    property alias cfg_showLabels: showLabels.checked
    property alias cfg_moduleSpacing: moduleSpacing.value
    property alias cfg_verticalPadding: verticalPadding.value
    property alias cfg_networkBits: networkBits.checked
    property alias cfg_updateInterval: updateInterval.value
    property string cfg_temperatureSensor
    property alias cfg_showPublicIp: showPublicIp.checked

    readonly property var titles: ({
        cpu: i18n("CPU"),
        memory: i18n("Memory"),
        disk: i18n("Disk"),
        network: i18n("Network"),
        sensors: i18n("Sensors"),
        battery: i18n("Battery"),
    })
    readonly property var temperatureOptions: {
        const options = [
            { value: "cpu/all/averageTemperature", text: i18n("CPU average") },
            { value: "cpu/all/maximumTemperature", text: i18n("CPU maximum") },
        ];
        const chips = temperatures.matches.map(id => id.split("/")[1]);
        const unique = chips.filter((chip, i) => chips.indexOf(chip) === i);
        const chipNames = Names.chipNames(unique);
        unique.forEach((chip, i) => {
            const ids = temperatures.matches.filter(id => id.split("/")[1] === chip);
            const labels = Names.sensorNames(ids.map(id => temperatures.names[id]));
            ids.forEach((id, j) => options.push({ value: id, text: chipNames[i] + " – " + labels[j] }));
        });
        if (cfg_temperatureSensor && !options.some(o => o.value === cfg_temperatureSensor)) {
            options.push({ value: cfg_temperatureSensor, text: cfg_temperatureSensor });
        }
        return options;
    }

    // All modules: enabled ones first in panel order, then the rest.
    property var order: []

    function enabled() {
        return Array.from(cfg_panelModules);
    }

    function setEnabled(module, on) {
        const current = enabled();
        cfg_panelModules = order.filter(m => m === module ? on : current.includes(m));
    }

    function move(from, to) {
        const next = order.slice();
        next.splice(to, 0, next.splice(from, 1)[0]);
        order = next;
        const current = enabled();
        cfg_panelModules = order.filter(m => current.includes(m));
    }

    Component.onCompleted: {
        const current = enabled().filter(m => m in titles);
        order = current.concat(Object.keys(titles).filter(m => !current.includes(m)));
    }

    Sensors.SensorTreeModel {
        id: sensorTree
    }

    SensorSearch {
        id: temperatures
        tree: sensorTree
        pattern: /^(lmsensors\/[\w.:-]+\/temp\d+|gpu\/gpu\d+\/temperature)$/
        interval: 30000
    }

    Kirigami.FormLayout {
        ColumnLayout {
            Kirigami.FormData.label: i18n("Panel modules:")
            spacing: 0

            Repeater {
                model: page.order

                RowLayout {
                    required property string modelData
                    required property int index

                    QQC2.CheckBox {
                        text: page.titles[modelData]
                        checked: page.enabled().includes(modelData)
                        onToggled: page.setEnabled(modelData, checked)
                        Layout.fillWidth: true
                    }
                    QQC2.ToolButton {
                        icon.name: "arrow-up"
                        enabled: index > 0
                        onClicked: page.move(index, index - 1)
                        QQC2.ToolTip.text: i18n("Move up")
                        QQC2.ToolTip.visible: hovered
                    }
                    QQC2.ToolButton {
                        icon.name: "arrow-down"
                        enabled: index < page.order.length - 1
                        onClicked: page.move(index, index + 1)
                        QQC2.ToolTip.text: i18n("Move down")
                        QQC2.ToolTip.visible: hovered
                    }
                }
            }
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
            id: moduleSpacing
            Kirigami.FormData.label: i18n("Module spacing:")
            from: 0
            to: 48
            textFromValue: (value, locale) => i18nc("pixels", "%1 px", value)
            valueFromText: (text, locale) => parseInt(text)
        }

        QQC2.SpinBox {
            id: verticalPadding
            Kirigami.FormData.label: i18n("Edge padding:")
            from: 0
            to: 24
            textFromValue: (value, locale) => i18nc("pixels", "%1 px", value)
            valueFromText: (text, locale) => parseInt(text)
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Panel temperature:")
            model: page.temperatureOptions
            textRole: "text"
            valueRole: "value"
            currentIndex: page.temperatureOptions.findIndex(o => o.value === page.cfg_temperatureSensor)
            onActivated: page.cfg_temperatureSensor = currentValue
        }

        QQC2.CheckBox {
            id: networkBits
            Kirigami.FormData.label: i18n("Network speed:")
            text: i18n("Show in bits per second")
        }
        QQC2.CheckBox {
            id: showPublicIp
            Kirigami.FormData.label: i18n("Public IP:")
            text: i18n("Show public IP address")
        }
        QQC2.Label {
            text: i18n("Sends a request to api.ipify.org while the Network tab is open, at most every 10 minutes.")
            font: Kirigami.Theme.smallFont
            opacity: 0.7
            wrapMode: Text.Wrap
            Layout.maximumWidth: Kirigami.Units.gridUnit * 18
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
