/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts  1.2

import QGroundControl               1.0
import QGroundControl.Palette       1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0
import QtQuick.Window 2.2

Rectangle {
    id:     settingsView
    color:  qgcPal.window
    z:      QGroundControl.zOrderTopMost

    readonly property real _defaultTextHeight:  ScreenTools.defaultFontPixelHeight
    readonly property real _defaultTextWidth:   ScreenTools.defaultFontPixelWidth
    readonly property real _horizontalMargin:   _defaultTextWidth / 2
    readonly property real _verticalMargin:     _defaultTextHeight / 2
    readonly property real _buttonHeight:       ScreenTools.isTinyScreen ? ScreenTools.defaultFontPixelHeight * 3 : ScreenTools.defaultFontPixelHeight * 2

    property bool _first: true

    QGCPalette { id: qgcPal }

    Component.onCompleted: {
        //-- Default Settings
        __rightPanel.source = QGroundControl.corePlugin.settingsPages[QGroundControl.corePlugin.defaultSettings].url
    }
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
        }
            states: State {
                name: "down"
                //when: mouseArea.containsMouse === false
                when: mouseArea.mouseY > 10
                PropertyChanges {
                    target: _settingstxt
                    y: parent.height / 2
                    rotation: -90
                    font.pointSize: 28 * 2
                    //anchors.topMargin: _verticalMargin * 30

                }
            }
             transitions: Transition {
             from: ""
             to: "down"
             reversible: true
                ParallelAnimation {
                     NumberAnimation {
                        id: _slidetext
                        properties: "y,rotation,font.pointSize"
                        duration: 500
                        easing.type: Easing.InOutQuad
                        alwaysRunToEnd: true
                        }
                }
            }

    QGCLabel {
        id: _settingstxt
        anchors.left:           parent.left
        //anchors.right:          parent.right
        //anchors.top:            parent.top
        anchors.leftMargin:     _horizontalMargin * 30
        anchors.topMargin:      _verticalMargin * 3
        font.pointSize:         28 //
        text:                   qsTr("Application Settings")
        wrapMode:               Text.WordWrap
        horizontalAlignment:    Text.left//Text.AlignHCenter
        visible:                !ScreenTools.isShortScreen
    }
    //-- Panel Contents
    Loader {
        id:                       __rightPanel
        anchors.leftMargin:       _horizontalMargin
        anchors.rightMargin:      _horizontalMargin
        anchors.topMargin:        _verticalMargin
        anchors.bottomMargin:     _verticalMargin
        anchors.left:             parent.left //divider.right
        anchors.top:              parent.top
        anchors.bottom:           parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
    }
}
