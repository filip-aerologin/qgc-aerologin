/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


/**
 * @file
 *   @brief QGC Compass Widget
 *   @author Gus Grubba <mavlink@grubba.com>
 */

import QtQuick              2.3
import QtGraphicalEffects   1.0

import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Vehicle       1.0

Item {
    id:                     root

    property real size:     _defaultSize
    property var  vehicle:  null

    property real _defaultSize: ScreenTools.defaultFontPixelHeight * (10)
    property real _sizeRatio:   ScreenTools.isTinyScreen ? (size / _defaultSize) * 0.5 : size / _defaultSize
    property int  _fontSize:    ScreenTools.defaultFontPointSize * _sizeRatio
    property real _heading:     vehicle ? vehicle.heading.rawValue : 0

    property bool showPitch:    true
    property bool showHeading:  true

    property real _rollAngle:   vehicle ? vehicle.roll.rawValue  : 0
    property real _pitchAngle:  vehicle ? vehicle.pitch.rawValue : 0

    property string _north: "N"
    property string _south: "S"
    property string _east: "E"
    property string _west: "W"


    property string _headingString: vehicle ? _heading.toFixed(0) : "OFF"
    property string _headingString2: _headingString.length === 1 ? "0" + _headingString : _headingString
    property string _headingString3: _headingString2.length === 2 ? "0" + _headingString2 : _headingString2

    width:                  size
    height:                 size * 0.3
   // anchors.bottom: bottom


    Rectangle {
        id:             borderRect
        anchors.fill:   parent
      //  radius:         width
        color:          "black"
    }

    Item {
        id:             instrument
        anchors.fill:   parent
        visible:        false
/*
        QGCCompassIndicator {
            id:                 pitchWidget
            visible:            root.showHeading
            size:               root.size * 0.5
            anchors.verticalCenter: parent.verticalCenter
            pitchAngle:         _pitchAngle
            rollAngle:          _rollAngle
            heading:            _heading
            color:              Qt.rgba(0,0,0,0)
        }
*/
        QGCCompassIndicator {
            id:                 pitchIndicator
            anchors.verticalCenter: parent.verticalCenter
            visible:            showHeading
            pitchAngle:         _pitchAngle
            rollAngle:          _rollAngle
            heading:            _heading
            color:              Qt.rgba(0,0,0,0)
            size:               ScreenTools.defaultFontPixelHeight * (10)
        }

    /*    Image {
            id:                 pointer
            source:             vehicle ? vehicle.vehicleImageCompass : ""
            mipmap:             true
            width:              size * 0.65
            sourceSize.width:   width
            fillMode:           Image.PreserveAspectFit
            anchors.centerIn:   parent
            transform: Rotation {
                origin.x:       pointer.width  / 2
                origin.y:       pointer.height / 2
                angle:          _heading
            }
        }
*/
     /*   Image {
            id:                 compassDial
            source:             "/qmlimages/compassInstrumentDial.svg"
            mipmap:             true
            fillMode:           Image.PreserveAspectFit
            anchors.fill:       parent
            sourceSize.height:  parent.height
        }*/

        Rectangle {
            anchors.centerIn:   parent
            width:              size * 0.35
            height:             size * 0.2
            border.color:       Qt.rgba(1,1,1,0.15)
            color:              Qt.rgba(0,0,0,0.65)

            QGCLabel {
                text:           if(_headingString3 == "000" || _headingString3 == "360") {
                                _north
                                }
                                else if (_headingString3 == "180"){
                                _south
                                }
                                else if (_headingString3 == "090"){
                                    _east
                                }
                                else if (_headingString3 == "270"){
                                    _west
                                }
                                else {
                                    _headingString3
                                }
                font.family:    vehicle ? ScreenTools.demiboldFontFamily : ScreenTools.normalFontFamily
                font.pointSize: _fontSize < 8 ? 8 : _fontSize;
                color:          "white"
                anchors.centerIn: parent


            }
        }
        Rectangle {
            anchors.left: parent.left
            anchors.leftMargin: ScreenTools.defaultFontPixelHeight / 2
            anchors.verticalCenter: parent.verticalCenter
            width:              size * 0.1
            height:             size * 0.1
            border.color:       Qt.rgba(1,1,1,0.15)
            color:              Qt.rgba(0,0,0,0.65)

            QGCLabel {
                text:               if(_headingString3 >= "000" && _headingString3 < "090") {
                                    _west
                                    }
                                    else if (_headingString3 >= "090" && _headingString3 < "180"){
                                    _north
                                    }
                                    else if (_headingString3 >= "180" && _headingString3 < "270"){
                                    _east
                                    }
                                    else if (_headingString3 >= "270" && _headingString3 < "360"){
                                    _south
                                    }
                                    else {
                                    "W"
                                    }

                font.family:    vehicle ? ScreenTools.demiboldFontFamily : ScreenTools.normalFontFamily
                font.pointSize: _fontSize < 8 ? 8 : _fontSize;
                color:          "white"
                anchors.centerIn: parent
            }
        }

        Rectangle {
            anchors.right: parent.right
            anchors.rightMargin: ScreenTools.defaultFontPixelHeight / 2
            anchors.verticalCenter: parent.verticalCenter
            width:              size * 0.1
            height:             size * 0.1
            border.color:       Qt.rgba(1,1,1,0.15)
            color:              Qt.rgba(0,0,0,0.65)

            QGCLabel {
                text:               if(_headingString3 >= "000" && _headingString3 < "090") {
                                    _east
                                    }
                                    else if (_headingString3 >= "090" && _headingString3 < "180"){
                                    _south
                                    }
                                    else if (_headingString3 >= "180" && _headingString3 < "270"){
                                    _west
                                    }
                                    else if (_headingString3 >= "270" && _headingString3 < "360"){
                                    _north
                                    }
                                    else {
                                    "E"
                                    }

                font.family:    vehicle ? ScreenTools.demiboldFontFamily : ScreenTools.normalFontFamily
                font.pointSize: _fontSize < 8 ? 8 : _fontSize;
                color:          "white"
                anchors.centerIn: parent
            }
        }

    }

    Rectangle {
        id:             mask
        anchors.fill:   instrument
        //radius:         width / 2
        color:          "black"
        visible:        false
    }

    OpacityMask {
        anchors.fill:   instrument
        source:         instrument
        maskSource:     mask
    }

}

