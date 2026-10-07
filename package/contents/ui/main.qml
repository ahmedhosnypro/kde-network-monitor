import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as PlasmaCore
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    // Content in the FULL representation, preferred over compact —
    // the full representation gets natural width in the panel (netspeedWidget pattern)
    fullRepresentation: Item {
        id: content

        // Panel applets size the representation from Layout/implicit sizes
        implicitWidth: contentRow.implicitWidth + Kirigami.Units.smallSpacing * 6
        implicitHeight: Kirigami.Units.iconSizes.small
        Layout.minimumWidth: implicitWidth
        Layout.preferredWidth: implicitWidth
        Layout.minimumHeight: Kirigami.Units.iconSizes.small
        Layout.maximumHeight: Kirigami.Units.iconSizes.small

        readonly property real fontSize: Kirigami.Units.iconSizes.small * 0.85

        readonly property color upColor: "#F5A97F"   // peach  — upload
        readonly property color downColor: "#A6E3A1" // green  — download

        property string upText: "--"
        property string downText: "--"

        PlasmaCore.DataSource {
            id: ds
            engine: "executable"
            connectedSources: ["/home/ahmed/.local/bin/netmon"]  // full path: plasmashell PATH lacks ~/.local/bin
            interval: 1000   // engine re-runs the command automatically each interval

            onNewData: function (source, data) {
                if (data["exit code"] !== 0 || !data.stdout) {
                    upText = "--";
                    downText = "--";
                } else {
                    var parts = data.stdout.trim().split("|");
                    if (parts.length >= 2) {
                        upText = parts[0];
                        downText = parts[1];
                    }
                }
            }
        }

        Row {
            id: contentRow
            anchors.centerIn: parent
            spacing: Kirigami.Units.smallSpacing * 2

            Row {
                spacing: Kirigami.Units.smallSpacing
                Kirigami.Icon {
                    source: "go-up"
                    isMask: true
                    color: content.upColor
                    width: content.fontSize
                    height: width
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: content.upText
                    color: content.upColor
                    font.pixelSize: content.fontSize
                    font.family: "monospace"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Row {
                spacing: Kirigami.Units.smallSpacing
                Kirigami.Icon {
                    source: "go-down"
                    isMask: true
                    color: content.downColor
                    width: content.fontSize
                    height: width
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: content.downText
                    color: content.downColor
                    font.pixelSize: content.fontSize
                    font.family: "monospace"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }

    preferredRepresentation: fullRepresentation
}
