import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

PlasmaComponents.Label {
    font.bold: true
    elide: Text.ElideRight
    Layout.fillWidth: true
    Layout.topMargin: Kirigami.Units.largeSpacing
}
