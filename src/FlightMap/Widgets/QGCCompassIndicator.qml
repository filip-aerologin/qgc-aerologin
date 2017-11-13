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
 *   @brief QGC Pitch Indicator
 *   @author Gus Grubba <mavlink@grubba.com>
 */

import QtQuick 2.3
import QGroundControl.ScreenTools 1.0
import QGroundControl.Controls 1.0

Rectangle {
    property real pitchAngle:       0
    property real rollAngle:        0
    property real heading:          0
    property real size:             ScreenTools.isAndroid ? 300 : 100
    property real _reticleHeight:   1
    property real _reticleSpacing:  size * 0.15
    property real _reticleSlot:     _reticleSpacing + _reticleHeight
    property real _longDash:        size * 0.35
    property real _shortDash:       size * 0.2
    property real _fontSize:        ScreenTools.defaultFontPointSize * 0.75
    property real _heading:         vehicle ? vehicle.heading.rawValue : 0

    height: size
    width:  size
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter:   parent.verticalCenter
    clip: true
    Item {
        height: parent.height
        width:  parent.width
        Row{
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter:   parent.verticalCenter
            spacing: _reticleSpacing
            Repeater {
                model: 360
                Rectangle {
                    property string _headingString: vehicle ? _heading.toFixed(0) : "OFF"
                    property string _headingString2: _headingString.length === 1 ? "0" + _headingString : _headingString
                    property string _headingString3: _headingString2.length === 2 ? "0" + _headingString2 : _headingString2
                    property int _pitch: (modelData)
                   // property int _head:  _heading.toFixed(0)
                    anchors.verticalCenter: parent.verticalCenter
                    width:  _reticleHeight
                    height: _shortDash
                    color: "white"
                    antialiasing: true
                    smooth: true
                  /*  QGCLabel {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.horizontalCenterOffset: -(_longDash)
                        anchors.verticalCenter: parent.verticalCenter
                        smooth: true
                        font.family: ScreenTools.demiboldFontFamily
                        font.pointSize: _fontSize
                        text: _pitch
                        color: "white"
                        visible: (_pitch != 0) && ((_pitch % 10) === 0)
                    }*/
                   /* QGCLabel {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.horizontalCenterOffset: (_longDash)
                        anchors.verticalCenter: parent.verticalCenter
                        smooth: true
                        font.family: ScreenTools.demiboldFontFamily
                        font.pointSize: _fontSize
                        text: _pitch
                        color: "white"
                        visible: (_pitch != 0) && ((_pitch % 10) === 0)
                    } */
                }
            }
        }
        transform: [ Translate {
                x: -((heading * _reticleSlot / 5) - (_reticleSlot / 2))
                }]
    }
   /* transform: [
        Rotation {
            origin.x: width  / 2
            origin.y: height / 2
            angle:    -rollAngle
            }
    ]*/
}
