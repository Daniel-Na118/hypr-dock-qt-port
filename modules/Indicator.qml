import QtQuick

Image {
    id: root

    property int count: 0
    property int indicatorWidth: 13
    property int indicatorHeight: 3
    property string themeDir: Qt.resolvedUrl("../theme/lotos/point")

    // Original chooses highest available file index <= count.
    // We ship 0..3, with 3 acting as the "3+" indicator.
    readonly property int selected: Math.min(Math.max(count, 0), 3)

    width: indicatorWidth
    height: indicatorHeight
    fillMode: Image.PreserveAspectFit
    source: themeDir + "/" + selected + ".svg"
    sourceSize.width: indicatorWidth
    sourceSize.height: indicatorHeight
    smooth: true
    asynchronous: true
}
