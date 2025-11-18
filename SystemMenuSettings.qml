import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "systemMenu"
    
    //property var pluginService: null
    readonly property var defaults: ({
        terminalApp: "alacritty",
        setupInstalled: false,
        showIcon: true,
        showText: true
    })
    
    property string terminalApp: defaults.terminalApp
    property string setupInstalled: defaults.setupInstalled
    property string showIcon: defaults.showIcon
    property string showText: defaults.showText

    StyledText {
        width: parent.width
        text: "System Menu Settings"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    StyledText {
        width: parent.width
        text: "Opens a compact system menu for common tasks (install, update, power, etc)."
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.surfaceVariantText
        wrapMode: Text.WordWrap
    }

    StyledRect {
        width: parent.width
        height: 1
        color: Theme.surfaceVariant
    }

    StringSetting {
        settingKey: "terminalApp"
        label: "Terminal Application"
        description: "Choose terminal to launch scripts."
        defaultValue: root.terminalApp
        placeholder: root.terminalApp
    }

    ToggleSetting {
        settingKey: "setupInstalled"
        label: "Turn off to activate toogle for plugin setup."
        description: "Displays the download icon in the popout"
        defaultValue: root.setupInstalled
    }

    ToggleSetting {
        settingKey: "showIcon"
        label: "Show Icon"
        description: "Display the plugin icon in the panel"
        defaultValue: root.showIcon
    }

    ToggleSetting {
        settingKey: "showText"
        label: "Show Text"
        description: "Display the plugin's label text in the panel"
        defaultValue: root.showText
    }

    Column {
        spacing: 8
        width: parent.width - 32

        Text {
            text: "Usage:"
            font.pixelSize: 14
            font.weight: Font.Medium
            color: "#FFFFFF"
        }

        Column {
            spacing: 4
            leftPadding: 16
            bottomPadding: 24

            Text {
                text: "1. Use popout topleft download button to setup needed scripts. "
                font.pixelSize: 12
                color: "#CCFFFFFF"
            }

            Text {
                text: "2. Add title:'^DMS_SM$' to your hyprland/niri floating configuration."
                font.pixelSize: 12
                color: "#CCFFFFFF"
            }

            Text {
                text: "3."
                font.pixelSize: 12
                color: "#CCFFFFFF"
            }

            Text {
                text: "4. "
                font.pixelSize: 12
                color: "#CCFFFFFF"
            }
        }
    }

    function saveSettings(key, value) {
        if (pluginService) {
            pluginService.savePluginData("systemMenu", key, value)
        }
    }

    // function loadSettings(key, defaultValue) {
    //     if (pluginService) {
    //         return pluginService.loadPluginData("systemMenu", key, defaultValue)
    //     }
    //     return defaultValue
    // }

    function loadSettings() {
        const load = key => PluginService.loadPluginData(pluginId, key) || defaults[key];
        terminalApp = load("terminalApp");
        setupInstalled = load("setupInstalled");
        showIcon = load("showIcon");
        showText = load("showText");
    }

    Component.onCompleted: {
        loadSettings();
    }

    Connections {
        target: PluginService
        function onPluginDataChanged(pluginId) {
            if (pluginId === root.pluginId) {
                loadSettings();
            }
        }
    }

}
