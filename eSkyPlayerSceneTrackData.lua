local prototype = class("eSkyPlayerSceneTrackData", require("eSkyPlayer/eSkyPlayerTrackDataBase"));
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


function prototype:_loadFromBuff(buff, name, nameTable)
    if buff == nil then return false; end
    local title = buff:ReadString(); --name 
    self.name_ = self:getTrackName(name, self.trackType_, title, nameTable);
    self:_setParam({stagePath = buff:ReadString()});
    local eventCount = buff:ReadShort();
    if eventCount == 0 then
        return true;
    end
    for i = 1, eventCount do
        local beginTime = 0;
        local eventObj = nil;
        if self.eventsSupportted_ == nil then
            return false;
        end
        beginTime = buff:ReadFloat();
        local name = buff:ReadString();--event对应的文件名
        buff:ReadByte();--storeType_ 
        buff:ReadByte();--isLoopPlay_ = misc.getBoolByByte(buff:ReadByte());
        buff:ReadByte();--labelID_ 
        eventObj = newClass("eSkyPlayer/eSkyPlayerSceneMotionEventData");
        eventObj:initialize();
        if self:isSupported(eventObj) == false then
            return false;
        end
        local scene_path = string.format("mod/plans/scene/" ..self.title_ .."/scene/" ..name ..".byte");
        if eventObj:loadEvent(scene_path) == false then
            return false;
        end
        self:_insertEvent(beginTime, eventObj);
    end

    return true;
end


function prototype.createObject(param)
    local obj = prototype:create();
    if obj:_setParam(param) == false then
        return nil;
    end
    return obj;
end

function prototype:_setParam(param)
    if misc.checkParam(self.createParameters, param) == false then
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