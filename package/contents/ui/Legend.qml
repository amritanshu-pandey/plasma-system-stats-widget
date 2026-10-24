import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

RowLayout {
    property alias color: swatch.color
    property alias text: label.text

    spacing: Kirigami.Units.smallSpacing

    Rectangle {
        id: swatch
        implicitWidth: Kirigami.Units.smallSpacing * 2
        implicitHeight: implicitWidth
        radius: implicitWidth / 2
    }
    PlasmaComponents.Label {
        id: label
        font: Kirigami.Theme.smallFont
    }
}
