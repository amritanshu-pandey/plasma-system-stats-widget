.pragma library

// Marks names for translation. Callers pass a translate function, usually i18n.
function I18N_NOOP(text) {
    return text;
}

// Readable names for common lm-sensors chip drivers, matched by prefix.
// The order of this list is the display order.
const chips = [
    [/^(k10temp|coretemp|zenpower|cpu_thermal)/, I18N_NOOP("CPU")],
    [/^(amdgpu|radeon|nouveau|nvidia|i915|xe)/, I18N_NOOP("GPU")],
    [/^gpu\d+/, I18N_NOOP("GPU")],
    [/^(spd5118|jc42|ee1004)/, I18N_NOOP("Memory module")],
    [/^nvme/, I18N_NOOP("NVMe drive")],
    [/^drivetemp/, I18N_NOOP("Drive")],
    [/^(nct\d+|it\d+|f71\d+|w83\d+|asus_wmi|gigabyte_wmi)/, I18N_NOOP("Motherboard")],
    [/^pch_/, I18N_NOOP("Chipset")],
    [/^(thinkpad|dell_smm|dell_ddv|asus|hp|applesmc|surface)/, I18N_NOOP("Laptop")],
    [/^cros_ec/, I18N_NOOP("Embedded controller")],
    [/^acpitz/, I18N_NOOP("ACPI thermal zone")],
    [/^(iwlwifi|ath\d+|mt7\d+|rtw)/, I18N_NOOP("Wi-Fi")],
    [/^(r8169|igc|e1000e|enp|eth)/, I18N_NOOP("Ethernet")],
    [/^(BAT|battery)/, I18N_NOOP("Battery")],
    [/^ucsi_source_psy/, I18N_NOOP("USB-C")],
];

// Common words used in sensor labels, mainly by embedded controllers.
const words = {
    cpu: I18N_NOOP("CPU"),
    gpu: I18N_NOOP("GPU"),
    soc: I18N_NOOP("SoC"),
    ddr: I18N_NOOP("Memory"),
    local: I18N_NOOP("Board"),
    ambient: I18N_NOOP("Ambient"),
    charger: I18N_NOOP("Charger"),
    battery: I18N_NOOP("Battery"),
    vrm: I18N_NOOP("VRM"),
    pch: I18N_NOOP("Chipset"),
};

// Position of a chip in the display order. Unknown chips go last.
function chipRank(chip) {
    const index = chips.findIndex(([pattern]) => pattern.test(chip));
    return index < 0 ? chips.length : index;
}

function chipName(chip, translate) {
    for (const [pattern, name] of chips) {
        if (pattern.test(chip)) {
            return translate(name);
        }
    }
    return chip;
}

// Turns labels like "cpu_f75303@4d (°C)" into "CPU".
function sensorName(name, translate) {
    const clean = String(name || "")
        .replace(/\s*\([^)]*\)$/, "")
        .replace(/@\w+$/, "")
        .replace(/_[a-z]?\d{3,}$/i, "");
    const key = clean.toLowerCase();
    if (key in words) {
        return translate(words[key]);
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
function chipNames(ids, translate) {
    return numbered(ids.map(id => chipName(id, translate)));
}

// Sensor names for a list of raw labels, numbered when a name repeats.
function sensorNames(labels, translate) {
    return numbered(labels.map(label => sensorName(label, translate)));
}
