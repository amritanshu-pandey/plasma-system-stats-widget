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
    property bool showLabel: true
    property bool showGraph: true
    property alias values: graph.values
    property alias secondValues: graph.secondValues
    property alias maximum: graph.maximum
    property alias size: graph.size

    readonly property bool twoLines: secondText !== ""

    signal clicked()

    spacing: Kirigami.Units.smallSpacing

    PlasmaComponents.Label {
        visible: item.showLabel
        text: item.label
        font: Kirigami.Theme.smallFont
        opacity: 0.7
    }

    MiniGraph {
        id: graph
        visible: item.showGraph
        Layout.fillHeight: true
        Layout.topMargin: Kirigami.Units.smallSpacing
        Layout.bottomMargin: Kirigami.Units.smallSpacing
        Layout.preferredWidth: Kirigami.Units.gridUnit * 2
    }

    ColumnLayout {
        spacing: 0
        Layout.minimumWidth: metrics.advanceWidth

        PlasmaComponents.Label {
            text: item.text
            font: item.twoLines ? Kirigami.Theme.smallFont : Kirigami.Theme.defaultFont
        }
        PlasmaComponents.Label {
            visible: item.twoLines
            text: item.secondText
            font: Kirigami.Theme.smallFont
        }
    }

    TextMetrics {
        id: metrics
        font: item.twoLines ? Kirigami.Theme.smallFont : Kirigami.Theme.defaultFont
        text: item.sample
    }

    TapHandler {
        onTapped: item.clicked()
    }
}
