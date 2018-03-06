/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


import QtQuick                          2.3
import QtQuick.Controls                 1.2

import QGroundControl                   1.0
import QGroundControl.FlightDisplay     1.0
import QGroundControl.FlightMap         1.0
import QGroundControl.ScreenTools       1.0
import QGroundControl.Controls          1.0
import QGroundControl.Palette           1.0
import QGroundControl.Vehicle           1.0
import QGroundControl.Controllers       1.0

Item {
    id: root
    property double _ar:                QGroundControl.settingsManager.videoSettings.aspectRatio.rawValue
    property bool   _showGrid:          QGroundControl.settingsManager.videoSettings.gridLines.rawValue > 0
    property var    _videoReceiver:     QGroundControl.videoManager2.videoReceiver
    property var    _activeVehicle:     QGroundControl.multiVehicleManager.activeVehicle
    property var    _dynamicCameras:    _activeVehicle ? _activeVehicle.dynamicCameras : null
    property bool   _connected:         _activeVehicle ? !_activeVehicle.connectionLost : false
    Rectangle {
        id:             noVideo2
        anchors.fill:   parent
        color:          qgcPal.globalTheme === QGCPalette.Light ? Qt.rgba(255,255,255,0.75) : Qt.rgba(0,0,0,0.75)
        border.width:   ScreenTools.defaultFontPixelHeight * 0.0625
        border.color:    qgcPal.globalTheme === QGCPalette.Light ? Qt.rgba(0,0,0,0.75) : Qt.rgba(255,255,255,0.75)
        visible:        !(_videoReceiver && _videoReceiver.videoRunning)
        QGCLabel {
            text:               qsTr("VIDEO 2")
            font.family:        ScreenTools.demiboldFontFamily
            color:              qgcPal.globalTheme === QGCPalette.Light ? "black" : "white"
            font.pointSize:     ScreenTools.smallFontPointSize
            anchors.centerIn:   parent
        }
      /*  MouseArea {
            anchors.fill: parent
            onDoubleClicked: {
                QGroundControl.videoManager2.fullScreen = !QGroundControl.videoManager2.fullScreen
            }
        } */
    }


    Rectangle {
        anchors.fill:   parent
        color:          "black"
        visible:        _videoReceiver && _videoReceiver.videoRunning
        QGCVideoBackground {
            id:             videoContent2
            height:         parent.height
            width:          _ar != 0.0 ? height * _ar : parent.width
            anchors.centerIn: parent
            receiver:       _videoReceiver
            display:        _videoReceiver && _videoReceiver.videoSurface
            visible:        _videoReceiver && _videoReceiver.videoRunning
            Connections {
                target:         _videoReceiver
                onImageFileChanged: {
                    videoContent2.grabToImage(function(result) {
                        if (!result.saveToFile(_videoReceiver.imageFile)) {
                            console.error('Error capturing video frame');
                        }
                    });
                }
            }
            Rectangle {
                color:  Qt.rgba(1,1,1,0.5)
                height: parent.height
                width:  1
                x:      parent.width * 0.33
                visible: _showGrid && !QGroundControl.videoManager2.fullScreen
            }
            Rectangle {
                color:  Qt.rgba(1,1,1,0.5)
                height: parent.height
                width:  1
                x:      parent.width * 0.66
                visible: _showGrid && !QGroundControl.videoManager2.fullScreen
            }
            Rectangle {
                color:  Qt.rgba(1,1,1,0.5)
                width:  parent.width
                height: 1
                y:      parent.height * 0.33
                visible: _showGrid && !QGroundControl.videoManager2.fullScreen
            }
            Rectangle {
                color:  Qt.rgba(1,1,1,0.5)
                width:  parent.width
                height: 1
                y:      parent.height * 0.66
                visible: _showGrid && !QGroundControl.videoManager2.fullScreen
            }
        }
     /*   MouseArea {
            anchors.fill: parent
            onDoubleClicked: {
                QGroundControl.videoManager2.fullScreen = !QGroundControl.videoManager2.fullScreen
            }
        } */
    }
}
