local prototype = class("eSkyPlayerSceneMotionEventData", require("eSkyPlayer/eSkyPlayerEventDataBase"));
local definations = require("eSkyPlayer/eSkyPlayerDefinations");
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");

function prototype:ctor()
    self.base:ctor();
    self.eventType_ = definations.EVENT_TYPE.SCENE_MOTION;
    self.createParameters = {
        beginCut = "number", --裁剪起点
        endCut = "number", --裁剪终点
        timeLength = "number", --自身时长
    };
end



function prototype:_loadFromBuff(buff)
    local eventFile = {};
    eventFile.beginCut = buff:ReadFloat();
    eventFile.endCut = buff:ReadFloat();
    buff:ReadString(); --animation 的名字
    eventFile.timeLength = self.eventData_.timeLength_;
    if self:_setParam(eventFile) == false then
        return false;
    end
    return true;
end

-- param是一个table
function prototype.createObject(param)
    local obj = prototype:create();
    if obj:_setParam(param) == false then
        return nil
    end
    return obj;
end

function prototype:_setParam(param)
    if misc.checkParam(self.createParameters,param) == false then return false; end;
    local eventData_ = {};
    eventData_.beginCut = param.beginCut;
    eventData_.endCut = param.endCut;
    eventData_.timeLength_ = param.timeLength;
    if param.mainSceneModelPath_ ~= nil then
        eventData_.mainSceneModelPath_ = param.mainSceneModelPath_;
    end
    self.eventData_ = eventData_;
    return true;
end


return prototype;