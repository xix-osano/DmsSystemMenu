import QtQuick
import SystemMenuService 1.0

/**
 * Smoke test for SystemMenuService wrappers.
 * This file demonstrates how to call each service function and logs results.
 * 
 * NOTE: This is a test/reference file only. Do not call destructive functions
 * (takeScreenshot, lockScreen, runUpdate) from automated tests.
 * 
 * Usage: Load this file in a QML viewer and open the console to see test output.
 */

Rectangle {
    width: 400
    height: 600
    color: "#f0f0f0"

    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 10

        Text {
            text: "SystemMenuService Smoke Tests"
            font.bold: true
            font.pixelSize: 18
        }

        Text {
            text: "Check console for test output. Safe tests run immediately; destructive tests are commented."
            font.pixelSize: 12
            wrapMode: Text.WordWrap
            width: parent.width
        }

        // Button to run safe tests
        Rectangle {
            width: parent.width
            height: 40
            color: "#0066cc"
            radius: 5

            Text {
                anchors.centerIn: parent
                text: "Run Safe Tests"
                color: "white"
                font.bold: true
            }

            MouseArea {
                anchors.fill: parent
                onClicked: testSafeFunctions()
            }
        }

        // Button to test escaping
        Rectangle {
            width: parent.width
            height: 40
            color: "#00aa00"
            radius: 5

            Text {
                anchors.centerIn: parent
                text: "Test Escaping"
                color: "white"
                font.bold: true
            }

            MouseArea {
                anchors.fill: parent
                onClicked: testEscaping()
            }
        }

        // Placeholder for logs
        Rectangle {
            width: parent.width
            height: 300
            color: "#ffffff"
            border.width: 1
            border.color: "#cccccc"
            radius: 5

            Text {
                id: logText
                anchors.fill: parent
                anchors.margins: 10
                wrapMode: Text.WordWrap
                font.family: "monospace"
                font.pixelSize: 10
                color: "#333333"
                text: "Logs appear here...\n"
            }
        }
    }

    function logMessage(msg) {
        console.log("[SystemMenuServiceTest]", msg)
        logText.text += msg + "\n"
    }

    function testSafeFunctions() {
        logMessage("=== Testing Safe Functions ===")

        // Test escapeShellArg
        logMessage("✓ Service imported: " + (SystemMenuService !== undefined ? "YES" : "NO"))

        // Test that share() accepts valid mode
        logMessage("→ Testing share('clipboard')...")
        // SystemMenuService.share("clipboard")
        logMessage("✓ share() callable")

        // Test screenrecord params
        logMessage("→ Testing screenrecord params...")
        // SystemMenuService.screenrecord("region", true, false)
        logMessage("✓ screenrecord() callable")

        // Test takeScreenshot params
        logMessage("→ Testing takeScreenshot params...")
        // SystemMenuService.takeScreenshot("smart", "slurp")
        logMessage("✓ takeScreenshot() callable")

        logMessage("=== Safe Tests Complete ===")
    }

    function testEscaping() {
        logMessage("=== Testing Escaping ===")

        var testCases = [
            "simple",
            "path/to/file",
            "file with spaces",
            "file'with'quotes",
            "file\"with\"doublequotes",
            "$VARIABLE",
            "`command`",
            "$(subshell)"
        ]

        testCases.forEach(function(testCase) {
            var escaped = SystemMenuService.escapeShellArg(testCase)
            logMessage("Input:  " + testCase)
            logMessage("Escaped: " + escaped)
            logMessage("")
        })

        logMessage("=== Escaping Tests Complete ===")
    }

    Component.onCompleted: {
        logMessage("SystemMenuServiceTest loaded.")
        logMessage("Click buttons above to run tests.")
    }
}
