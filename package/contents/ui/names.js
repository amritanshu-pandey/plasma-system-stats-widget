.pragma library

// Readable names for common lm-sensors chip drivers, matched by prefix.
// The order of this list is the display order.
const chips = [
    [/^(k10temp|coretemp|zenpower|cpu_thermal)/, "CPU"],
    [/^(amdgpu|radeon|nouveau|nvidia|i915|xe)/, "GPU"],
    [/^gpu\d+/, "GPU"],
    [/^(spd5118|jc42|ee1004)/, "Memory module"],
    [/^nvme/, "NVMe drive"],
    [/^drivetemp/, "Drive"],
    [/^(nct\d+|it\d+|f71\d+|w83\d+|asus_wmi|gigabyte_wmi)/, "Motherboard"],
    [/^pch_/, "Chipset"],
    [/^(thinkpad|dell_smm|dell_ddv|asus|hp|applesmc|surface)/, "Laptop"],
    [/^cros_ec/, "Embedded controller"],
    [/^acpitz/, "ACPI thermal zone"],
    [/^(iwlwifi|ath\d+|mt7\d+|rtw)/, "Wi-Fi"],
    [/^(r8169|igc|e1000e|enp|eth)/, "Ethernet"],
    [/^(BAT|battery)/, "Battery"],
    [/^ucsi_source_psy/, "USB-C"],
];

// Common words used in sensor labels, mainly by embedded controllers.
const words = {
    cpu: "CPU",
    gpu: "GPU",
    soc: "SoC",
    ddr: "Memory",
    local: "Board",
    ambient: "Ambient",
    charger: "Charger",
    battery: "Battery",
    vrm: "VRM",
    pch: "Chipset",
};

// Position of a chip in the display order. Unknown chips go last.
function chipRank(chip) {
    const index = chips.findIndex(([pattern]) => pattern.test(chip));
    return index < 0 ? chips.length : index;
}

function chipName(chip) {
    for (const [pattern, name] of chips) {
        if (pattern.test(chip)) {
            return name;
        }
    }
    return chip;
}

// Turns labels like "cpu_f75303@4d (°C)" into "CPU".
function sensorName(name) {
    const clean = String(name || "")
        .replace(/\s*\([^)]*\)$/, "")
        .replace(/@\w+$/, "")
        .replace(/_[a-z]?\d{3,}$/i, "");
    const key = clean.toLowerCase();
    if (key in words) {
        return words[key];
    }
    return clean.charAt(0).toUpperCase() + clean.slice(1);
}

// Adds a number to names that appear more than once.
function numbered(names) {
    const counts = {};
    names.forEach(name => counts[name] = (counts[name] || 0) + 1);
    const seen = {};
    return names.map(name => {
        if (counts[name] < 2) {
            return name;
        }
        seen[name] = (seen[name] || 0) + 1;
        return name + " " + seen[name];
    });
}

// Chip names for a list of chip ids, numbered when a name repeats.
function chipNames(ids) {
    return numbered(ids.map(chipName));
}

// Sensor names for a list of raw labels, numbered when a name repeats.
function sensorNames(labels) {
    return numbered(labels.map(sensorName));
}
