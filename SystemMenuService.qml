pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services

Item {
    id: root

    readonly property var defaults: ({
            terminalApp: "alacritty",
        })

    readonly property string pluginId: "systemMenu"

}