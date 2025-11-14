import QtQuick
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "systemmenu"

    StyledText {
        text: "System Menu"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    StyledText {
        text: "Opens a compact system menu for common tasks (install, update, power, etc)."
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.surfaceVariantText
        width: parent.width
        wrapMode: Text.WordWrap
    }

    StyledRect {
        width: parent.width
        height: 1
        color: Theme.surfaceVariant
    }

    ToggleSetting {
        settingKey: "showIcon"
        label: "Show Icon"
        description: "Display the plugin icon in the panel"
        defaultValue: true
    }

    ToggleSetting {
        settingKey: "showText"
        label: "Show Text"
        description: "Display the plugin's label text in the panel"
        defaultValue: true
    }
}
