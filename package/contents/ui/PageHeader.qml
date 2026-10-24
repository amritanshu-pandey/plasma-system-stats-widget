import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

RowLayout {
    property alias title: title.text
    property alias subtitle: subtitle.text
    property alias value: value.text

    Layout.fillWidth: true

    ColumnLayout {
        spacing: 0
        Layout.fillWidth: true

        Kirigami.Heading {
            id: title
            level: 3
            Layout.fillWidth: true
            elide: Text.ElideRight
        }
        PlasmaComponents.Label {
            id: subtitle
            visible: text !== ""
            opacity: 0.7
            font: Kirigami.Theme.smallFont
            Layout.fillWidth: true
            elide: Text.ElideRight
        }
    }

    Kirigami.Heading {
        id: value
        level: 2
    }
}
