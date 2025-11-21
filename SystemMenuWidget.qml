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
    property bool showIcon: boolSetting(pluginData.showIcon, true)
    property bool showText: boolSetting(pluginData.showText, true)

    /* ------- Terminal plugins ---------*/
    property bool isLoading: false
    property string displayCommand: ""

    /* ----------  menu data  ---------- */
    property var currentItems: topLevelMenu
    property var menuStack:    ([])

    property string currentTitle: "System Menu"
    property bool setupInstalled: setupCheckResult

    // Check if setup is complete by verifying scripts exist
    property bool setupCheckResult: false

    function checkSetupComplete() {
        if (checkSetupProcess.running) return
        checkSetupProcess.command = ["sh", "-c", "command -v dms-sm-terminal >/dev/null 2>&1"]
        checkSetupProcess.running = true
    }

    Process {
        id: checkSetupProcess
        command: ["sh", "-c", "command -v dms-sm-terminal >/dev/null 2>&1"]
        running: false

        onExited: (exitCode) => {
            var wasComplete = setupCheckResult
            setupCheckResult = (exitCode === 0)
            
            if (setupCheckResult) setupCheckTimer.stop()
        }
    }

    // Check on component completion and periodically
    Component.onCompleted: {
        checkSetupComplete()
        // Check every 5 seconds to detect when setup completes
        setupCheckTimer.start()
    }

    // Update when plugin data changes
    Connections {
        target: PluginService
        function onPluginDataChanged(changedPluginId) {
            if (changedPluginId === pluginId) {
                // Re-check setup status when plugin data changes
                checkSetupComplete()
            }
        }
    }

    Timer {
        id: setupCheckTimer
        interval: 5000
        running: false
        repeat: true
        onTriggered: {
            if (!setupCheckResult) {
                checkSetupComplete()
            } else {
                stop()   // Stop checking once setup is confirmed complete
            }
        }
    }

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
        const scriptsPath = "/home/enosh/.local/share/dms-sm-plugin/bin"
        var envPath = `PATH=$PATH:${scriptsPath}`

        switch (actionType) {
        case "Web":
            root.closePopout()
            Quickshell.execDetached(["xdg-open", actionData])
            toast("Opened: " + actionData)
            break
        case "Edit":
            root.closePopout()
            // Call launcher with the editor command+path, wrapped in shell
            var editCmd = `${envPath} dms-sm-launch-editor ${actionData}`
            //var editCmd = scriptsPath + "/dms-sm-launch-editor " + actionData
            console.log("SystemMenu: Edit launching:", editCmd)
            Quickshell.execDetached(["sh", "-c", editCmd])
            toast("Editing config file: " + actionData)
            break

        // case "Script": 
        //     root.closePopout() 
        //     // Call dms-sm-terminal through shell - need to join terminal args properly 
        //     var terminalCmd = splitArgs(root.terminalApp) 
        //     var terminalStr = terminalCmd.join(" ") 
        //     var scriptCmd = scriptsPath + "/dms-sm-terminal " + terminalStr + " -- " + actionData 
        //     console.log("SystemMenu: Script launching:", scriptCmd) 
        //     Quickshell.execDetached(["sh", "-c", scriptCmd]) 
        //     toast("Script executed: " + actionData) 
        //     break
        case "Script":
            root.closePopout()
            // Call dms-sm-terminal through shell - need to join terminal args properly
            var terminalCmd = splitArgs(root.terminalApp).join(" ")
            //var safeActionData = actionData.replace(/'/g, "'\\''") // escape single quotes
            //var scriptCmd = `PATH=$PATH:${scriptsPath} dms-sm-terminal ${terminalCmd} -- '${safeActionData}'`
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
    // function splitArgs(str) {
    //     if (!str) return []
    //     // Simple split that handles quoted strings
    //     var result = []
    //     var current = ""
    //     var inQuotes = false
    //     var quoteChar = ""
        
    //     for (var i = 0; i < str.length; i++) {
    //         var ch = str.charAt(i)
    //         if ((ch === '"' || ch === "'") && !inQuotes) {
    //             inQuotes = true
    //             quoteChar = ch
    //         } else if (ch === quoteChar && inQuotes) {
    //             inQuotes = false
    //             quoteChar = ""
    //         } else if (ch === ' ' && !inQuotes) {
    //             if (current.length > 0) {
    //                 result.push(current)
    //                 current = ""
    //             }
    //         } else {
    //             current += ch
    //         }
    //     }
    //     if (current.length > 0) {
    //         result.push(current)
    //     }
    //     return result.length > 0 ? result : [str]
    // }

    function splitArgs(cmd) {
        return cmd.trim().split(/\s+/);
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
            root.isLoading = false
            if (exitCode === 0) {
                if (root.displayCommand) {
                    isLoading = true
                }
            } else {
                console.warn("DmsSystemMenu: Command failed with code", exitCode)
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
            // show the setup/download button when setup is NOT installed and still in main menu
            visible: !root.setupInstalled && currentTitle === "System Menu"
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
                onClicked: root.executeCommand(root.terminalApp)
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
    }
    verticalBarPill: Column {
        spacing: Theme.spacingXS
        SystemMenuIcon { 
            anchors.horizontalCenter: parent.horizontalCenter
        }
        SystemMenuText {
            anchors.horizontalCenter: parent.horizontalCenter 
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