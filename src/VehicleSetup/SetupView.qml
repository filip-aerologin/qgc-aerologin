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

import QGroundControl                       1.0
import QGroundControl.AutoPilotPlugin       1.0
import QGroundControl.Palette               1.0
import QGroundControl.Controls              1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.MultiVehicleManager   1.0

Rectangle {
    id:     setupView
    color:  qgcPal.window
    z:      QGroundControl.zOrderTopMost

    QGCPalette { id: qgcPal; colorGroupEnabled: true }

    ExclusiveGroup { id: setupButtonGroup }

    readonly property real      _defaultTextHeight: ScreenTools.defaultFontPixelHeight
    readonly property real      _defaultTextWidth:  ScreenTools.defaultFontPixelWidth
    readonly property real      _horizontalMargin:  _defaultTextWidth / 2
    readonly property real      _verticalMargin:    _defaultTextHeight / 2
    readonly property real      _buttonWidth:       _defaultTextWidth * 18
    readonly property string    _armedVehicleText:  qsTr("This operation cannot be performed while the vehicle is armed.")

    property string _messagePanelText:              qsTr("missing message panel text")
    property bool   _fullParameterVehicleAvailable: QGroundControl.multiVehicleManager.parameterReadyVehicleAvailable && !QGroundControl.multiVehicleManager.activeVehicle.parameterManager.missingParameters
    property var    _corePlugin:                    QGroundControl.corePlugin

    function showSummaryPanel()
    {
        if (_fullParameterVehicleAvailable) {
            if (QGroundControl.multiVehicleManager.activeVehicle.autopilot.vehicleComponents.length == 0) {
                panelLoader.setSourceComponent(noComponentsVehicleSummaryComponent)
            } else {
                panelLoader.setSource("VehicleSummary.qml")
            }
        } else if (QGroundControl.multiVehicleManager.parameterReadyVehicleAvailable) {
            panelLoader.setSourceComponent(missingParametersVehicleSummaryComponent)
        } else {
            panelLoader.setSourceComponent(disconnectedVehicleSummaryComponent)
        }
    }

    function showFirmwarePanel()
    {
        if (!ScreenTools.isMobile) {
            panelLoader.setSource("FirmwareUpgrade.qml")
        }
    }

    function showJoystickPanel()
    {
        panelLoader.setSource("JoystickConfig.qml")
    }

    function showParametersPanel()
    {
        panelLoader.setSource("SetupParameterEditor.qml")
    }

    function showPX4FlowPanel()
    {
        panelLoader.setSource("PX4FlowSensor.qml")
    }

    function showVehicleComponentPanel(vehicleComponent)
    {
        var autopilotPlugin = QGroundControl.multiVehicleManager.activeVehicle.autopilot
        var prereq = autopilotPlugin.prerequisiteSetup(vehicleComponent)
        if (prereq !== "") {
            //-- TODO: This cannot be translated when built this way.
            _messagePanelText = prereq + " setup must be completed prior to " + vehicleComponent.name + " setup."
            panelLoader.setSourceComponent(messagePanelComponent)
        } else {
            panelLoader.setSource(vehicleComponent.setupSource, vehicleComponent)
            for(var i = 0; i < componentRepeater.count; i++) {
                var obj = componentRepeater.itemAt(i);
                if (obj.text === vehicleComponent.name) {
                    obj.checked = true;
                    break;
                }
            }
        }
    }

    Component.onCompleted: showSummaryPanel()

    Connections {
        target: QGroundControl.multiVehicleManager

        onParameterReadyVehicleAvailableChanged: {
            if(!QGroundControl.skipSetupPage) {
                if (parameterReadyVehicleAvailable || summaryButton.checked || setupButtonGroup.current != firmwareButton) {
                    // Show/Reload the Summary panel when:
                    //      A new vehicle shows up
                    //      The summary panel is already showing and the active vehicle goes away
                    //      The active vehicle goes away and we are not on the Firmware panel.
                    summaryButton.checked = true
                    showSummaryPanel()
                }
            }
        }
    }

    Component {
        id: noComponentsVehicleSummaryComponent

        Rectangle {
            color: qgcPal.windowShade

            QGCLabel {
                anchors.margins:        _defaultTextWidth * 2
                anchors.fill:           parent
                verticalAlignment:      Text.AlignVCenter
                horizontalAlignment:    Text.AlignHCenter
                wrapMode:               Text.WordWrap
                font.pointSize:         ScreenTools.mediumFontPointSize
                text:                   qsTr("%1 does not currently support setup of your vehicle type. ").arg(QGroundControl.appName) +
                                        "If your vehicle is already configured you can still Fly."

                onLinkActivated: Qt.openUrlExternally(link)
            }
        }
    }

    Component {
        id: disconnectedVehicleSummaryComponent

        //Rectangle {
           // color: qgcPal.windowShade

            QGCLabel {
                anchors.margins:        _defaultTextWidth * 2
                anchors.fill:           parent
                verticalAlignment:      Text.AlignVCenter
                horizontalAlignment:    Text.AlignHCenter
                wrapMode:               Text.WordWrap
                font.pointSize:         ScreenTools.largeFontPointSize
                text:                   qsTr("Vehicle settings and info will display after connecting your vehicle.") +
                                        (ScreenTools.isMobile ? "" : " Click Firmware on the left to upgrade your vehicle.")

                onLinkActivated: Qt.openUrlExternally(link)
            }
        //}
    }

    Component {
        id: missingParametersVehicleSummaryComponent

        Rectangle {
            color: qgcPal.windowShade

            QGCLabel {
                anchors.margins:        _defaultTextWidth * 2
                anchors.fill:           parent
                verticalAlignment:      Text.AlignVCenter
                horizontalAlignment:    Text.AlignHCenter
                wrapMode:               Text.WordWrap
                font.pointSize:         ScreenTools.mediumFontPointSize
                text:                   qsTr("You are currently connected to a vehicle but it did not return the full parameter list. ") +
                                        qsTr("As a result, the full set of vehicle setup options are not available.")

                onLinkActivated: Qt.openUrlExternally(link)
            }
        }
    }

    Component {
        id: messagePanelComponent

        Item {
            QGCLabel {
                anchors.margins:        _defaultTextWidth * 2
                anchors.fill:           parent
                verticalAlignment:      Text.AlignVCenter
                horizontalAlignment:    Text.AlignHCenter
                wrapMode:               Text.WordWrap
                font.pointSize:         ScreenTools.mediumFontPointSize
                text:                   _messagePanelText
            }
        }
    }

    QGCFlickable {
        id:                 buttonScroll
        width:              buttonScroll.width
        //anchors.topMargin:  _verticalMargin * 3
        anchors.top:        parent.top
        anchors.bottom:     parent.bottom
        anchors.leftMargin: _horizontalMargin * 10
        anchors.left:       parent.left
        anchors.rightMargin: _horizontalMargin
        anchors.right:      parent.right
        contentHeight:      buttonScroll.height + _verticalMargin
        flickableDirection: Flickable.VerticalFlick
        clip:               true
        anchors.topMargin:      ScreenTools.defaultPixelHeight

        RowLayout {
            id:         buttonColumn
            spacing:    _defaultTextHeight

            QGCLabel {
                anchors.left:           parent.left
                anchors.top:            parent.top
                font.pointSize:         20 //////////////////////////////////////
                text:                   qsTr("Vehicle Setup  ")
                wrapMode:               Text.WordWrap
                horizontalAlignment:    Text.left//Text.AlignHCenter
                visible:                !ScreenTools.isShortScreen
            }

            Repeater {
                model:                  _corePlugin ? _corePlugin.settingsPages : []
                visible:                _corePlugin && _corePlugin.options.combineSettingsAndSetup

                SubMenuButton {
                    imageResource:      modelData.icon
                    setupIndicator:     false
                    exclusiveGroup:     setupButtonGroup
                    text:               modelData.title
                    visible:            _corePlugin && _corePlugin.options.combineSettingsAndSetup
                    onClicked:          panelLoader.setSource(modelData.url)
                    Layout.fillWidth:   true

                }
            }

            SubMenuButton {
                id:                 summaryButton
                imageResource:      "/qmlimages/PaperPlane.svg"
                setupIndicator:     false
                checked:            true
                exclusiveGroup:     setupButtonGroup
                text:               qsTr("Summary")
                Layout.fillWidth:   true

                onClicked: showSummaryPanel()
            }

            /*SubMenuButton {
                id:                 firmwareButton
                imageResource:      "/qmlimages/FirmwareUpgradeIcon.svg"
                setupIndicator:     false
                exclusiveGroup:     setupButtonGroup
                visible:            !ScreenTools.isMobile && _corePlugin.options.showFirmwareUpgrade
                text:               qsTr("Firmware")
                Layout.fillWidth:   true

                onClicked: showFirmwarePanel()
            }*/

            SubMenuButton {
                id:                 px4FlowButton
                exclusiveGroup:     setupButtonGroup
                visible:            QGroundControl.multiVehicleManager.activeVehicle ? QGroundControl.multiVehicleManager.activeVehicle.genericFirmware : false
                setupIndicator:     false
                text:               qsTr("PX4Flow")
                Layout.fillWidth:   true

                onClicked:      showPX4FlowPanel()
            }

            SubMenuButton {
                id:                 joystickButton
                setupIndicator:     true
                setupComplete:      joystickManager.activeJoystick ? joystickManager.activeJoystick.calibrated : false
                exclusiveGroup:     setupButtonGroup
                visible:            _fullParameterVehicleAvailable && joystickManager.joysticks.length != 0
                text:               qsTr("Joystick")
                Layout.fillWidth:   true

                onClicked: showJoystickPanel()
            }

            Repeater {
                id:     componentRepeater
                model:  _fullParameterVehicleAvailable ? QGroundControl.multiVehicleManager.activeVehicle.autopilot.vehicleComponents : 0

                SubMenuButton {
                    imageResource:      modelData.iconResource
                    setupIndicator:     modelData.requiresSetup
                    setupComplete:      modelData.setupComplete
                    exclusiveGroup:     setupButtonGroup
                    text:               modelData.name
                    visible:            modelData.setupSource.toString() != ""
                    Layout.fillWidth:   true

                    onClicked: showVehicleComponentPanel(modelData)
                }
            }

           /* SubMenuButton {
                setupIndicator:     false
                exclusiveGroup:     setupButtonGroup
                visible:            QGroundControl.multiVehicleManager && QGroundControl.multiVehicleManager.parameterReadyVehicleAvailable && _corePlugin.showAdvancedUI
                text:               qsTr("Parameters")
                Layout.fillWidth:   true

                onClicked: showParametersPanel()
            } */

        }
    }

    /*Rectangle {
        id:                     divider
        anchors.topMargin:      _verticalMargin
        anchors.bottomMargin:   _verticalMargin
        anchors.leftMargin:     _horizontalMargin
        anchors.left:           buttonScroll.right
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        width:                  1
        color:                  qgcPal.windowShade
    }*/

    Loader {
        id:                     panelLoader
        anchors.leftMargin:     _horizontalMargin + 30
        anchors.rightMargin:    _horizontalMargin + 30
        anchors.topMargin:      _verticalMargin * 15
        anchors.bottomMargin:   _verticalMargin
        anchors.left:           parent.left //divider.right
        //anchors.right:          parent.right
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        function setSource(source, vehicleComponent) {
            panelLoader.vehicleComponent = vehicleComponent
            panelLoader.source = source
        }

        function setSourceComponent(sourceComponent, vehicleComponent) {
            panelLoader.vehicleComponent = vehicleComponent
            panelLoader.sourceComponent = sourceComponent
        }

        property var vehicleComponent
    }
}
