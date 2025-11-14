import QtQuick
import QtQuick.Controls 2.15
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins
import SystemMenuService 1.0

PluginComponent {
    id: root

    property string displayIcon: "menu"
    property string displayText: "System"
    property bool showIcon: true
    property bool showText: true
    // Process used to run helper commands (shellos-* and other system actions).
    Process {
        id: actionProcess
        running: false

        onExited: function(exitCode, exitStatus) {
            if (exitCode !== 0) {
                console.warn("systemmenu: command exited with code", exitCode)
            }
        }
    }

    // Simple stack-driven menu so the widget presents choices natively instead of launching walker.
    property var menuStack: []
    property var currentItems: []
    property string currentTitle: "Go"

    // Define menus (command strings will be executed via bash -lc)
    property var mainMenu: [
        { text: "Learn", icon: "learn", submenu: [
            { text: "Hyprland", actionCmd: "xdg-open 'https://wiki.hypr.land/'" },
            { text: "Arch", actionCmd: "xdg-open 'https://wiki.archlinux.org/title/Main_page'" },
            { text: "Neovim", actionCmd: "xdg-open 'https://www.lazyvim.org/keymaps'" },
            { text: "Bash", actionCmd: "xdg-open 'https://devhints.io/bash'" },
            { text: "Dank", actionCmd: "xdg-open 'https://danklinux.com/docs/'" }
        ]},
        { text: "Trigger", icon: "trigger", submenu: [
            { text: "Capture", submenu: [
                { text: "Screenshot", submenu: [
                    { text: "Snap screenarea", actionCmd: "grimblast copy area" },
                    { text: "Snap fullscreen", actionCmd: "grimblast copy screen" }
                ]},
                { text: "Screenrecord", submenu: [
                    { text: "Region", actionCmd: "shellos-cmd-screenrecord" },
                    { text: "Region + Audio", actionCmd: "shellos-cmd-screenrecord region --with-audio" },
                    { text: "Display", actionCmd: "shellos-cmd-screenrecord output" },
                    { text: "Display + Audio", actionCmd: "shellos-cmd-screenrecord output --with-audio" },
                    { text: "Display + Webcam", actionCmd: "shellos-cmd-screenrecord output --with-audio --with-webcam" }
                ]}
            ]},
            { text: "Share", submenu: [
                { text: "Clipboard", actionCmd: "shellos-cmd-share clipboard" },
                { text: "File", actionCmd: "shellos-cmd-share file" },
                { text: "Folder", actionCmd: "shellos-cmd-share folder" }
            ]},
            { text: "Toggle", submenu: [
                { text: "Screensaver", actionCmd: "shellos-toggle-screensaver" },
                { text: "Idle Lock", actionCmd: "shellos-toggle-idle" }
            ]}
        ]},
        { text: "Style", submenu: [
            { text: "Hyprland", actionCmd: "shellos-launch-editor ~/.config/hypr/hyprland.conf" },
            { text: "Screensaver", actionCmd: "shellos-launch-editor ~/.config/shellos/branding/screensaver.txt" },
            { text: "About", actionCmd: "shellos-launch-editor ~/.config/shellos/branding/about.txt" }
        ]},
        { text: "Setup", submenu: [
            { text: "DNS", actionCmd: "shellos-setup-dns" },
            { text: "Security", submenu: [
                { text: "SecureBoot", actionCmd: "shellos-setup-secureboot" },
                { text: "AppArmor", actionCmd: "shellos-setup-apparmor" },
                { text: "Fingerprint", actionCmd: "shellos-setup-fingerprint" },
                { text: "Fido2", actionCmd: "shellos-setup-fido2" }
            ]},
            { text: "Config", submenu: [
                { text: "Hyprland", actionCmd: "shellos-launch-editor ~/.config/hypr/hyprland.conf" },
                { text: "Hypridle", actionCmd: "shellos-launch-editor ~/.config/hypr/hypridle.conf && shellos-restart-hypridle" },
                { text: "Walker", actionCmd: "shellos-launch-editor ~/.config/walker/config.toml && shellos-restart-walker" }
            ]}
        ]},
        { text: "Install", submenu: [
            { text: "Package", actionCmd: "shellos-pkg-install" },
            { text: "AUR", actionCmd: "shellos-pkg-aur-install" },
            { text: "Service", submenu: [
                { text: "Dropbox", actionCmd: "shellos-install-dropbox" },
                { text: "Tailscale", actionCmd: "shellos-install-tailscale" },
                { text: "Bitwarden", actionCmd: "bash -lc \"present_terminal 'echo Installing Bitwarden...'; sudo pacman -S --noconfirm bitwarden bitwarden-cli\"" }
            ]}
        ]},
        { text: "Remove", submenu: [
            { text: "Package", actionCmd: "shellos-pkg-remove" },
            { text: "Web App", actionCmd: "shellos-webapp-remove" },
            { text: "TUI", actionCmd: "shellos-tui-remove" }
        ]},
        { text: "Update", submenu: [
            { text: "Shellos", actionCmd: "shellos-update" },
            { text: "Config", actionCmd: "shellos-refresh-hyprland" },
            { text: "Process", submenu: [
                { text: "Hypridle", actionCmd: "shellos-restart-hypridle" },
                { text: "Walker", actionCmd: "shellos-restart-walker" }
            ]}
        ]},
        { text: "System", submenu: [
            { text: "Lock", actionCmd: "shellos-lock-screen" },
            { text: "Screensaver", actionCmd: "shellos-launch-screensaver force" },
            { text: "Suspend", actionCmd: "systemctl suspend" },
            { text: "Restart", actionCmd: "shellos-state clear re*-required && systemctl reboot --no-wall" },
            { text: "Shutdown", actionCmd: "shellos-state clear re*-required && systemctl poweroff --no-wall" }
        ]}
    ]

    function runCommand(cmd) {
        if (!cmd) return
        
        // Dispatch to appropriate service method based on command prefix
        if (cmd.startsWith("shellos-cmd-screenshot")) {
            var parts = cmd.split(" ")
            var mode = parts[1] || "smart"
            var processing = parts[2] || "slurp"
            SystemMenuService.takeScreenshot(mode, processing)
        } else if (cmd.startsWith("shellos-cmd-screenrecord")) {
            var hasAudio = cmd.includes("--with-audio")
            var hasWebcam = cmd.includes("--with-webcam")
            var scope = cmd.includes("output") ? "output" : "region"
            SystemMenuService.screenrecord(scope, hasAudio, hasWebcam)
        } else if (cmd.startsWith("shellos-cmd-share")) {
            var shareMode = cmd.split(" ")[1] || "clipboard"
            SystemMenuService.share(shareMode)
        } else if (cmd.startsWith("shellos-launch-editor")) {
            var filePath = cmd.substring("shellos-launch-editor".length).trim()
            SystemMenuService.launchEditor(filePath)
        } else if (cmd === "shellos-lock-screen") {
            SystemMenuService.lockScreen()
        } else if (cmd.startsWith("shellos-launch-screensaver")) {
            var force = cmd.includes("force")
            SystemMenuService.launchScreensaver(force)
        } else if (cmd === "shellos-update") {
            SystemMenuService.runUpdate()
        } else if (cmd === "shellos-pkg-install") {
            SystemMenuService.presentTerminalWithPresentation("shellos-pkg-install")
        } else if (cmd === "shellos-pkg-aur-install") {
            SystemMenuService.presentTerminalWithPresentation("shellos-pkg-aur-install")
        } else if (cmd === "shellos-pkg-remove") {
            SystemMenuService.presentTerminalWithPresentation("shellos-pkg-remove")
        } else {
            // Fallback: run directly via service
            SystemMenuService.execDetached(["sh", "-c", cmd])
        }
        
        if (menuPopup.visible) menuPopup.close()
    }

    function navigateTo(menu, title) {
        menuStack.push({items: currentItems, title: currentTitle})
        currentItems = menu
        currentTitle = title || ""
    }

    function goBack() {
        if (menuStack.length === 0) {
            menuPopup.close()
            return
        }
        var prev = menuStack.pop()
        currentItems = prev.items
        currentTitle = prev.title
    }

    function showMainMenu() {
        menuStack = []
        currentTitle = "Go"
        currentItems = mainMenu
        menuPopup.open()
    }

    // Native popup to render the currentItems stack
    Popup {
        id: menuPopup
        modal: true
        focus: true
        width: 360
        height: 420
        closePolicy: Popup.CloseOnEscape

        contentItem: Rectangle {
            width: menuPopup.width
            height: menuPopup.height
            color: Theme.surface
            radius: Theme.cornerRadius
            border.width: 1
            border.color: Theme.surfaceVariant

            Column {
                anchors.fill: parent
                spacing: 0

                Row {
                    width: parent.width
                    height: 52
                    spacing: Theme.spacingS
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: Theme.spacingS

                    ViewToggleButton {
                        iconName: "arrow_back"
                        isActive: false
                        onClicked: goBack()
                        visible: menuStack.length > 0
                    }

                    StyledText {
                        text: currentTitle
                        font.pixelSize: Theme.fontSizeMedium
                        font.weight: Font.Medium
                        color: Theme.surfaceText
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.spacingXS

                        ViewToggleButton {
                            iconName: "close"
                            isActive: false
                            onClicked: menuPopup.close()
                        }
                    }
                }

                ListView {
                    id: menuList
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.topMargin: 52
                    anchors.margins: Theme.spacingS
                    model: currentItems
                    clip: true

                    delegate: Rectangle {
                        width: parent.width
                        height: 44
                        color: mouseArea.containsMouse ? Theme.surfaceContainerHighest : "transparent"

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: Theme.spacingM
                            anchors.rightMargin: Theme.spacingM
                            spacing: Theme.spacingS

                            DankIcon {
                                name: modelData.icon || "menu"
                                size: Theme.iconSize
                                color: Theme.surfaceText
                                visible: modelData.icon !== undefined
                            }

                            StyledText {
                                text: modelData.text || ""
                                font.pixelSize: Theme.fontSizeMedium
                                color: Theme.surfaceText
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Item { Layout.fillWidth: true }

                            DankIcon {
                                name: modelData.submenu ? "chevron_right" : "launch"
                                size: Theme.iconSize - 2
                                color: Theme.surfaceVariantText
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (modelData.submenu) {
                                    navigateTo(modelData.submenu, modelData.text)
                                } else if (modelData.actionCmd) {
                                    runCommand(modelData.actionCmd)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    horizontalBarPill: Component {
        MouseArea {
            implicitWidth: contentRow.implicitWidth
            implicitHeight: contentRow.implicitHeight
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: function(mouse) {
                showMainMenu()
            }

            Row {
                id: contentRow
                spacing: Theme.spacingXS

                DankIcon {
                    name: root.displayIcon
                    size: Theme.iconSize - 6
                    color: Theme.surfaceText
                    anchors.verticalCenter: parent.verticalCenter
                    visible: root.showIcon
                }

                StyledText {
                    text: root.displayText
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: Font.Medium
                    color: Theme.surfaceText
                    anchors.verticalCenter: parent.verticalCenter
                    visible: root.showText
                }
            }
        }
    }

    verticalBarPill: Component {
        MouseArea {
            implicitWidth: contentColumn.implicitWidth
            implicitHeight: contentColumn.implicitHeight
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: function(mouse) {
                showMainMenu()
            }

            Column {
                id: contentColumn
                spacing: Theme.spacingXS

                DankIcon {
                    name: root.displayIcon
                    size: Theme.iconSize - 6
                    color: Theme.surfaceText
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: root.showIcon
                }

                StyledText {
                    text: root.displayText
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: Font.Medium
                    color: Theme.surfaceText
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: root.showText
                }
            }
        }
    }
}
