import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

ColumnLayout {
    id: page

    property Stats stats
    property bool active

    spacing: Kirigami.Units.smallSpacing

    PageHeader {
        title: i18n("Battery")
        value: page.stats.percent(page.stats.battery.value)
    }

    Repeater {
        model: page.stats.batteries

        BatteryInfo {
            required property string modelData

            device: modelData
            stats: page.stats
            active: page.active
            showName: page.stats.batteries.length > 1
            Layout.fillWidth: true
        }
    }
}
