import QtQuick
import org.kde.ksysguard.sensors as Sensors

// Finds sensor ids matching a pattern by walking the ksystemstats sensor tree.
QtObject {
    id: search

    property Sensors.SensorTreeModel tree
    property var pattern: /^$/
    property bool active: true
    property int interval: 5000
    property var matches: []

    function refresh() {
        if (!tree) {
            return;
        }
        const found = [];
        const walk = parent => {
            for (let row = 0; row < tree.rowCount(parent); row++) {
                const index = tree.index(row, 0, parent);
                const id = tree.data(index, Sensors.SensorTreeModel.SensorId) || "";
                if (pattern.test(id)) {
                    found.push(id);
                }
                walk(index);
            }
        };
        walk(tree.index(-1, -1));
        found.sort();
        if (found.join("\n") !== matches.join("\n")) {
            matches = found;
        }
    }

    // The tree loads asynchronously, so search again shortly after it changes.
    readonly property Timer changed: Timer {
        interval: 250
        onTriggered: search.refresh()
    }

    readonly property Connections treeConnections: Connections {
        target: search.tree
        enabled: search.active
        function onRowsInserted() {
            search.changed.restart();
        }
        function onRowsRemoved() {
            search.changed.restart();
        }
        function onModelReset() {
            search.changed.restart();
        }
    }

    readonly property Timer timer: Timer {
        interval: search.interval
        running: search.active
        repeat: true
        triggeredOnStart: true
        onTriggered: search.refresh()
    }
}
