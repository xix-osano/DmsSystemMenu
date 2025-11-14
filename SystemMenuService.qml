pragma Singleton

import QtQuick
import Quickshell
import qs.Services

Item {
    id: root

    // Escape shell special characters to safely pass arguments to shell
    function escapeShellArg(arg) {
        if (typeof arg !== "string") arg = String(arg)
        // Single-quote wrapping and escaping for shell safety
        return "'" + arg.replace(/'/g, "'\"'\"'") + "'"
    }

    // Minimal helper wrapper
    function execDetached(cmdArray) {
        if (!cmdArray) return;
        try {
            Quickshell.execDetached(cmdArray);
        } catch (e) {
            console.error("SystemMenuService.execDetached failed:", e, cmdArray);
        }
    }

    function presentTerminal(cmd) {
        if (!cmd) return;
        // Exec using the default shell so callers can use terminal helpers
        Quickshell.execDetached(["sh", "-c", cmd]);
    }

    function launchEditor(path) {
        if (!path) path = "";
        execDetached(["sh", "-c", "shellos-launch-editor " + escapeShellArg(path)]);
    }

    function presentTerminalWithPresentation(cmd) {
        if (!cmd) return;
        execDetached(["sh", "-c", "shellos-launch-floating-terminal-with-presentation " + escapeShellArg(cmd)]);
    }

    function takeScreenshot(mode, processing) {
        var m = mode || "smart";
        var p = processing || "slurp";
        execDetached(["sh", "-c", "shellos-cmd-screenshot " + m + " " + p]);
    }

    function screenrecord(scope, withAudio, withWebcam) {
        var args = [];
        if (scope) args.push(scope);
        if (withAudio) args.push("--with-audio");
        if (withWebcam) args.push("--with-webcam");
        execDetached(["sh", "-c", "shellos-cmd-screenrecord " + args.join(" ")]);
    }

    function share(mode) {
        var m = mode || "clipboard";
        execDetached(["sh", "-c", "shellos-cmd-share " + m]);
    }

    function lockScreen() {
        execDetached(["sh", "-c", "shellos-lock-screen"]);
    }

    function launchScreensaver(forceBool) {
        var f = forceBool ? "force" : "";
        execDetached(["sh", "-c", "shellos-launch-screensaver " + f]);
    }

    function runUpdate() {
        // Prefer interactive terminal presentation for update flow
        presentTerminalWithPresentation("shellos-update");
    }

    function pkgInstall() {
        execDetached(["sh", "-c", "shellos-pkg-install"]);
    }
}
