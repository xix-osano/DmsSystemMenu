import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "systemMenu"

    property string terminalApp: root.defaultSetting("terminalApp")
    property bool showIcon: root.defaultSetting("showIcon")
    property bool showText: root.defaultSetting("showText")

    function defaultSetting(key) {
        if (key === "terminalApp") return "alacritty"
        if (key === "showIcon") return true
        if (key === "showText") return true
        return undefined
    }
    
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
        height: actionColumn.implicitHeight + Theme.spacingL * 2
        radius: Theme.cornerRadius
        color: Theme.surfaceContainerHigh

        Column {
            id: actionColumn
            anchors.fill: parent
            anchors.margins: Theme.spacingL
            spacing: Theme.spacingM

            Row {
                width: parent.width
                spacing: Theme.spacingS

                StyledText {
                    text: "Terminal Application"
                    font.pixelSize: Theme.fontSizeLarge
                    font.weight: Font.Medium
                    width: parent.width - terminalAppField.width - Theme.spacingS
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.surfaceText
                }

                DankTextField {
                    id: terminalAppField
                    width: 200
                    //placeholderText: "Enter terminal application"
                    text: root.defaultSetting("terminalApp")
                    onTextChanged: root.terminalApp = text
                }
            }

            StyledRect {
                width: parent.width
                height: 1
            }

            Row {
                width: parent.width
                spacing: Theme.spacingM
                

                Column {
                    spacing: Theme.spacingXS
                    width: parent.width

                    Row {
                        width: parent.width
                        spacing: Theme.spacingXS
                        

                        StyledText {
                            text: "Show Icon"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceVariantText
                            width: parent.width - showIconToggle.width -Theme.spacingM
                        }

                        DankToggle {
                            anchors.verticalCenter: parent.verticalCenter
                            id: showIconToggle
                            checked: root.defaultSetting("showIcon")
                            onToggled: isChecked => {
                                root.showIcon = isChecked
                            }
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: 1
            }

            Row {
                width: parent.width
                spacing: Theme.spacingM

                Column {
                    width: parent.width
                    spacing: Theme.spacingXS

                    Row {
                        width: parent.width
                        spacing: Theme.spacingXS

                        StyledText {
                            text: "Show Text"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceVariantText
                            width: parent.width - showTextToggle.width -Theme.spacingM
                        }

                        DankToggle {
                            anchors.verticalCenter: parent.verticalCenter
                            id: showTextToggle
                            checked: root.defaultSetting("showText")
                            onToggled: isChecked => {
                                root.showText = isChecked
                            }
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: 1
            }
        }
    }

    StyledRect {
        width: parent.width
        height: Math.max(200, instructionsColumn.implicitHeight + Theme.spacingL * 2)
        radius: Theme.cornerRadius
        color: Theme.surfaceContainerHigh

        Column {
            id: instructionsColumn
            anchors.fill: parent
            anchors.margins: Theme.spacingL
            spacing: Theme.spacingM

            StyledText {
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
    }
}