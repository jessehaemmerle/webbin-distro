import QtQuick 2.15
import calamares.slideshow 1.0

Presentation {
  id: presentation

  Slide {
    Image {
      anchors.fill: parent
      source: "welcome.svg"
      fillMode: Image.PreserveAspectCrop
    }
  }
}
