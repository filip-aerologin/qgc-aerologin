/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#include "VideoSettings.h"

#include <QQmlEngine>
#include <QtQml>
#include <QVariantList>

#ifndef QGC_DISABLE_UVC
#include <QCameraInfo>
#endif

const char* VideoSettings::videoSettingsGroupName = "Video";

const char* VideoSettings::videoSourceName =        "VideoSource";
const char* VideoSettings::udpPortName =            "VideoUDPPort";
const char* VideoSettings::udpPortName2 =            "VideoUDPPort2";
const char* VideoSettings::rtspUrlName =            "VideoRTSPUrl";
const char* VideoSettings::tcpUrlName =             "VideoTCPUrl";
const char* VideoSettings::videoAspectRatioName =   "VideoAspectRatio";
const char* VideoSettings::videoGridLinesName =     "VideoGridLines";
const char* VideoSettings::showRecControlName =     "ShowRecControl";
const char* VideoSettings::recordingFormatName =    "RecordingFormat";
const char* VideoSettings::maxVideoSizeName =       "MaxVideoSize";
const char* VideoSettings::enableStorageLimitName = "EnableStorageLimit";
const char* VideoSettings::rtspTimeoutName =        "RtspTimeout";

const char* VideoSettings::videoSourceNoVideo =     "No Video Available";
const char* VideoSettings::videoDisabled =          "Video Stream Disabled";
const char* VideoSettings::videoSourceUDP =         "UDP Video Stream";
const char* VideoSettings::videoSourceRTSP =        "RTSP Video Stream";
const char* VideoSettings::videoSourceTCP =         "TCP-MPEG2 Video Stream";

VideoSettings::VideoSettings(QObject* parent)
    : SettingsGroup(videoSettingsGroupName, QString() /* root settings group */, parent)
    , _videoSourceFact(NULL)
    , _udpPortFact(NULL)
    , _udpPortFact2(NULL)
    , _tcpUrlFact(NULL)
    , _rtspUrlFact(NULL)
    , _videoAspectRatioFact(NULL)
    , _gridLinesFact(NULL)
    , _showRecControlFact(NULL)
    , _recordingFormatFact(NULL)
    , _maxVideoSizeFact(NULL)
    , _enableStorageLimitFact(NULL)
    , _rtspTimeoutFact(NULL)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
    qmlRegisterUncreatableType<VideoSettings>("QGroundControl.SettingsManager", 1, 0, "VideoSettings", "Reference only");

    // Setup enum values for videoSource settings into meta data
    bool noVideo = false;
    QStringList videoSourceList;
#ifdef QGC_GST_STREAMING
#ifndef NO_UDP_VIDEO
    videoSourceList.append(videoSourceUDP);
#endif
    //videoSourceList.append(videoSourceRTSP);                          // Disable TCP/RTSP
    videoSourceList.append(videoSourceTCP);
#endif
/*#ifndef QGC_DISABLE_UVC                                               // Disable Connected Cameras
    QList<QCameraInfo> cameras = QCameraInfo::availableCameras();
    foreach (const QCameraInfo &cameraInfo, cameras) {
        videoSourceList.append(cameraInfo.description());
    }
#endif*/
    if (videoSourceList.count() == 0) {
        //noVideo = true;
        videoSourceList.append(videoSourceNoVideo);
    } else {
        videoSourceList.insert(0, videoDisabled);
    }
    QVariantList videoSourceVarList;
    foreach (const QString& videoSource, videoSourceList) {
        videoSourceVarList.append(QVariant::fromValue(videoSource));
    }
    _nameToMetaDataMap[videoSourceName]->setEnumInfo(videoSourceList, videoSourceVarList);

    // Set default value for videoSource
    if (noVideo) {
        _nameToMetaDataMap[videoSourceName]->setRawDefaultValue(videoSourceNoVideo);
    } else {
        _nameToMetaDataMap[videoSourceName]->setRawDefaultValue(videoDisabled);
    }
}

Fact* VideoSettings::videoSource(void)
{
    if (!_videoSourceFact) {
        _videoSourceFact = _createSettingsFact(videoSourceName);
    }

    return _videoSourceFact;
}

Fact* VideoSettings::udpPort(void)
{
    if (!_udpPortFact) {
        _udpPortFact = _createSettingsFact(udpPortName);
    }

    return _udpPortFact;
}


Fact* VideoSettings::udpPort2(void)
{
    if (!_udpPortFact2) {
        _udpPortFact2 = _createSettingsFact(udpPortName2);
    }

    return _udpPortFact2;
}


Fact* VideoSettings::rtspUrl(void)
{
    if (!_rtspUrlFact) {
        _rtspUrlFact = _createSettingsFact(rtspUrlName);
    }

    return _rtspUrlFact;
}

Fact* VideoSettings::tcpUrl(void)
{
    if (!_tcpUrlFact) {
        _tcpUrlFact = _createSettingsFact(tcpUrlName);
    }

    return _tcpUrlFact;
}

Fact* VideoSettings::aspectRatio(void)
{
    if (!_videoAspectRatioFact) {
        _videoAspectRatioFact = _createSettingsFact(videoAspectRatioName);
    }

    return _videoAspectRatioFact;
}

Fact* VideoSettings::gridLines(void)
{
    if (!_gridLinesFact) {
        _gridLinesFact = _createSettingsFact(videoGridLinesName);
    }

    return _gridLinesFact;
}

Fact* VideoSettings::showRecControl(void)
{
    if (!_showRecControlFact) {
        _showRecControlFact = _createSettingsFact(showRecControlName);
    }

    return _showRecControlFact;
}

Fact* VideoSettings::recordingFormat(void)
{
    if (!_recordingFormatFact) {
        _recordingFormatFact = _createSettingsFact(recordingFormatName);
    }

    return _recordingFormatFact;
}

Fact* VideoSettings::maxVideoSize(void)
{
    if (!_maxVideoSizeFact) {
        _maxVideoSizeFact = _createSettingsFact(maxVideoSizeName);
    }

    return _maxVideoSizeFact;
}

Fact* VideoSettings::enableStorageLimit(void)
{
    if (!_enableStorageLimitFact) {
        _enableStorageLimitFact = _createSettingsFact(enableStorageLimitName);
    }

    return _enableStorageLimitFact;
}

Fact* VideoSettings::rtspTimeout(void)
{
    if (!_rtspTimeoutFact) {
        _rtspTimeoutFact = _createSettingsFact(rtspTimeoutName);
    }

    return _rtspTimeoutFact;
}
