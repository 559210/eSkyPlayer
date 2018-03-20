local prototype = class("eSkyPlayerSceneTrackData", require("eSkyPlayer/eSkyPlayerSceneTrackDataBase"));
local definations = require("eSkyPlayer/eSkyPlayerDefinations");
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");

function prototype:ctor()
    prototype.super.ctor(self);
    self.trackType_ = definations.TRACK_TYPE.SCENE_MOTION; --7
    self.trackFileType_ = definations.TRACK_FILE_TYPE.SCENE;--6   
    self.eventsSupportted_ = {definations.EVENT_TYPE.SCENE_MOTION};--7
    self.stagePath = "";
    self.createParameters = {
        stagePath = "string",--资源路径
    };
end


function prototype.createObject(param)
    local obj = prototype:create();
    if obj:_setParam(param) == false then
        return nil;
    end
    return obj;
end

function prototype:_setParam(param)
    if misc.checkParam(self.createParameters,param) == false then
        return false;
    end
    self.stagePath = param.stagePath;
    return true;
end

function prototype:getResources()
    local resList = {};
    if #self.events_ == 0 then
        return nil;
    end
    
    for i = 1,#self.events_ do
    	local resPath = nil;
    	local event = self.events_[i];
    	if event.eventFile_.mainSceneModelPath_ ~= nil then
    		resPath = event.eventFile_.mainSceneModelPath_;
    	else
    		resPath = event.eventObj_.eventData_.mainSceneModelPath_;
    	end
    	local rList = {};
    	rList.path = resPath;
    	rList.count = 1;
    	resList[#resList + 1] = rList;
    end
    return resList;
end

return prototype;