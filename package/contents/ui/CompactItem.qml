import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

RowLayout {
    id: item

    property string label
    property string text
    property string secondText
    // Widest expected text, used to keep the width stable.
    property string sample
    property bool compactMode: false
    property bool showLabel: true
    property bool showGraph: true
    property alias values: graph.values
    property alias secondValues: graph.secondValues
    property alias maximum: graph.maximum
    property alias size: graph.size

    readonly property bool twoLines: secondText !== ""
    readonly property bool smallText: twoLines || compactMode

    signal clicked()

    spacing: Kirigami.Units.smallSpacing

    PlasmaComponents.Label {
        visible: item.showLabel && !item.compactMode
        text: item.label
        font: Kirigami.Theme.smallFont
        opacity: 0.7
    }

    MiniGraph {
        id: graph
        visible: item.showGraph && !item.compactMode
        Layout.fillHeight: true
        Layout.topMargin: Kirigami.Units.smallSpacing
        Layout.bottomMargin: Kirigami.Units.smallSpacing
        Layout.preferredWidth: Kirigami.Units.gridUnit * 2
    }

    ColumnLayout {
        spacing: 0
        Layout.minimumWidth: Math.max(metrics.advanceWidth, topLabel.visible ? topLabel.implicitWidth : 0)

        PlasmaComponents.Label {
            id: topLabel
            visible: item.compactMode && item.showLabel && !item.twoLines
            text: item.label
            font: Kirigami.Theme.smallFont
            opacity: 0.7
            Layout.alignment: Qt.AlignHCenter
        }
        PlasmaComponents.Label {
            text: item.text
            font: item.smallText ? Kirigami.Theme.smallFont : Kirigami.Theme.defaultFont
            Layout.alignment: item.compactMode && !item.twoLines ? Qt.AlignHCenter : Qt.AlignLeft
        }
        PlasmaComponents.Label {
            visible: item.twoLines
            text: item.secondText
            font: Kirigami.Theme.smallFont
        }
    }

    TextMetrics {
        id: metrics
        font: item.smallText ? Kirigami.Theme.smallFont : Kirigami.Theme.defaultFont
        text: item.sample
    }

    TapHandler {
        onTapped: item.clicked()
    }
}
