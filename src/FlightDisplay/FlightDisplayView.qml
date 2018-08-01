/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


import QtQuick                  2.3
import QtQuick.Controls         1.2
import QtQuick.Controls.Styles  1.4
import QtQuick.Dialogs          1.2
import QtLocation               5.3
import QtPositioning            5.3
import QtMultimedia             5.5
import QtQuick.Layouts          1.2

import QGroundControl               1.0
import QGroundControl.FlightDisplay 1.0
import QGroundControl.FlightMap     1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Controls      1.0
import QGroundControl.Palette       1.0
import QGroundControl.Vehicle       1.0
import QGroundControl.Controllers   1.0
import QGroundControl.FactSystem    1.0

/// Flight Display View
QGCView {
    id:             root
    viewPanel:      _panel

    QGCPalette { id: qgcPal; colorGroupEnabled: enabled }

    property alias  guidedController:   guidedActionsController

    property bool activeVehicleJoystickEnabled: _activeVehicle ? _activeVehicle.joystickEnabled : false

    property var    _planMasterController:  masterController
    property var    _missionController:     _planMasterController.missionController
    property var    _geoFenceController:    _planMasterController.geoFenceController
    property var    _rallyPointController:  _planMasterController.rallyPointController
    property var    _activeVehicle:         QGroundControl.multiVehicleManager.activeVehicle
    property var    _videoReceiver:         QGroundControl.videoManager.videoReceiver
    property bool   _recordingVideo:        _videoReceiver && _videoReceiver.recording
    property bool   _mainIsMap:             QGroundControl.videoManager.hasVideo ? QGroundControl.loadBoolGlobalSetting(_mainIsMapKey,  true) : true
  //  property bool   _mainIsMap2:            QGroundControl.videoManager.hasVideo ? QGroundControl.loadBoolGlobalSetting(_mainIsMapKey2,  true) : true
    property bool   _isPipVisible:          QGroundControl.videoManager.hasVideo ? QGroundControl.loadBoolGlobalSetting(_PIPVisibleKey, true) : false
    property bool   _isPipVisible2:         QGroundControl.videoManager2.hasVideo ? QGroundControl.loadBoolGlobalSetting(_PIPVisibleKey2, true) : false
    property bool   _mainIsVideo1:          false
    property bool   _mainIsVideo2:          false
    property bool   _trigger1:          false
    property bool   _trigger2:          false
    property real   _savedZoomLevel:        0
    property real   _margins:               ScreenTools.defaultFontPixelWidth / 2
    property real   _pipSize:               flightView.width * 0.2
    property real   _pipSize2:              flightView.width * 0.2
    property alias  _guidedController:      guidedActionsController
    property alias  _altitudeSlider:        altitudeSlider


    readonly property var       _dynamicCameras:        _activeVehicle ? _activeVehicle.dynamicCameras : null
    readonly property bool      _isCamera:              _dynamicCameras ? _dynamicCameras.cameras.count > 0 : false
    readonly property bool      isBackgroundDark:       _mainIsMap ? (_flightMap ? _flightMap.isSatelliteMap : true) : true
    readonly property real      _defaultRoll:           0
    readonly property real      _defaultPitch:          0
    readonly property real      _defaultHeading:        0
    readonly property real      _defaultAltitudeAMSL:   0
    readonly property real      _defaultGroundSpeed:    0
    readonly property real      _defaultAirSpeed:       0
    readonly property string    _mapName:               "FlightDisplayView"
    readonly property string    _showMapBackgroundKey:  "/showMapBackground"
    readonly property string    _mainIsMapKey:          "MainFlyWindowIsMap"
    readonly property string    _mainIsMapKey2:         "MainFlyWindowIsMap"
    readonly property string    _PIPVisibleKey:         "IsPIPVisible"
    readonly property string    _PIPVisibleKey2:        "IsPIPVisible"

    function setStates() {
        //QGroundControl.saveBoolGlobalSetting(_mainIsMapKey, _mainIsMap)
        if(_mainIsMap) {
            //-- Adjust Margins
            _flightMapContainer.state    = "fullMode"
            _flightMapContainer2.state   = "fullMode"
            _flightVideo.state           = "pipMode"
            _flightVideo2.state          = "pipMode"
            //-- Save/Restore Map Zoom Level
            if(_savedZoomLevel != 0) {
                _flightMap.zoomLevel = _savedZoomLevel
                _flightMap2.zoomLevel = _savedZoomLevel
            }
            else
                _savedZoomLevel = _flightMap.zoomLevel
        }
        else {
            _flightMapContainer.state    = "pipMode"
            _flightMapContainer2.state   = "pipMode"
            //-- Set Map Zoom Level
            _savedZoomLevel = _flightMap.zoomLevel
            _savedZoomLevel = _flightMap2.zoomLevel
            _flightMap.zoomLevel = _savedZoomLevel - 3
            _flightMap2.zoomLevel = _savedZoomLevel - 3
          //  _flightMap.zoomLevel = _savedZoomLevel - 3
          //  _flightMap2.zoomLevel = _savedZoomLevel - 3

            if (_mainIsVideo1) {
                _flightVideo.state        = "fullMode"
                _flightVideo2.state       = "pipMode"
            }
            if (_mainIsVideo2) {
                _flightVideo.state       = "pipMode"
                _flightVideo2.state       = "fullMode"
            }
        }
    }

    function setPipVisibility(state) {
        _isPipVisible = state;
        QGroundControl.saveBoolGlobalSetting(_PIPVisibleKey, state)
    }
    function setPipVisibility2(state) {
        _isPipVisible2 = state;
        QGroundControl.saveBoolGlobalSetting(_PIPVisibleKey2, state)
    }

    PlanMasterController {
        id:                     masterController
        Component.onCompleted:  start(false /* editMode */)
    }

    Connections {
        target:                     _missionController
        onResumeMissionReady:       guidedActionsController.confirmAction(guidedActionsController.actionResumeMissionReady)
        onResumeMissionUploadFail:  guidedActionsController.confirmAction(guidedActionsController.actionResumeMissionUploadFail)
    }

    Component.onCompleted: {
        setStates()
        if(QGroundControl.corePlugin.options.flyViewOverlay.toString().length) {
            flyViewOverlay.source = QGroundControl.corePlugin.options.flyViewOverlay
        }
    }

    // The following code is used to track vehicle states such that we prompt to remove mission from vehicle when mission completes

    property bool vehicleArmed:                 _activeVehicle ? _activeVehicle.armed : true // true here prevents pop up from showing during shutdown
    property bool vehicleWasArmed:              false
    property bool vehicleInMissionFlightMode:   _activeVehicle ? (_activeVehicle.flightMode === _activeVehicle.missionFlightMode) : false
    property bool promptForMissionRemove:       false

    onVehicleArmedChanged: {
        if (vehicleArmed) {
            if (!promptForMissionRemove) {
                promptForMissionRemove = vehicleInMissionFlightMode
                vehicleWasArmed = true
            }
        } else {
            if (promptForMissionRemove && (_missionController.containsItems || _geoFenceController.containsItems || _rallyPointController.containsItems)) {
                // ArduPilot has a strange bug which prevents mission clear from working at certain times, so we can't show this dialog
                if (!_activeVehicle.apmFirmware) {
                    root.showDialog(missionCompleteDialogComponent, qsTr("Flight Plan complete"), showDialogDefaultWidth, StandardButton.Close)
                }
            }
            promptForMissionRemove = false
        }
    }

    onVehicleInMissionFlightModeChanged: {
        if (!promptForMissionRemove && vehicleArmed) {
            promptForMissionRemove = true
        }
    }

    Component {
        id: missionCompleteDialogComponent

        QGCViewDialog {
            QGCFlickable {
                anchors.fill:   parent
                contentHeight:  column.height

                ColumnLayout {
                    id:                 column
                    anchors.margins:    _margins
                    anchors.left:       parent.left
                    anchors.right:      parent.right
                    spacing:            ScreenTools.defaultFontPixelHeight

                    QGCLabel {
                        Layout.fillWidth:       true
                        text:                   qsTr("%1 Images Taken").arg(_activeVehicle.cameraTriggerPoints.count)
                        horizontalAlignment:    Text.AlignHCenter
                        visible:                _activeVehicle.cameraTriggerPoints.count != 0
                    }

                    QGCButton {
                        Layout.fillWidth:   true
                        text:               qsTr("Remove plan from vehicle")
                        onClicked: {
                            _planMasterController.removeAllFromVehicle()
                            hideDialog()
                        }
                    }

                    QGCButton {
                        Layout.fillWidth:   true
                        text:               qsTr("Leave plan on vehicle")
                        anchors.horizontalCenter:   parent.horizontalCenter
                        onClicked:                  hideDialog()
                    }
                }
            }
        }
    }

    QGCMapPalette { id: mapPal; lightColors: _mainIsMap ? _flightMap.isSatelliteMap : true }


    QGCViewPanel {
        id:             _panel
        anchors.fill:   parent

        //-- Map View
        //   For whatever reason, if FlightDisplayViewMap is the _panel item, changing
        //   width/height has no effect.
        Item {
            id: _flightMapContainer
            z:  (_mainIsVideo1 || _mainIsVideo2) ? _panel.z + 2 : _panel.z + 1
            anchors.left:   _panel.left
            anchors.bottom: _panel.bottom
            visible:        _mainIsMap || _isPipVisible && _mainIsVideo1
            width:          if(_mainIsVideo1 || _mainIsVideo2) _pipSize
                            else _panel.width
            height:         if(_mainIsVideo1 || _mainIsVideo2) _pipSize * (9/16)
                            else _panel.height
            states: [
                State {
                    name:   "pipMode"
                    PropertyChanges {
                        target:             _flightMapContainer
                        anchors.bottomMargin:     ScreenTools.defaultFontPixelHeight * 2.5
                        anchors.leftMargin:     ScreenTools.defaultFontPixelHeight
                    }
                },
                State {
                    name:   "fullMode"
                    PropertyChanges {
                        target:             _flightMapContainer
                        anchors.margins:    0
                    }
                }
            ]
            FlightDisplayViewMap {
                id:                         _flightMap
                anchors.fill:               parent
                planMasterController:       masterController
                guidedActionsController:    _guidedController
                flightWidgets:              flightDisplayViewWidgets
                rightPanelWidth:            ScreenTools.defaultFontPixelHeight * 9
                qgcView:                    root
                multiVehicleView:           !singleVehicleView.checked
                scaleState:                 (_mainIsMap && flyViewOverlay.item) ? (flyViewOverlay.item.scaleState ? flyViewOverlay.item.scaleState : "bottomMode") : "bottomMode"
            }
        }


        ///// NEW FLIGHTMAPCONTAINER


        Item {
            id: _flightMapContainer2
            z:  (_mainIsVideo1 || _mainIsVideo2) ? _panel.z + 2 : _panel.z + 1
            anchors.right:  _panel.right
            anchors.bottom: _panel.bottom
            visible:        _mainIsMap || _isPipVisible2 && _mainIsVideo2
            width:          if(_mainIsVideo1 || _mainIsVideo2) _pipSize2
                            else _panel.width
            height:         if(_mainIsVideo1 || _mainIsVideo2) _pipSize2 * (9/16)
                            else _panel.height
            states: [
                State {
                    name:   "pipMode"
                    PropertyChanges {
                        target:             _flightMapContainer2
                        anchors.bottomMargin:     ScreenTools.defaultFontPixelHeight * 2.5
                        anchors.rightMargin:     ScreenTools.defaultFontPixelHeight
                    }
                },
                State {
                    name:   "fullMode"
                    PropertyChanges {
                        target:             _flightMapContainer2
                        anchors.margins:    0
                    }
                }
            ]
           FlightDisplayViewMap {
                id:                         _flightMap2
                anchors.fill:               parent
                planMasterController:       masterController
                guidedActionsController:    _guidedController
                flightWidgets:              flightDisplayViewWidgets
                rightPanelWidth:            ScreenTools.defaultFontPixelHeight * 9
                qgcView:                    root
                multiVehicleView:           !singleVehicleView.checked
                scaleState:                 (_mainIsMap && flyViewOverlay.item) ? (flyViewOverlay.item.scaleState ? flyViewOverlay.item.scaleState : "bottomMode") : "bottomMode"
            }


        }


        //-- Video View
        Item {
            id:             _flightVideo
            z:              !_mainIsVideo1 ? _panel.z + 2 : _panel.z + 1
            width:          if(_mainIsVideo1) _panel.width
                            else _pipSize
            height:         if(_mainIsVideo1) _panel.height
                            else _pipSize * (9/16)         
            anchors.left:   _panel.left
            anchors.bottom: _panel.bottom
            visible:        QGroundControl.videoManager.hasVideo && ((!_mainIsMap && !_mainIsVideo2) || _isPipVisible )
            states: [
                State {
                    name:   "pipMode"
                    PropertyChanges {
                        target: _flightVideo
                        anchors.bottomMargin:     ScreenTools.defaultFontPixelHeight * 2.5
                        anchors.leftMargin:       ScreenTools.defaultFontPixelHeight
                    }
                },
                State {
                    name:   "fullMode"
                    PropertyChanges {
                        target: _flightVideo
                        anchors.margins:    0
                    }
                }
            ]
            //-- Video Streaming
            FlightDisplayViewVideo {
                anchors.fill:   parent
                visible:        QGroundControl.videoManager.isGStreamer
            }
            //-- UVC Video (USB Camera or Video Device)
            Loader {
                id:             cameraLoader
                anchors.fill:   parent
                visible:        !QGroundControl.videoManager.isGStreamer
                source:         QGroundControl.videoManager.uvcEnabled ? "qrc:/qml/FlightDisplayViewUVC.qml" : "qrc:/qml/FlightDisplayViewDummy.qml"
            }
        }
        QGCPipable {
            id:                 _flightVideoPipControl
            z:                  _flightVideo.z + 3
            width:              _pipSize
            height:             _pipSize * (9/16)
            anchors.left:       _panel.left
            anchors.bottom:     _panel.bottom
            anchors.bottomMargin:     ScreenTools.defaultFontPixelHeight * 2.5
            anchors.leftMargin:     ScreenTools.defaultFontPixelHeight
            visible:            QGroundControl.videoManager.hasVideo && !QGroundControl.videoManager.fullScreen
            isHidden:           !_isPipVisible
            isDark:             isBackgroundDark
            onActivated: {
                if (_mainIsVideo1 == true) {
                    _mainIsMap = true
                    _mainIsVideo1 = false
                    setStates()
                }
                else {
                    _mainIsMap = false
                    _mainIsVideo1 = true
                    _mainIsVideo2 = false
                    setStates()// zmiana parametrów okienek w liscie multivechicle
                }

            }
            onHideIt: {
                setPipVisibility(!state)
            }
            onNewWidth: {
                _pipSize = newWidth
            }
        }
       //-- NEW VIDEO VIEW
        Item {
            id:             _flightVideo2
            z:             !_mainIsVideo2 ? _panel.z + 2 : _panel.z + 1
            width:          if(_mainIsVideo2) _panel.width
                            else _pipSize2
            height:         if(_mainIsVideo2) _panel.height
                            else _pipSize2 * (9/16)
            anchors.right:  _panel.right
            anchors.bottom: _panel.bottom
            visible:        QGroundControl.videoManager2.hasVideo && ((!_mainIsMap && !_mainIsVideo1) || _isPipVisible2)
            states: [
                State {
                    name:   "pipMode"
                    PropertyChanges {
                        target: _flightVideo2
                        anchors.bottomMargin:     ScreenTools.defaultFontPixelHeight * 2.5
                        anchors.rightMargin:     ScreenTools.defaultFontPixelHeight
                    }
                },
                State {
                    name:   "fullMode"
                    PropertyChanges {
                        target: _flightVideo2
                        anchors.margins:    0
                    }
                }
            ]
            //-- Video Streaming
            FlightDisplayViewVideo2 {
                anchors.fill:   parent
                visible:        QGroundControl.videoManager2.isGStreamer
            }
            //-- UVC Video (USB Camera or Video Device)
            Loader {
                id:             cameraLoader2
                anchors.fill:   parent
                visible:        !QGroundControl.videoManager2.isGStreamer
                source:         QGroundControl.videoManager2.uvcEnabled ? "qrc:/qml/FlightDisplayViewUVC.qml" : "qrc:/qml/FlightDisplayViewDummy.qml"
            }
        }
        QGCPipableinv {
            id:                 _flightVideoPipControl2
            z:                  _flightVideo2.z + 3
            width:              _pipSize2
            height:             _pipSize2 * (9/16)
            anchors.right:      _panel.right
            anchors.bottom:     _panel.bottom
            anchors.bottomMargin:     ScreenTools.defaultFontPixelHeight * 2.5
            anchors.rightMargin:     ScreenTools.defaultFontPixelHeight
            visible:            QGroundControl.videoManager2.hasVideo && !QGroundControl.videoManager2.fullScreen
            isHidden:           !_isPipVisible2
            isDark:             isBackgroundDark
            onActivated: {
                if (_mainIsVideo2 == true) {
                    _mainIsMap = true
                    _mainIsVideo2 = false
                    setStates()
                }
                else {
                    _mainIsMap = false
                    _mainIsVideo1 = false
                    _mainIsVideo2 = true
                    setStates()
                }
            }
            onHideIt: {
                setPipVisibility2(!state)
            }
            onNewWidth: {
                _pipSize2 = newWidth
            }
        }
        ///////////////////////////////////////////////////////////////

        // CheckBox single/multi-vechicle
        Row {
            id:                     singleMultiSelector
            anchors.topMargin:      ScreenTools.toolbarHeight + _margins
            anchors.rightMargin:    _margins + 10
            anchors.right:          parent.right
            anchors.top:            parent.top
            spacing:                ScreenTools.defaultFontPixelWidth + 10
            z:                      _panel.z + 4
            visible:                QGroundControl.multiVehicleManager.vehicles.count > 1

            ExclusiveGroup { id: multiVehicleSelectorGroup }

            QGCRadioButton {
                id:             singleVehicleView
                exclusiveGroup: multiVehicleSelectorGroup
                text:           qsTr("Single")
                checked:        true
                color:          mapPal.text
            }

            QGCRadioButton {
                exclusiveGroup: multiVehicleSelectorGroup
                text:           qsTr("Multi-Vehicle")
                color:          mapPal.text
            }
        }

        FlightDisplayViewWidgets {
            id:                 flightDisplayViewWidgets
            z:                  _panel.z + 4
            height:             ScreenTools.availableHeight - (singleMultiSelector.visible ? singleMultiSelector.height + _margins : 0)
            anchors.left:       parent.left
            anchors.right:      altitudeSlider.visible ? altitudeSlider.left : parent.right
            anchors.bottom:     parent.bottom
            qgcView:            root
            useLightColors:     isBackgroundDark
            missionController:  _missionController
            visible:            singleVehicleView.checked && !QGroundControl.videoManager.fullScreen
        }

        //-------------------------------------------------------------------------
        //-- Loader helper for plugins to overlay elements over the fly view
        Loader {
            id:                 flyViewOverlay
            z:                  flightDisplayViewWidgets.z + 1
            visible:            !QGroundControl.videoManager.fullScreen
            height:             ScreenTools.availableHeight
            anchors.left:       parent.left
            anchors.right:      altitudeSlider.visible ? altitudeSlider.left : parent.right
            anchors.bottom:     parent.bottom

            property var qgcView: root
        }

        // Button to start/stop video recording
        /*Item {
            z:                  _flightVideoPipControl.z + 1
            anchors.margins:    ScreenTools.defaultFontPixelHeight / 2
            anchors.bottom:     _flightVideo.bottom
            anchors.right:      _flightVideo.right
            height:             ScreenTools.defaultFontPixelHeight * 2
            width:              height
            visible:            _videoReceiver && _videoReceiver.videoRunning && QGroundControl.settingsManager.videoSettings.showRecControl.rawValue && _flightVideo.visible && !_isCamera && !QGroundControl.videoManager.fullScreen
            opacity:            0.75

            readonly property string recordBtnBackground: "BackgroundName"

            Rectangle {
                id:                 recordBtnBackground
                anchors.top:        parent.top
                anchors.bottom:     parent.bottom
                width:              height
                radius:             _recordingVideo ? 0 : height
                color:              "red"

                SequentialAnimation on visible {
                    running:        _recordingVideo
                    loops:          Animation.Infinite
                    PropertyAnimation { to: false; duration: 1000 }
                    PropertyAnimation { to: true;  duration: 1000 }
                }
            }

            QGCColoredImage {
                anchors.top:                parent.top
                anchors.bottom:             parent.bottom
                anchors.horizontalCenter:   parent.horizontalCenter
                width:                      height * 0.625
                sourceSize.width:           width
                source:                     "/qmlimages/CameraIcon.svg"
                visible:                    recordBtnBackground.visible
                fillMode:                   Image.PreserveAspectFit
                color:                      "white"
            }

            MouseArea {
                anchors.fill:   parent
                onClicked: {
                    if (_videoReceiver) {
                        if (_recordingVideo) {
                            _videoReceiver.stopRecording()
                            // reset blinking animation
                            recordBtnBackground.visible = true
                        } else {
                            _videoReceiver.startRecording()
                        }
                    }
                }
            }
        }*/

        MultiVehicleList {
            anchors.margins:    _margins
            anchors.top:        singleMultiSelector.bottom
            anchors.right:      parent.right
            anchors.bottom:     parent.bottom
            width:              ScreenTools.defaultFontPixelWidth * 36//30
            visible:            !singleVehicleView.checked && !QGroundControl.videoManager.fullScreen
            z:                  _panel.z + 4
        }

        //-- Virtual Joystick
        /*
        Loader {
            id:                         virtualJoystickMultiTouch
            z:                          _panel.z + 5
            width:                      parent.width  - (_flightVideoPipControl.width / 2)
            height:                     Math.min(ScreenTools.availableHeight * 0.25, ScreenTools.defaultFontPixelWidth * 16)
            visible:                    (_virtualJoystick ? _virtualJoystick.value : false) && !QGroundControl.videoManager.fullScreen
            anchors.bottom:             _flightVideoPipControl.top
            anchors.bottomMargin:       ScreenTools.defaultFontPixelHeight * 2
            anchors.horizontalCenter:   flightDisplayViewWidgets.horizontalCenter
            source:                     "qrc:/qml/VirtualJoystick.qml"
            active:                     _virtualJoystick ? _virtualJoystick.value : false

            property bool useLightColors: isBackgroundDark

            property Fact _virtualJoystick: QGroundControl.settingsManager.appSettings.virtualJoystick
        } */

        ToolStrip { ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            visible:            (_activeVehicle ? _activeVehicle.guidedModeSupported : true) && !QGroundControl.videoManager.fullScreen
            id:                 toolStrip
            anchors.rightMargin: ScreenTools.defaultFontPixelWidth * 30 + ScreenTools.defaultFontPixelHeight * 2
            anchors.right:       _panel.right
            //anchors.bottomMargin:  ScreenTools.toolbarHeight + (_margins * 2) + 20
            anchors.topMargin: ScreenTools.toolbarHeight + ScreenTools.defaultFontPixelHeight
            anchors.top:     _panel.top
            z:                  _panel.z + 4
            title:              qsTr("Fly")
            maxHeight:          (_flightVideo.visible ? _flightVideo.y : parent.width) - toolStrip.x
            buttonVisible:      [ _guidedController.showTakeoff || !_guidedController.showLand, _guidedController.showLand && !_guidedController.showTakeoff, true, true, true, _guidedController.smartShotsAvailable ]
            buttonEnabled:      [ _guidedController.showTakeoff, _guidedController.showLand, _guidedController.showRTL, _guidedController.showPause, _anyActionAvailable, _anySmartShotAvailable ]

            property bool _anyActionAvailable: _guidedController.showStartMission || _guidedController.showResumeMission || _guidedController.showChangeAlt || _guidedController.showLandAbort
            property bool _anySmartShotAvailable: _guidedController.showOrbit
            property var _actionModel: [
                {
                    title:      _guidedController.startMissionTitle,
                    text:       _guidedController.startMissionMessage,
                    action:     _guidedController.actionStartMission,
                    visible:    _guidedController.showStartMission
                },
                {
                    title:      _guidedController.continueMissionTitle,
                    text:       _guidedController.continueMissionMessage,
                    action:     _guidedController.actionContinueMission,
                    visible:    _guidedController.showContinueMission
                },
                {
                    title:      _guidedController.resumeMissionTitle,
                    text:       _guidedController.resumeMissionMessage,
                    action:     _guidedController.actionResumeMission,
                    visible:    _guidedController.showResumeMission
                },
                {
                    title:      _guidedController.changeAltTitle,
                    text:       _guidedController.changeAltMessage,
                    action:     _guidedController.actionChangeAlt,
                    visible:    _guidedController.showChangeAlt
                },
                {
                    title:      _guidedController.landAbortTitle,
                    text:       _guidedController.landAbortMessage,
                    action:     _guidedController.actionLandAbort,
                    visible:    _guidedController.showLandAbort
                }
            ]
            property var _smartShotModel: [
                {
                    title:      _guidedController.orbitTitle,
                    text:       _guidedController.orbitMessage,
                    action:     _guidedController.actionOrbit,
                    visible:    _guidedController.showOrbit
                }
            ]

            model: [
                {
                    name:       _guidedController.takeoffTitle,
                    iconSource: "/res/takeoff.svg",
                    action:     _guidedController.actionTakeoff
                },
                {
                    name:       _guidedController.landTitle,
                    iconSource: "/res/land.svg",
                    action:     _guidedController.actionLand
                },
             {
                    name:       _guidedController.rtlTitle,
                    iconSource: "/res/rtl.svg",
                    action:     _guidedController.actionRTL
                },
            ]

            onClicked: {
                guidedActionsController.closeAll()
                var action = model[index].action
                _guidedController.confirmAction(action)
            }
        }

        ToolStrip { ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            visible:            (_activeVehicle ? _activeVehicle.guidedModeSupported : true) && !QGroundControl.videoManager.fullScreen
            id:                 toolStrip2
            anchors.left:       toolStrip.left
            anchors.topMargin: ScreenTools.defaultFontPixelHeight
            anchors.top:     toolStrip.bottom
            z:                  _panel.z + 4
            title:              qsTr("Fly")
            maxHeight:          (_flightVideo.visible ? _flightVideo.y : parent.width) - toolStrip2.x
            buttonVisible:      [ true, true, _guidedController.smartShotsAvailable ]
            buttonEnabled:      [ _guidedController.showPause, _anyActionAvailable, _anySmartShotAvailable ]

            property bool _anyActionAvailable: _guidedController.showStartMission || _guidedController.showResumeMission || _guidedController.showChangeAlt || _guidedController.showLandAbort  /* WIFI SEARCH DISABLED - TO ENABLE UNCOMMENT || _guidedController.showWifiOn || _guidedController.showWifiOff */
            property bool _anySmartShotAvailable: _guidedController.showOrbit
            property var _actionModel: [
                {
                    title:      _guidedController.startMissionTitle,
                    text:       _guidedController.startMissionMessage,
                    action:     _guidedController.actionStartMission,
                    visible:    _guidedController.showStartMission
                },
                {
                    title:      _guidedController.continueMissionTitle,
                    text:       _guidedController.continueMissionMessage,
                    action:     _guidedController.actionContinueMission,
                    visible:    _guidedController.showContinueMission
                },
                {
                    title:      _guidedController.resumeMissionTitle,
                    text:       _guidedController.resumeMissionMessage,
                    action:     _guidedController.actionResumeMission,
                    visible:    _guidedController.showResumeMission
                },
                {
                    title:      _guidedController.changeAltTitle,
                    text:       _guidedController.changeAltMessage,
                    action:     _guidedController.actionChangeAlt,
                    visible:    _guidedController.showChangeAlt
                },
                {
                    title:      _guidedController.landAbortTitle,
                    text:       _guidedController.landAbortMessage,
                    action:     _guidedController.actionLandAbort,
                    visible:    _guidedController.showLandAbort
                }
                 /* WIFI SEARCH DISABLED - TO ENABLE UNCOMMENT

                ,
                {
                    title:      _guidedController.wifiOnTitle,
                    text:       _guidedController.wifiOnMessage,
                    action:     _guidedController.actionWifiOn,
                    visible:    _guidedController.showWifiOn
                },
                {
                    title:      _guidedController.wifiOffTitle,
                    text:       _guidedController.wifiOffMessage,
                    action:     _guidedController.actionWifiOff,
                    visible:    _guidedController.showWifiOff
                }
                */
            ]
            property var _smartShotModel: [
                {
                    title:      _guidedController.orbitTitle,
                    text:       _guidedController.orbitMessage,
                    action:     _guidedController.actionOrbit,
                    visible:    _guidedController.showOrbit
                }
            ]

            model: [

                   {///////////////////////////////////////////////////////////////////////////////
                    name:       _guidedController.pauseTitle,
                    iconSource: "/res/pause-mission.svg",
                    action:     _guidedController.actionPause
                },
                {
                    name:       qsTr("Action"),
                    iconSource: "/res/action.svg",
                    action:     -1
                },

                /* No firmware support any smart shots yet
                {
                    name:       qsTr("Smart"),
                    iconSource: "/qmlimages/MapCenter.svg",
                    action:     -1
                },*/

            ]

            onClicked: {
                guidedActionsController.closeAll()
                var action = model[index].action
                if (action === -1) {
                    if (index == 1) {
                        guidedActionList.model   = _actionModel
                        guidedActionList.visible = true
                    }

                } else {
                    _guidedController.confirmAction(action)
                }
            }
        }



        ToolStrip {
            id:                 toolStripZoom
            anchors.left:       toolStrip.left
            anchors.topMargin:  ScreenTools.defaultFontPixelHeight
            anchors.top:        toolStrip2.bottom
            color:              qgcPal.window
            title:              qsTr("Plan")
            z:                  QGroundControl.zOrderWidgets
            showAlternateIcon:  [ false, false, masterController.dirty, false, false, false ]
            rotateImage:        [ false, false, masterController.syncInProgress, false, false, false ]
            animateImage:       [ false, false, masterController.dirty, false, false, false ]
            buttonEnabled:      [ true, true, !masterController.syncInProgress, true, true, true ]
            buttonVisible:      [ true, true, true, true, _showZoom, _showZoom ]
            //maxHeight:          mapScale.y - toolStripZoom.y

            property bool _showZoom: !ScreenTools.isMobile

            model: [
                {
                    name:               "In",
                    iconSource:         "/qmlimages/ZoomPlus.svg"
                },
                {
                    name:               "Out",
                    iconSource:         "/qmlimages/ZoomMinus.svg"
                }
            ]

            onClicked: {
                switch (index) {
                case 0:
                    _flightMap.zoomLevel += 0.5
                    _flightMap2.zoomLevel += 0.5
                    break
                case 1:
                    _flightMap.zoomLevel -= 0.5
                    _flightMap2.zoomLevel -= 0.5
                    break
                }
            }
        }
 /* WIFI SEARCH DISABLED - TO ENABLE UNCOMMENT
        ToolStrip {
            id:                 toolStripWifi
            anchors.left:       toolStrip.left
            anchors.leftMargin: toolStrip.width / 4
            anchors.topMargin:  ScreenTools.defaultFontPixelHeight
            anchors.top:        toolStripZoom.bottom
            color:              qgcPal.window
            visible:            _guidedController.showWifiOff
            title:              qsTr("Wifi")
            z:                  QGroundControl.zOrderWidgets
            showAlternateIcon:  [ false ]
            rotateImage:        [ false ]
            animateImage:       [ true  ]
            buttonEnabled:      [ true  ]
            buttonVisible:      [ true  ]
            //maxHeight:          mapScale.y - toolStripZoom.y

            property bool _showZoom: !ScreenTools.isMobile

            model: [
                {
                    name:               "Search",
                    iconSource:         "/qmlimages/wifi.svg"
                }
            ]
        }
*/
        GuidedActionsController {
            id:                 guidedActionsController
            missionController:  _missionController
            confirmDialog:      guidedActionConfirm
            actionList:         guidedActionList
            altitudeSlider:     _altitudeSlider
            z:                  _flightVideoPipControl.z + 1

            onShowStartMissionChanged: {
                if (showStartMission && !showResumeMission) {
                    confirmAction(actionStartMission)
                }
            }

            onShowContinueMissionChanged: {
                if (showContinueMission) {
                    confirmAction(actionContinueMission)
                }
            }

            onShowResumeMissionChanged: {
                if (showResumeMission) {
                    confirmAction(actionResumeMission)
                }
            }

            onShowLandAbortChanged: {
                if (showLandAbort) {
                    confirmAction(actionLandAbort)
                }
            }

            /// Close all dialogs
            function closeAll() {
                mainWindow.enableToolbar()
                rootLoader.sourceComponent  = null
                guidedActionConfirm.visible = false
                guidedActionList.visible    = false
                altitudeSlider.visible      = false
            }
        }

        GuidedActionConfirm {
            id:                         guidedActionConfirm
            anchors.margins:            _margins
            anchors.bottom:             parent.bottom
            anchors.horizontalCenter:   parent.horizontalCenter
            guidedController:           _guidedController
            altitudeSlider:             _altitudeSlider
        }

        GuidedActionList {
            id:                         guidedActionList
            anchors.margins:            _margins
            anchors.bottom:             parent.bottom
            anchors.horizontalCenter:   parent.horizontalCenter
            guidedController:           _guidedController
        }

        //-- Altitude slider
        GuidedAltitudeSlider {
            id:                 altitudeSlider
            anchors.margins:    _margins
            anchors.right:      parent.right
            anchors.topMargin:  ScreenTools.toolbarHeight + _margins
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            z:                  _guidedController.z
            radius:             ScreenTools.defaultFontPixelWidth / 2
            width:              ScreenTools.defaultFontPixelWidth * 10
            color:              qgcPal.window
            visible:            false
        }
    }
}
