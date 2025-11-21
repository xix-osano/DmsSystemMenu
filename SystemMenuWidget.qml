import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    /* ----------  plugin config  ---------- */
    property var pluginService: null
    property string pluginId: "systemMenu"
    property string displayIcon: "menu"
    property string displayText: "System"
    property string terminalApp: pluginData.terminalApp !== undefined ? pluginData.terminalApp : "alacritty"
    property string floatingTerminalApp: "alacritty --title=DMS_SM"
    property bool showIcon: boolSetting(pluginData.showIcon, true)
    property bool showText: boolSetting(pluginData.showText, true)
    property bool isLoading: false

    // property string scriptsPath: Quickshell.env.HOME + "/.local/share/dms-sm-plugin/bin"
    property string assetsDir: "~/.local/share/dms-sm-plugin/assets"
    property string installedFlagFile: assetsDir + "/.installed"
    property string installedVersionFile: assetsDir + "/.version"
    property string currentVersionFile: "~/.config/DankMaterialShell/plugins/DmsSystemMenu/assets/.version"
    property bool setupInstalled: !setupRequired

    /* ----------  menu data  ---------- */
    property var currentItems: topLevelMenu
    property var menuStack:    ([])

    property string currentTitle: "System Menu"

    property var topLevelMenu: [
        { name: "Learn",   icon: "school", submenu: [
            { name: "Arch",     icon: "language", actionCmd: "Web:https://wiki.archlinux.org/title/Main_page" },
            { name: "Niri",     icon: "language", actionCmd: "Web:https://yalter.github.io/niri/Configuration%3A-Introduction" },
            { name: "Hyprland", icon: "language", actionCmd: "Web:https://wiki.hypr.land/" },
            { name: "Neovim",   icon: "language", actionCmd: "Web:https://www.lazyvim.org/keymaps" },
            { name: "Bash",     icon: "language", actionCmd: "Web:https://devhints.io/bash" },
            { name: "Dank",     icon: "language", actionCmd: "Web:https://danklinux.com/docs/" }
        ]},
        { name: "Capture", icon: "screenshot_monitor", submenu: [
            { name: "Screenshot Region",    icon: "crop_square", actionCmd: "Script:dms-sm-screenshot region" },
            { name: "Screenshot Fullscreen",icon: "screenshot_monitor", actionCmd: "Script:dms-sm-screenshot fullscreen" },
            { name: "Snapshot",             icon: "photo_library", submenu: [
                { name: "Create Snapshot",icon: "photo_camera", actionCmd: "Script:dms-sm-snapshot create" },
                { name: "Restore Snapshot",icon: "history", actionCmd: "Script:dms-sm-snapshot restore" },
            ]}
        ]},
        { name: "Share",   icon: "share", submenu: [
            { name: "Share Clipboard", icon: "content_copy", actionCmd: "Script:dms-sm-share clipboard" },
            { name: "Share File",      icon: "description", actionCmd: "Script:dms-sm-share file" },
            { name: "Share Folder",    icon: "folder", actionCmd: "Script:dms-sm-share folder" }
        ]},
        { name: "Config",  icon: "edit_square", submenu: [
            { name: "Edit Hyprland", icon: "edit", actionCmd: "Edit:~/.config/hypr/hyprland.conf" },
            { name: "Edit Niri", icon: "edit", actionCmd: "Edit:~/.config/niri/config.kdl" },
            { name: "Edit Bash",   icon: "edit", actionCmd: "Edit:~/.bashrc" }
        ]},
        { name: "Setup",  icon: "construction", submenu: [
            { name: "Security", icon: "security", submenu: [
                { name: "Apparmor", icon: "verified_user", actionCmd: "Script:dms-sm-setup-apparmor" },
                { name: "Secureboot", icon: "verified_user", actionCmd: "Script:dms-sm-setup-secureboot" },
                { name: "Fingerprint",   icon: "fingerprint", actionCmd: "Script:dms-sm-setup-fingerprint" },
                { name: "Fido2",   icon: "vpn_key", actionCmd: "Script:dms-sm-setup-fido2" }
            ]},
            { name: "Power",   icon: "battery_full", submenu: [
                { name: "Power-saver",   icon: "battery_saver", actionCmd: "Script:dms-sm-setup-power power-saver" },
                { name: "Balanced",   icon: "battery_full", actionCmd: "Script:dms-sm-setup-power balanced" },
                { name: "Performance",   icon: "battery_unknown", actionCmd: "Script:dms-sm-setup-power performance" }
            ]},
            { name: "Dns",   icon: "dns", submenu: [
                { name: "CloudFlare",   icon: "cloud", actionCmd: "Script:dms-sm-setup-dns Cloudflare" },
                { name: "Quad9",   icon: "cloud", actionCmd: "Script:dms-sm-setup-dns Quad9" },
                { name: "DHCP",   icon: "cloud_queue", actionCmd: "Script:dms-sm-setup-dns DHCP" },
                { name: "Custom",   icon: "settings_ethernet", actionCmd: "Script:dms-sm-setup-dns Custom" }
            ]}
        ]},
        { name: "Install", icon: "add_circle", submenu: [
            { name: "Package", icon: "package", actionCmd: "Script:dms-sm-pkg-install" },
            { name: "AUR",     icon: "package", actionCmd: "Script:dms-sm-pkg-aur-install" },
            { name: "Development", icon: "developer_mode", actionCmd: "Script:dms-sm-install-service" },
            { name: "Service", icon: "add_circle", actionCmd: "Script:dms-sm-install-service" }
        ]},
        { name: "Remove", icon: "delete", submenu: [
            { name: "Package", icon: "delete", actionCmd: "Script:dms-sm-pkg-install" },
            { name: "AUR",     icon: "delete", actionCmd: "Script:dms-sm-pkg-aur-install" },
            { name: "Service", icon: "delete", actionCmd: "Script:dms-sm-install-service" }
        ]},
        { name: "Update", icon: "update", submenu: [
            { name: "System", icon: "system_update", actionCmd: "Script:dms-sm-update" },
            { name: "Firmware",     icon: "upgrade", actionCmd: "Script:dms-sm-update-firmware" },
            { name: "DMSSystemMenu Plugin", icon: "extension", actionCmd: "Script:dms-sm-update-plugin" }
        ]},
        { name: "Power", icon: "power_settings_new", submenu: [
            { name: "Logout",      icon: "logout",        actionCmd: "Run:loginctl terminate-session $XDG_SESSION_ID" },
            { name: "Lock",        icon: "lock",          actionCmd: "Run:dms ipc call lock lock" },
            { name: "Suspend",     icon: "bedtime",       actionCmd: "Run:systemctl suspend" },
            { name: "Hibernate",   icon: "nightlight",    actionCmd: "Run:systemctl hibernate" },
            { name: "Reboot",      icon: "restart_alt",   actionCmd: "Run:systemctl reboot" },
            { name: "Power Off",   icon: "power_settings_new", actionCmd: "Run:systemctl poweroff" }
        ]}
    ]

    /* ----------  plugin interface  ---------- */
    signal stacksChanged()

    function boolSetting(value, fallback) {
        if (value === undefined || value === null) return fallback
        if (typeof value === "boolean") return value
        if (typeof value === "string") return value.toLowerCase() === "true"
        if (typeof value === "number") return value !== 0
        return fallback
    }

    /* ----------  required by Quickshell  ---------- */
    function getStacks(query) {
        if (!query || query.length === 0) return topLevelMenu

        const q = query.toLowerCase()
        return topLevelMenu.filter(stack =>
            stack.name.toLowerCase().includes(q) ||
            (stack.submenu && stack.submenu.some(it => it.name.toLowerCase().includes(q)))
        )
    }

    /* ----------  navigation helpers  ---------- */
    function navigateTo(submenu, title) {
        menuStack.push(currentItems)
        currentItems = submenu
        currentTitle = title
    }
    function goBack() {
        if (!menuStack.length) { root.closePopout(); return }
        currentItems = menuStack.pop()
        currentTitle = menuStack.length ? currentItems[0].name : "System Menu"
    }

    /* ----------  command dispatcher  ---------- */
    function runAction(cmdString) {
        if (!cmdString) { 
            console.warn("SystemMenu: empty command")
            return 
        }

        const actionParts = cmdString.split(":")
        const actionType = actionParts[0]
        const actionData = actionParts.slice(1).join(":")

        console.log("SystemMenu: executeStack cmdString=", cmdString, "actionType=", actionType, "actionData=", actionData)

        // Absolute paths for your scripts
        const scriptsPath = "$HOME/.local/share/dms-sm-plugin/bin"
        var envPath = `PATH=$PATH:${scriptsPath}`

        switch (actionType) {
        case "Web":
            root.closePopout()
            Quickshell.execDetached(["xdg-open", actionData])
            toast("Opened: " + actionData)
            break
        case "Edit":
            root.closePopout()
            var editCmd = `${envPath} dms-sm-launch-editor ${actionData}`
            console.log("SystemMenu: Edit launching:", editCmd)
            Quickshell.execDetached(["sh", "-c", editCmd])
            toast("Editing config file: " + actionData)
            break

        case "Script":
            root.closePopout()
            var terminalCmd = splitArgs(root.terminalApp).join(" ")
            var scriptCmd = `${envPath} dms-sm-terminal ${terminalCmd} -- ${actionData}`
            console.log("SystemMenu: Script launching:", scriptCmd)
            Quickshell.execDetached(["sh", "-c", scriptCmd])
            toast("Script executed: " + actionData)
            break
        case "Run":
            root.closePopout()
            Quickshell.execDetached(["sh", "-c", actionData])
            break
        default:
            toast("Unknown action: " + actionType)
        }
    }

    function toast(msg) {
        if (typeof ToastService !== "undefined") ToastService.showInfo("SystemMenu", msg)
        else console.log("SystemMenu toast:", msg)
    }

    // Helper to split command string into array, handling basic quoted arguments
    function splitArgs(cmd) {
        // Regex to split by whitespace but keep quoted strings intact
        const regex = /[^\s"]+|"([^"]*)"/g;
        let match;
        let args = [];
        while (match = regex.exec(cmd)) {
            // If the match had a quoted group, use that (index 1), otherwise use the main match (index 0)
            args.push(match[1] ? match[1] : match[0]);
        }
        return args;
    }

    function executeCommand(command) {
        if (!command) return

        root.closePopout()
        isLoading = true
        actionProcess.command = ["sh", "-c", command]
        actionProcess.running = true
    }

    Process {
        id: actionProcess
        command: ["sh", "-c", ""]
        running: false

        onExited: (exitCode, exitStatus) => {
            root.isLoading = false // Should always be false upon exit
            if (exitCode !== 0) {
                console.warn("DmsSystemMenu: Command failed with code", exitCode)
                root.toast(`Command failed with exit code ${exitCode}. Check terminal output.`)
            }
        }
    }

    /* --------Function to copy needed scripts & Add path to bash*/
    function pluginSetupCmd() {
        root.closePopout()
        // Launch the setup script in a terminal so user can see the output
        // We can't use dms-sm-terminal here since it doesn't exist until after setup
        const setupScript = "~/.config/DankMaterialShell/plugins/DmsSystemMenu/dms-sm-setup.sh"
        const setupCommand = "bash " + setupScript + "; echo ''; echo 'Press any key to close...'; read -n 1"
        
        // Split terminal app and build command array
        var termArgs = splitArgs(root.terminalApp)
        if (termArgs.length === 0) {
            termArgs = ["alacritty"] // fallback
        }
        
        // Build terminal command with flags and exec prefix
        var termProg = termArgs[0]
        var termFlags = []
        var execPrefix = []
        
        // Add terminal-specific flags based on terminal type
        if (termProg === "alacritty" || termProg.includes("alacritty")) {
            termFlags.push("--class=DMS_SM", "--title=DMS_SM")
            execPrefix = ["-e", "bash", "-c"]
        } else if (termProg === "kitty" || termProg.includes("kitty")) {
            termFlags.push("--title", "DMS_SM")
            execPrefix = ["-e", "bash", "-c"]
        } else {
            // Generic fallback for other terminals
            execPrefix = ["-e", "bash", "-c"]
        }
        
        // Build final command array
        var argv = termArgs.concat(termFlags).concat(execPrefix).concat([setupCommand])
        Quickshell.execDetached(argv)
        toast("Setup script launching in terminal...")

        // mark as installed after setup
        root.setupInstalled = true
        root.setupRequired = false
    }

    Component.onCompleted: {
        // Check if installed version file exists
        Quickshell.Io.File.exists(root.installedVersionFile).then(function(installedExists) {
            if (!installedExists) {
                root.setupRequired = true
                return
            }

            // Read installed version
            Quickshell.Io.File.read(root.installedVersionFile).then(function(installedVersion) {
                // Read current plugin version
                Quickshell.Io.File.read(currentVersionFile).then(function(currentVersion) {
                    root.setupRequired = (installedVersion.trim() !== currentVersion.trim())
                    root.setupInstalled = !root.setupRequired
                    console.log("SystemMenu: setupRequired =", root.setupRequired,
                                "installedVersion =", installedVersion.trim(),
                                "currentVersion =", currentVersion.trim())
                }).catch(function(e) {
                    console.warn("SystemMenu: Could not read current version file", e)
                    root.setupRequired = true
                    root.setupInstalled = false
                })
            }).catch(function(e) {
                console.warn("SystemMenu: Could not read installed version file", e)
                root.setupRequired = false
                root.setupInstalled = true
            })
        })
    }

    /* ----------  UI components  ---------- */
    component SystemMenuIcon: DankIcon {
        name: root.displayIcon
        size: Theme.barIconSize(root.barThickness, -4)
        color: Theme.surfaceText

        visible: root.showIcon
    }
    component SystemMenuText: StyledText {
        text: root.displayText
        font.pixelSize: Theme.fontSizeMedium
        font.weight: Font.Medium
        color: Theme.surfaceText
        visible: root.showText
    }

    component MenuHeader: Rectangle {
        id: menuHeader
        width: parent.width
        height: 52
        color: "transparent"
       
        ViewToggleButton {
            id: pluginSetup
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: Theme.spacingM
            iconName: "download"
            isActive: false
            onClicked: root.pluginSetupCmd()
            // show the setup/download button when setup is required and still in main menu
            visible: root.setupRequired && menuStack.length === 0
        }

        ViewToggleButton {
            id: backBtn
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: Theme.spacingM
            iconName: "arrow_back"
            isActive: false
            onClicked: root.goBack()
            visible: currentTitle !== "System Menu"
        }
        StyledText {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            text: currentTitle
            font.pixelSize: Theme.fontSizeXLarge
            font.weight: Font.Bold
            color: Theme.surfaceText
        }
        Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.spacingXS
            ViewToggleButton {
                iconName: "terminal"
                isActive: false
                onClicked: root.executeCommand(root.floatingTerminalApp)
                visible: root.terminalApp !== undefined && root.terminalApp !== ""
            }
        }
    }

    component MenuStacks: StyledRect {
        id: menuStacksRows
        property var menuData
        signal clicked

        width: parent.width
        height: 60
        radius: Theme.cornerRadius
        color: mouseArea.containsMouse ? Theme.surfaceContainerHighest : Theme.surfaceContainerHigh
        border.width: 0

        Row {
            width: parent.width
            height: parent.height
            spacing: Theme.spacingM

            DankIcon {
                name: modelData.icon || "menu"
                size: Theme.iconSize - 2
                color: Theme.surfaceText
                visible: modelData.icon !== undefined
                anchors.left: parent.left
                anchors.leftMargin: Theme.spacingM
                anchors.verticalCenter: parent.verticalCenter
            }
            StyledText {
                text: modelData.name
                font.pixelSize: Theme.fontSizeLarge
                color: Theme.surfaceText
                anchors.left: parent.left
                anchors.leftMargin: 50
                anchors.verticalCenter: parent.verticalCenter
            }
 
            DankIcon {
                name: modelData.submenu ? "chevron_right" : "launch"
                size: 16
                color: Theme.surfaceVariantText
                anchors.right: parent.right
                anchors.rightMargin: Theme.spacingM
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: menuStacksRows.clicked()
        }
    }

    /* ----------  bar pills  ---------- */
    horizontalBarPill: Row {
        spacing: Theme.spacingXS
        SystemMenuIcon {
            anchors.verticalCenter: parent.verticalCenter 
        }
        SystemMenuText { 
            anchors.verticalCenter: parent.verticalCenter 
        }
        BusyIndicator {
            visible: root.isLoading
        }
    }
    verticalBarPill: Column {
        spacing: Theme.spacingXS
        SystemMenuIcon { 
            anchors.horizontalCenter: parent.horizontalCenter
        }
        SystemMenuText {
            anchors.horizontalCenter: parent.horizontalCenter 
        }
        BusyIndicator {
            visible: root.isLoading
        }
    }

    /* ----------  pop-out  ---------- */
    popoutWidth: 400
    popoutHeight: 530

    popoutContent: Component {
        id: menuPopoutContent
        Column {
            spacing: 0

            MenuHeader {
               //color: Theme.primary
            }

            /* list */
            DankListView {
                id: menuList
                width: parent.width
                height: root.popoutHeight - 46 - Theme.spacingXL
                topMargin: 0
                bottomMargin: Theme.spacingM
                leftMargin: Theme.spacingM
                rightMargin: Theme.spacingM
                spacing: 6
                clip: true
                model: currentItems
                interactive: true
                currentIndex: 0
                highlightFollowsCurrentItem: true
                focus: true

                delegate: Column {
                    width: menuList.width - menuList.leftMargin - menuList.rightMargin
                    spacing: 0

                    MenuStacks {
                        menuData: modelData
                        onClicked: {
                            if (modelData.submenu) root.navigateTo(modelData.submenu, modelData.name)
                            else if (modelData.actionCmd) root.runAction(modelData.actionCmd)
                        }
                    }
                }

                Keys.onUpPressed: {
                    list.currentIndex = Math.max(0, list.currentIndex - 1)
                }

                Keys.onDownPressed: {
                    list.currentIndex = Math.min(list.count - 1, list.currentIndex + 1)
                }

                Keys.onReturnPressed: {
                    let m = list.model[list.currentIndex]
                    if (!m) return

                    if (m.submenu) {
                        root.navigateTo(m.submenu, m.name)
                    } else if (m.actionCmd) {
                        root.runAction(m.actionCmd)
                    }
                }

                Keys.onSpacePressed: {
                    let m = list.model[list.currentIndex]
                    if (!m) return

                    if (m.submenu) {
                        root.navigateTo(m.submenu, m.name)
                    } else if (m.actionCmd) {
                        root.runAction(m.actionCmd)
                    }
                }

                Keys.forwardTo: [menuStack]
            }
        }
    }

    /* ----------  tiny helper  ---------- */
    component ViewToggleButton: Rectangle {
        property string iconName: ""
        property bool isActive: false
        signal clicked

        width: 36; height: 36; radius: Theme.cornerRadius
        color: isActive ? Theme.primaryHover
                        : (mouseArea.containsMouse ? Theme.surfaceHover : "transparent")

        DankIcon {
            anchors.centerIn: parent
            name: iconName
            size: 18
            color: isActive ? Theme.primary : Theme.surfaceText
        }
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }
}