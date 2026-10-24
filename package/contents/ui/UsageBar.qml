import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Rectangle {
    id: bar

    property real value: 0
    property bool warning: value >= 90

    implicitHeight: Kirigami.Units.smallSpacing
    Layout.fillWidth: true
    radius: height / 2
    color: Qt.alpha(Kirigami.Theme.textColor, 0.1)

    Rectangle {
        width: parent.width * Math.max(0, Math.min(bar.value, 100)) / 100
        height: parent.height
        radius: parent.radius
        color: bar.warning ? Kirigami.Theme.negativeTextColor : Kirigami.Theme.highlightColor
    }
}
