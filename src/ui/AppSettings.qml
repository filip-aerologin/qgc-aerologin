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

    QGCFlickable {
        id:                 buttonList
        width:              buttonColumn.width
        anchors.topMargin:  _verticalMargin * 3
        anchors.top:        parent.top
        anchors.bottom:     parent.bottom
        anchors.leftMargin: _horizontalMargin * 20
        anchors.left:       parent.left
        anchors.rightMargin: _horizontalMargin
        anchors.right:      parent.right
        contentHeight:      buttonColumn.height + _verticalMargin
        flickableDirection: Flickable.VerticalFlick
        clip:               true

        ExclusiveGroup { id: panelActionGroup }

        RowLayout {                                      // ColumnLayout
            id:         buttonColumn
            spacing:    _verticalMargin * 7

            property real _maxButtonWidth: 0

            QGCLabel {
                anchors.left:           parent.left
                anchors.right:          parent.right
                font.pointSize:         28 //////////////////////////////////////
                text:                   qsTr("Application Settings      ")
                wrapMode:               Text.WordWrap
                horizontalAlignment:    Text.left//Text.AlignHCenter
                visible:                !ScreenTools.isShortScreen
            }

            Repeater {
                model:  QGroundControl.corePlugin.settingsPages
                QGCButton {
                    height:             _buttonHeight
                    anchors.bottom:     anchors.bottom
                    text:               modelData.title
                    exclusiveGroup:     panelActionGroup
                    Layout.fillWidth:   true

                    onClicked: {
                        if(__rightPanel.source !== modelData.url) {
                            __rightPanel.source = modelData.url
                        }
                        checked = true
                    }

                    Component.onCompleted: {
                        if(_first) {
                            _first = false
                            checked = true
                        }
                    }
                }
            }

        }

    }

    /*Rectangle {
        id:                     divider
        anchors.topMargin:      _verticalMargin
        anchors.bottomMargin:   _verticalMargin
        anchors.leftMargin:     _horizontalMargin
        anchors.left:           buttonList.right
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        width:                  1
        color:                  qgcPal.windowShade
    }*/

    //-- Panel Contents
    Loader {
        id:                     __rightPanel
        anchors.leftMargin:     _horizontalMargin
        anchors.rightMargin:    _horizontalMargin
        anchors.topMargin:      _verticalMargin * 12
        anchors.bottomMargin:   _verticalMargin
        anchors.left:           parent.left //divider.right
        anchors.right:          parent.right
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
    }
}

