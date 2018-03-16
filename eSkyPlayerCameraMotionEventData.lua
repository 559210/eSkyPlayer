local prototype = class("eSkyPlayerCameraMotionEventData", require("eSkyPlayer/eSkyPlayerEventDataBase"));
local definations = require("eSkyPlayer/eSkyPlayerDefinations");
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");

function prototype:ctor()
    self.base:ctor();
    self.eventType_ = definations.EVENT_TYPE.CAMERA_MOTION;
    self.createParameters = {
        beginFrame = "table", --起点坐标
        beginDr = "table", --起点角度
        beginLookAt = "table", --起点朝向
        endFrame = "table", --重点坐标
        endDr = "table", --重点角度
        endLookAt = "table", --终点朝向
        fov = "number", --相机视角
        tweenType = "number", --相机移动动画类型
        timeLength = "number", --自身时长
    };
end



function prototype:_loadFromBuff(buff)
    local eventFile = {};
    eventFile.beginFrame = {x = buff:ReadFloat(), y = buff:ReadFloat(), z = buff:ReadFloat()};
    eventFile.beginDr = {x = buff:ReadFloat(), y = buff:ReadFloat(), z = buff:ReadFloat()};
    eventFile.beginLookAt = {x = buff:ReadFloat(),y = buff:ReadFloat(), z = buff:ReadFloat()};
    eventFile.endFrame = {x = buff:ReadFloat(), y = buff:ReadFloat(), z = buff:ReadFloat()};
    eventFile.endDr = {x = buff:ReadFloat(), y = buff:ReadFloat(), z = buff:ReadFloat()};
    eventFile.endLookAt = {x = buff:ReadFloat(), y = buff:ReadFloat(), z = buff:ReadFloat()};
    eventFile.fov = buff:ReadFloat();
    eventFile.tweenType = buff:ReadByte();
    if eventFile.tweenType == 0 then
        eventFile.pos1 = {x = buff:ReadFloat(), y = buff:ReadFloat()};
        eventFile.pos2 = {x = buff:ReadFloat(), y = buff:ReadFloat()};
    end
    eventFile.timeLength = self.eventData_.timeLength_;
    if self:_setParam(eventFile) == false then
        return false;
    end
    return true;

end

-- param是一个table
function prototype.createObject(param)      
    local obj = prototype:create()
    if obj:_setParam(param) == false then
        return nil;
    end 
    return obj;
end


function prototype:_setParam(param)
    if misc.checkParam(self.createParameters,param) == false then return false; end;
    local eventData_ = {};
    eventData_.beginFrame_ = Vector3.New(param.beginFrame.x, param.beginFrame.y, param.beginFrame.z);
    eventData_.beginDr_ = Quaternion.Euler(param.beginDr.x, param.beginDr.y, param.beginDr.z);
    eventData_.beginLookAt_ = Vector3.New(param.beginLookAt.x, param.beginLookAt.y, param.beginLookAt.z);
    eventData_.endFrame_ = Vector3.New(param.endFrame.x, param.endFrame.y, param.endFrame.z);
    eventData_.endDr_ = Quaternion.Euler(param.endDr.x, param.endDr.y, param.endDr.z);
    eventData_.endLookAt_ = Vector3.New(param.endLookAt.x, param.endLookAt.y, param.endLookAt.z);
    eventData_.fov_ = param.fov;
    eventData_.tweenType_ = param.tweenType;
    eventData_.timeLength_ = param.timeLength;
    if param.tweenType == 0 then
        eventData_.pos1_ = {};
        eventData_.pos2_ = {};
        eventData_.pos1_ = param.pos1;
        eventData_.pos2_ = param.pos2;
    end
    self.eventData_ = eventData_;
    return true;
end

return prototype;
