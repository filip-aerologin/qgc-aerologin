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
import QtQuick.Dialogs  1.2

import QGroundControl                       1.0
import QGroundControl.Controls              1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.Palette               1.0

Item {
    property var  _activeVehicle:       QGroundControl.multiVehicleManager.activeVehicle
    property bool _communicationLost:   _activeVehicle ? _activeVehicle.connectionLost : false

    QGCPalette { id: qgcPal }

    // Easter egg mechanism
    MouseArea {
        anchors.fill: parent
        onClicked: {
            _clickCount++
            eggTimer.restart()
            if (_clickCount == 5 && !QGroundControl.corePlugin.showAdvancedUI) {
                advancedModeConfirmation.visible = true
            } else if (_clickCount == 7) {
                QGroundControl.corePlugin.showTouchAreas = true
            }
        }

        property int _clickCount: 0

        Timer {
            id:             eggTimer
            interval:       1000
            onTriggered:    parent._clickCount = 0
        }

        MessageDialog {
            id:                 advancedModeConfirmation
            title:              qsTr("Advanced Mode")
            text:               QGroundControl.corePlugin.showAdvancedUIMessage
            standardButtons:    StandardButton.Yes | StandardButton.No

            onYes: {
                QGroundControl.corePlugin.showAdvancedUI = true
                visible = false
            }
        }
    }

    QGCLabel {
        id:                     waitForVehicle       
        anchors.verticalCenter: parent.verticalCenter
        //text:                   ("Oczekiwanie na DC-01 Mucha")  //qsTr("Waiting For Vehicle Connection")
        text:                   qsTr("Waiting For DC-01 Mucha...")
        font.pointSize:         ScreenTools.largeFontPointSize // ScreenTools.mediumFontPointSize  // small
        font.family:            ScreenTools.demiboldFontFamily
        color:                  qgcPal.alertBackground //qgcPal.colorRed
        visible:                !_activeVehicle
    }

    Row {
        id:             indicatorRow
        anchors.top:    parent.top
        anchors.bottom: parent.bottom
        spacing:        ScreenTools.defaultFontPixelWidth * 10// przerwa pomiędzy ikonami (gps, battery itp.) default podzielone przez 1.5
        visible:        _activeVehicle && !_communicationLost

        Repeater {
            model:      _activeVehicle ? _activeVehicle.toolBarIndicators : []
            Loader {
                anchors.top:    parent.top
                anchors.bottom: parent.bottom
                source:         modelData;
            }
        }
    }
    // Brand image --------------------------------------------------------------------------------------------------------------------------------------------------------------
    Image {
        id:                     brandImage
        anchors.right:          parent.right
        anchors.rightMargin:    ScreenTools.defaultFontPixelWidth * 2
        anchors.top:            parent.top
        anchors.topMargin:      -3
        anchors.bottom:         parent.bottom
        anchors.bottomMargin:   -3
        visible:                true //x > indicatorRow.width && !_communicationLost
        fillMode:               Image.PreserveAspectFit
        source:                 _outdoorPalette ? "/qmlimages/UAVS/BrandOutdoor" : "/qmlimages/UAVS/BrandIndoor"
        mipmap:                 true

        property bool   _outdoorPalette:        qgcPal.globalTheme === QGCPalette.Light
        property bool   _corePluginBranding:    QGroundControl.corePlugin.brandImageIndoor.length != 0
        property string _userBrandImageIndoor:  QGroundControl.settingsManager.brandImageSettings.userBrandImageIndoor.value
        property string _userBrandImageOutdoor: QGroundControl.settingsManager.brandImageSettings.userBrandImageOutdoor.value
        property bool   _userBrandingIndoor:    _userBrandImageIndoor.length != 0
        property bool   _userBrandingOutdoor:   _userBrandImageOutdoor.length != 0
        property string _brandImageIndoor:      _userBrandingIndoor ?
                                                    _userBrandImageIndoor : (_userBrandingOutdoor ?
                                                        _userBrandImageOutdoor : (_corePluginBranding ?
                                                            QGroundControl.corePlugin.brandImageIndoor : (_activeVehicle ?
                                                                _activeVehicle.brandImageIndoor : ""
                                                            )
                                                        )
                                                    )
        property string _brandImageOutdoor:     _userBrandingOutdoor ?
                                                    _userBrandImageOutdoor : (_userBrandingIndoor ?
                                                        _userBrandImageIndoor : (_corePluginBranding ?
                                                            QGroundControl.corePlugin.brandImageOutdoor : (_activeVehicle ?
                                                                _activeVehicle.brandImageOutdoor : ""
                                                            )
                                                        )
                                                    )
    }
    //----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    Row {
        anchors.right:       brandImage.left
        anchors.fill:        parent
        anchors.rightMargin: ScreenTools.defaultFontPixelWidth * 18
        layoutDirection:     Qt.RightToLeft
        spacing:             ScreenTools.defaultFontPixelWidth * 2
        visible:             _communicationLost

        QGCButton {
            id:                     disconnectButton
            anchors.verticalCenter: parent.verticalCenter
            text:                   qsTr("Disconnect")
            primary:                true
            onClicked:              _activeVehicle.disconnectInactiveVehicle()
        }

        QGCLabel {
            id:                     connectionLost
            anchors.verticalCenter: parent.verticalCenter
            text:                   qsTr("Communication Lost")
            font.pointSize:         ScreenTools.largeFontPointSize
            font.family:            ScreenTools.demiboldFontFamily
            color:                  "#009EE0"
        }
    }
}
