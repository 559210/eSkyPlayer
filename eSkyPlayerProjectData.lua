local prototype = class("eSkyPlayerProjectData");
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");

function prototype:ctor()
    self.projectFile_ = nil;
    self.trackMaxLength_ = 0;
end


function prototype:initialize()
    self.projectFile_ = {tracks = {}};
    return true;
end


function prototype:loadProject(filename)
    local tracks, isLoopPlay = self:_loadConfig(filename);
    for i = 1,#tracks do
        local trackPath = filename .. "/" .. tracks[i].name .. ".byte";
        if self:_loadTracks(trackPath) == false then
            return false;
        end
    end
    return true;
end


function  prototype:_loadConfig(filename)
    local path = Util.AppDataRoot .. "/" ..filename .. "/config.byte";
    local buff = misc.readAllBytes(path);
    local isLoopPlay = misc.getBoolByByte(buff:ReadByte());
    local trackCount = buff:ReadShort();
    local tracks = {};
    for i = 1, trackCount do
        local track = {};
        track.name = buff:ReadString();
        tracks[#tracks + 1] = track;
    end
    return tracks, isLoopPlay;
end



function prototype:_loadTracks(trackPath)
    local trackData = nil;
    if string.match(trackPath,"mod/plans/camera/.+/cameraTrack") then
        trackData = newClass("eSkyPlayer/eSkyPlayerCameraMotionTrackData");
        trackData:initialize();
        if trackData:loadTrack(trackPath) == false then
            return false;
        end
    elseif string.match(trackPath,"mod/projects/.+/cameraTrack") then
        trackData = newClass("eSkyPlayer/eSkyPlayerCameraPlanTrackData");
        trackData:initialize();
        if trackData:loadTrack(trackPath) == false then
            return false;
        end
    elseif string.match(trackPath,"mod/plans/camera/.+/cameraMotionTrack") then
        trackData = newClass("eSkyPlayer/eSkyPlayerCameraEffectTrackData");
        trackData:initialize();
        if trackData:loadTrack(trackPath) == false then
            return false;
        end
    else
        return true;
    end

    self.projectFile_.tracks[#self.projectFile_.tracks + 1] = trackData;
    if trackData:getTrackType() ~= definations.TRACK_TYPE.CAMERA_PLAN and
        trackData:getTrackType() ~= definations.TRACK_TYPE.MOTION_PLAN and
        trackData:getTrackType() ~= definations.TRACK_TYPE.MUSIC_PLAN and
        trackData:getTrackType() ~= definations.TRACK_TYPE.SCENE_PLAN then

        if trackData:getTrackLength() > self.trackMaxLength_ then
            self.trackMaxLength_ = trackData:getTrackLength();
        end
    end
    return true;
end


function prototype:getTrackCount()
    return #self.projectFile_.tracks;
end


function prototype:getTrackAt(index)
    if index < 1 or index > #self.projectFile_.tracks then
        return false;
    end
    return self.projectFile_.tracks[index];
end


function prototype:getTimeLength()
    return self.trackMaxLength_;
end


return prototype;