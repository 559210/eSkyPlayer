local prototype = class("eSkyPlayerProjectData");
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");

function prototype:ctor()
    self.projectFile_ = nil;
    self.trackMaxLength_ = 0;
end


function prototype:initialize()
    self.projectFile_ = {tracks_ = {}};
    return true;
end


function prototype:loadProject(filename)
    local isScene = string.match(filename,"mod/plans/scene/.+");
    if isScene then
        self:_loadSceneConfig(filename);
    end
    local tracks, isLoopPlay = self:_loadConfig(filename);
    for i = 1,#tracks do
        local trackPath = filename .. "/" .. tracks[i].name .. ".byte";
        if self:_loadTracks(trackPath) == false then
            return false;
        end
    end
    return true;
end

function prototype:_loadSceneConfig(filename)
    local path = Util.AppDataRoot .. "/" ..filename .. "/@sceneconfig.byte";
    local buff = misc.readAllBytes(path);
    if nil == buff then return false; end;
    local stageName = buff:ReadString();
    local stagePath = buff:ReadString();

    local sceneTrack = require("eSkyPlayer/eSkyPlayerSceneVirtualTrackData");
    local virtualTrack = sceneTrack.createObject({stagePath = stagePath});
    -- TODO: 考虑是否要将track放入容器的功能抽成函数
    if nil ~= virtualTrack then
        self.projectFile_.tracks_[#self.projectFile_.tracks_ + 1] = virtualTrack;    
    end

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
    if string.match(trackPath,"mod/plans/camera/.+/cameraTrack") or
        string.match(trackPath,"mod/projects/.+/plans/camera/.+/cameraTrack") then
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
    elseif string.match(trackPath,"mod/plans/camera/.+/cameraMotionTrack") or
        string.match(trackPath,"mod/projects/.-/plans/camera/.+/cameraMotionTrack") then
        trackData = newClass("eSkyPlayer/eSkyPlayerCameraEffectTrackData");
        trackData:initialize();
        if trackData:loadTrack(trackPath) == false then
            return false;
        end
    elseif string.match(trackPath,"mod/plans/scene/.-/sceneTrack") then
        trackData = newClass("eSkyPlayer/eSkyPlayerSceneTrackData");
        trackData:initialize();
        if trackData:loadTrack(trackPath) == false then
            return false;
        end
    elseif string.match(trackPath,"mod/projects/.+/sceneTrack") then
        trackData = newClass("eSkyPlayer/eSkyPlayerScenePlanTrackData");
        trackData:initialize();
        if trackData:loadTrack(trackPath) == false then
            return false;
        end
    elseif string.match(trackPath,"mod/projects/.+/motionTrack") then
        trackData = newClass("eSkyPlayer/eSkyPlayerRolePlanTrackData");
        trackData:initialize();
        if trackData:loadTrack(trackPath) == false then
            return false;
        end
    elseif string.match(trackPath, "mod/plans/motion/.+/motionTrack") then
        trackData = newClass("eSkyPlayer/eSkyPlayerRoleMotionTrackData");
        trackData:initialize();
        if trackData:loadTrack(trackPath) == false then
            return false;
        end
    else
        return true;
    end

    self.projectFile_.tracks_[#self.projectFile_.tracks_ + 1] = trackData;
    if trackData:getTrackType() ~= definations.TRACK_TYPE.CAMERA_PLAN and
        trackData:getTrackType() ~= definations.TRACK_TYPE.ROLE_PLAN and
        trackData:getTrackType() ~= definations.TRACK_TYPE.MUSIC_PLAN and
        trackData:getTrackType() ~= definations.TRACK_TYPE.SCENE_PLAN
        then

        if trackData:getTrackLength() > self.trackMaxLength_ then
            self.trackMaxLength_ = trackData:getTrackLength();
        end
    end
    return true;
end


function prototype:getTrackCount()
    return #self.projectFile_.tracks_;
end


function prototype:getTrackAt(index)
    if index < 1 or index > #self.projectFile_.tracks_ then
        return false;
    end
    return self.projectFile_.tracks_[index];
end


function prototype:getTimeLength()
    return self.trackMaxLength_;
end


return prototype;