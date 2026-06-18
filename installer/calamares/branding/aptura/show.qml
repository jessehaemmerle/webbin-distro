/* Aptura OS installer slideshow */
import QtQuick 2.0
import calamares.slideshow 1.0

Presentation {
    id: presentation

    function onActivate() { presentation.startTimer(); }
    function onLeave()    { presentation.stopTimer(); }

    Timer {
        interval: 8000
        running: true
        repeat: true
        onTriggered: presentation.goToNextSlide()
    }

    Slide {
        Rectangle {
            anchors.fill: parent
            color: "#12142b"
            Text {
                anchors.centerIn: parent
                color: "#eef1ff"
                font.pixelSize: 26
                horizontalAlignment: Text.AlignHCenter
                text: "Welcome to Aptura OS\nA calm Linux for everyday work"
            }
        }
    }

    Slide {
        Rectangle {
            anchors.fill: parent
            color: "#12142b"
            Text {
                anchors.centerIn: parent
                color: "#00d9c0"
                font.pixelSize: 22
                horizontalAlignment: Text.AlignHCenter
                text: "Office, mail and music, ready out of the box.\nLibreOffice · Thunderbird · Firefox · Spotify"
            }
        }
    }

    Slide {
        Rectangle {
            anchors.fill: parent
            color: "#12142b"
            Text {
                anchors.centerIn: parent
                color: "#7a4dff"
                font.pixelSize: 22
                horizontalAlignment: Text.AlignHCenter
                text: "Aptura Shell\nA fast, focused Wayland desktop"
            }
        }
    }
}
