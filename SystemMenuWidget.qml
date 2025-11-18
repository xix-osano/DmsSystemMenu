import QtQuick
import QtQuick.Controls 2.15
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    /* ----------  plugin config  ---------- */
    property var  pluginService: null
    property string terminalApp: pluginData.terminalApp !== undefined ? pluginData.terminalApp : "alacritty"

    property string pluginId: "systemMenu"
    property string displayIcon: "menu"
    property string displayText: "System"
    property bool   showIcon: pluginData.showIcon !== undefined ? pluginData.showIcon : true
    property bool   showText: pluginData.showText !== undefined ? pluginData.showText : true

    /* ----------  menu data  ---------- */
    property var currentItems: topLevelMenu
    property var menuStack:    ([])

    property string currentTitle: "System Menu"
    // Whether the plugin has been set up/installed. Can be provided by pluginData
    property bool setupInstalled: pluginData && pluginData.setupInstalled !== undefined ? pluginData.setupInstalled : false

    property var topLevelMenu: [
        { name: "Learn",   icon: "school", submenu: [
            { name: "Hyprland", icon: "school", actionCmd: "Web:https://wiki.hypr.land/" },
            { name: "Arch",     icon: "school", actionCmd: "Web:https://wiki.archlinux.org/title/Main_page" },
            { name: "Neovim",   icon: "school", actionCmd: "Web:https://www.lazyvim.org/keymaps" },
            { name: "Bash",     icon: "school", actionCmd: "Web:https://devhints.io/bash" },
            { name: "Dank",     icon: "school", actionCmd: "Web:https://danklinux.com/docs/" }
        ]},
        { name: "Capture", icon: "photo_camera", submenu: [
            { name: "Screenshot Region",    icon: "photo_camera", actionCmd: "Script:dms-sm-screenshot region" },
            { name: "Screenshot Fullscreen",icon: "photo_camera", actionCmd: "Script:dms-sm-screenshot fullscreen" },
            { name: "Snapshot",             icon: "photo_camera", actionCmd: "Script:dms-sm-snapshot" }
        ]},
        { name: "Share",   icon: "share", submenu: [
            { name: "Share Clipboard", icon: "share", actionCmd: "Script:dms-sm-share clipboard" },
            { name: "Share File",      icon: "share", actionCmd: "Script:dms-sm-share file" },
            { name: "Share Folder",    icon: "share", actionCmd: "Script:dms-sm-share folder" }
        ]},
        { name: "Config",  icon: "settings", submenu: [
            { name: "Edit Hyprland", icon: "settings", actionCmd: "Edit:dms-sm-editor ~/.config/hypr/hyprland.conf" },
            { name: "Edit Hypridle", icon: "settings", actionCmd: "Edit:dms-sm-editor ~/.config/hypr/hypridle.conf" },
            { name: "Edit Waybar",   icon: "settings", actionCmd: "Edit:dms-sm-editor ~/.config/waybar/config" }
        ]},
        { name: "Security",  icon: "settings", submenu: [
            { name: "Apparmor", icon: "settings", actionCmd: "Script:dms-sm-setup-apparmor" },
            { name: "Secureboot", icon: "settings", actionCmd: "Script:dms-sm-setup-secureboot" },
            { name: "Dns",   icon: "settings", actionCmd: "Script:dms-sm-setup-dns" }
        ]},
        { name: "Install", icon: "download", submenu: [
            { name: "Package", icon: "download", actionCmd: "Script:dms-sm-pkg-install" },
            { name: "AUR",     icon: "download", actionCmd: "Script:dms-sm-pkg-aur-install" },
            { name: "Service", icon: "download", actionCmd: "Script:dms-sm-install-service" }
        ]},
        { name: "Remove", icon: "download", submenu: [
            { name: "Package", icon: "download", actionCmd: "Script:dms-sm-pkg-install" },
            { name: "AUR",     icon: "download", actionCmd: "Script:dms-sm-pkg-aur-install" },
            { name: "Service", icon: "download", actionCmd: "Script:dms-sm-install-service" }
        ]},
        { name: "Update", icon: "download", submenu: [
            { name: "System", icon: "download", actionCmd: "Script:dms-sm-update" },
            { name: "Firmware",     icon: "download", actionCmd: "Script:dms-sm-update-firmware" },
            { name: "DMSSystemMenu Plugin", icon: "download", actionCmd: "Script:dms-sm-update-plugin" }
        ]}
    ]

    /* ----------  plugin interface  ---------- */
    signal stacksChanged()

    Component.onCompleted: {
        console.log(pluginId, ": Plugin loaded.");
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
        if (!menuStack.length) { menuPopout.close(); return }
        currentItems = menuStack.pop()
        currentTitle = menuStack.length ? currentItems[0].name : "System Menu"
    }

    /* ----------  command dispatcher  ---------- */
    function executeCommand(cmdString) {
        if (!cmdString) { console.warn("SystemMenu: empty command"); return }

        const parts = cmdString.split(":")
        const type  = parts[0]
        const data  = parts.slice(1).join(":")

        switch (type) {
        case "Web":
            // Use direct exec to avoid an extra shell and quoting issues
            Quickshell.execDetached(["xdg-open", data])
            toast("Opened: " + data)
            break
        case "Edit":
            menuPopout.close()
            // Call launcher with the single argument (the editor command+path)
            Quickshell.execDetached(["dms-sm-launch-editor", data])
            break
        case "Script":
            menuPopout.close()
            // Call dms-sm-terminal with terminalApp tokens, a separator "--", then the script+args
            var argv = ["dms-sm-terminal"].concat(splitArgs(root.terminalApp)).concat(["--"]).concat(splitArgs(data))
            Quickshell.execDetached(argv)
            toast("Script executed: " + data)
            break
        default:
            toast("Unknown action: " + type)
        }
    }

    function toast(msg) {
        if (typeof ToastService !== "undefined") ToastService.showInfo("SystemMenu", msg)
        else console.log("SystemMenu toast:", msg)
    }

    function launchTerminal(terminalApp) {
        // Use provided terminalApp argument or fallback to configured value
        var app = terminalApp || root.terminalApp
        if (!app) { toast("No terminal configured"); return }

        Quickshell.execDetached(["dms-sm-launch-terminal", app])
    }

    /* --------Fuction to copy needed scripts & Add path to bash*/
    function pluginSetupCmd() {
        // Run the bundled setup script. We keep the path unquoted so ~ expands.
        Quickshell.execDetached(["sh", "-c", "~/.config/DankMaterialShell/plugins/DmsSystemMenu/dms-sm-setup.sh"])
        // Optimistically mark installed so button hides; the script can
        // also update this via pluginData or by calling markSetupInstalled().
        root.setupInstalled = true
        toast("Setup started")
    }

    /* ----------  UI components  ---------- */
    component SystemMenuIcon: DankIcon {
        name: root.displayIcon
        size: Theme.barIconSize(root.barThickness, -4)
        color: Theme.primary
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
            iconName: "download"
            isActive: false
            onClicked: root.pluginSetupCmd()
            visible: root.setupInstalled = false
        }

        ViewToggleButton {
            id: backBtn
            anchors.verticalCenter: parent.verticalCenter
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
                onClicked: root.launchTerminal()
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
        id: menuPopout
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
                            else if (modelData.actionCmd) root.executeCommand(modelData.actionCmd)
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