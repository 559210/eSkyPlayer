local prototype = class("eSkyPlayerSceneVirtualTrackData", require("eSkyPlayer/eSkyPlayerSceneTrackDataBase"));
local definations = require("eSkyPlayer/eSkyPlayerDefinations");

function prototype:ctor()
    prototype.super.ctor(self);
    self.trackType_ = definations.TRACK_TYPE.SCENE_MOTION; --7
    self.trackFileType_ = definations.TRACK_FILE_TYPE.SCENE;--6
    self.eventsSupportted_ = {definations.EVENT_TYPE.SCENE_MOTION};--7
    self.stagePath_ = nil;
end


function prototype:_loadFromBuff(buff)
    return false;
end

function prototype.createObject(param)      -- param是一个table,里面存放具体创建某个track需要的参数
	if param.stagePath == nil or type(param.stagePath) ~= "string" then
		return nil;
	end

    local obj = prototype:create()
    obj.stagePath = param.stagePath;
    return obj;
end


function prototype:getResources()
	return self.stagePath_;
end

return prototype;