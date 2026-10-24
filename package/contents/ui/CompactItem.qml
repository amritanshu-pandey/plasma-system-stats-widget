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
    property string iconName
    // Space kept free at the top and bottom panel edges.
    property int edgePadding: 0
    // Panel thickness. Text is scaled down to fit it. 0 disables scaling.
    property real availableHeight: 0
    property alias values: graph.values
    property alias secondValues: graph.secondValues
    property alias maximum: graph.maximum
    property alias size: graph.size

    readonly property bool twoLines: secondText !== ""
    readonly property bool smallText: twoLines || compactMode
    readonly property font baseFont: smallText ? Kirigami.Theme.smallFont : Kirigami.Theme.defaultFont
    readonly property int lines: 1 + (twoLines || (compactMode && showLabel) ? 1 : 0)
    readonly property real textScale: availableHeight > 0
        ? Math.min(1, (availableHeight - 2 * edgePadding) / (lines * fontMetrics.height))
        : 1

    signal clicked()

    spacing: Kirigami.Units.smallSpacing

    PlasmaComponents.Label {
        visible: item.showLabel && !item.compactMode
        text: item.label
        font: Kirigami.Theme.smallFont
        opacity: 0.7
    }

    Kirigami.Icon {
        visible: item.iconName !== "" && !item.compactMode
        source: item.iconName
        Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
        Layout.preferredHeight: Kirigami.Units.iconSizes.smallMedium
    }

    MiniGraph {
        id: graph
        visible: item.showGraph && !item.compactMode
        Layout.fillHeight: true
        Layout.topMargin: item.edgePadding
        Layout.bottomMargin: item.edgePadding
        Layout.preferredWidth: Kirigami.Units.gridUnit * 2
    }

    ColumnLayout {
        spacing: 0
        Layout.alignment: Qt.AlignVCenter
        Layout.minimumWidth: Math.max(metrics.advanceWidth, topLabel.visible ? topLabel.implicitWidth : 0)

        PlasmaComponents.Label {
            id: topLabel
            visible: item.compactMode && item.showLabel && !item.twoLines
            text: item.label
            font.pointSize: Kirigami.Theme.smallFont.pointSize * item.textScale
            opacity: 0.7
            Layout.alignment: Qt.AlignHCenter
        }
        PlasmaComponents.Label {
            text: item.text
            font.pointSize: item.baseFont.pointSize * item.textScale
            Layout.alignment: item.compactMode && !item.twoLines ? Qt.AlignHCenter : Qt.AlignLeft
        }
        PlasmaComponents.Label {
            visible: item.twoLines
            text: item.secondText
            font.pointSize: Kirigami.Theme.smallFont.pointSize * item.textScale
        }
    }

    FontMetrics {
        id: fontMetrics
        font: item.baseFont
    }

    TextMetrics {
        id: metrics
        font.pointSize: item.baseFont.pointSize * item.textScale
        text: item.sample
    }

    TapHandler {
        onTapped: item.clicked()
    }
}
