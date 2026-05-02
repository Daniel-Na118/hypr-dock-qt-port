pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // Defaults mirror configs/hypr-dock.conf
    property string currentTheme: "lotos"
    property int iconSize: 23
    property string layer: "top"
    property bool exclusive: true
    property bool smartView: false
    property string position: "bottom"
    property int autoHideDelay: 400
    property bool systemGapUsed: true
    property int margin: 8
    property int contextPos: 5

    // Theme (theme.conf [Theme])
    property int spacing: 5

    readonly property string userConfigPath: (Quickshell.env("HOME") || "") + "/.config/hypr-dock/hypr-dock.conf"
    readonly property string fallbackConfigPath: Qt.resolvedUrl("../configs/hypr-dock.conf").toString().replace("file://", "")
    readonly property string themeConfPath: Qt.resolvedUrl("../theme/" + currentTheme + "/theme.conf").toString().replace("file://", "")

    function _parseIni(text) {
        const out = {};
        let section = "";
        const lines = text.split(/\r?\n/);
        for (let raw of lines) {
            const line = raw.replace(/#.*$/, "").replace(/;.*$/, "").trim();
            if (!line) continue;
            const m = line.match(/^\[(.+)\]$/);
            if (m) { section = m[1]; continue; }
            const kv = line.match(/^([^=]+?)\s*=\s*(.*)$/);
            if (!kv) continue;
            const key = (section ? section + "." : "") + kv[1].trim();
            out[key] = kv[2].trim();
        }
        return out;
    }

    function _bool(v, fallback) {
        if (v === undefined) return fallback;
        return /^(true|1|yes|on)$/i.test(v);
    }
    function _int(v, fallback) {
        if (v === undefined) return fallback;
        const n = parseInt(v, 10);
        return isNaN(n) ? fallback : n;
    }
    function _str(v, fallback) {
        return (v === undefined || v === "") ? fallback : v;
    }

    function _applyMain(text) {
        const c = _parseIni(text);
        currentTheme   = _str(c["General.CurrentTheme"], currentTheme);
        iconSize       = _int(c["General.IconSize"], iconSize);
        layer          = _str(c["General.Layer"], layer);
        exclusive      = _bool(c["General.Exclusive"], exclusive);
        smartView      = _bool(c["General.SmartView"], smartView);
        position       = _str(c["General.Position"], position);
        autoHideDelay  = _int(c["General.AutoHideDelay"], autoHideDelay);
        systemGapUsed  = _bool(c["General.SystemGapUsed"], systemGapUsed);
        margin         = _int(c["General.Margin"], margin);
        contextPos     = _int(c["General.ContextPos"], contextPos);
    }

    function _applyTheme(text) {
        const c = _parseIni(text);
        spacing = _int(c["Theme.Spacing"], spacing);
    }

    FileView {
        path: root.userConfigPath
        onLoaded: root._applyMain(text())
        onLoadFailed: root.fallback.reload()
    }

    FileView {
        id: fallback
        path: root.fallbackConfigPath
        onLoaded: root._applyMain(text())
    }

    FileView {
        path: root.themeConfPath
        onLoaded: root._applyTheme(text())
    }
}
