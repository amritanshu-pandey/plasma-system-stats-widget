import QtQuick

QtObject {
    property int size: 60
    property var values: []

    function push(value) {
        const next = values.slice(Math.max(0, values.length - size + 1));
        next.push(Number.isFinite(value) ? value : 0);
        values = next;
    }
}
