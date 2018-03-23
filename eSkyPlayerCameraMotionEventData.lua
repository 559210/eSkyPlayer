local prototype = class("eSkyPlayerCameraMotionEventData", require("eSkyPlayer/eSkyPlayerEventDataBase"));
local definations = require("eSkyPlayer/eSkyPlayerDefinations");
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");

function prototype:ctor()
    prototype.super.ctor(self);
    self.eventType_ = definations.EVENT_TYPE.CAMERA_MOTION;
    self.createParameters = {
        ----------beginFrame--------起点坐标
        beginFrameX = "number",
        beginFrameY = "number",
        beginFrameZ = "number",
        ----------beginDr--------起点角度
        beginDrX = "number",
        beginDrY = "number",
        beginDrZ = "number",
        ---------beginLookAt-------起点朝向
        beginLookAtX = "number",
        beginLookAtY = "number",
        beginLookAtZ = "number",
        --------endFrame--------终点坐标
        endFrameX = "number",
        endFrameY = "number",
        endFrameZ = "number",
        --------endDr---------
        endDrX = "number",
        endDrY = "number",
        endDrZ = "number",
        ---------endLookAt------终点朝向
        endLookAtX = "number",
        endLookAtY = "number",
        endLookAtZ = "number",
        fov = "number", --相机视角
        tweenType = "number", --相机移动动画类型
        ------pos1--------
        pos1X = "number",
        pos1Y = "number",
        ------pos2--------
        pos2X = "number",
        pos2Y = "number",
        timeLength = "number", --自身时长
    };
end


function prototype:_loadFromBuff(buff)
    local eventFile = {
        beginFrameX = buff:ReadFloat(), beginFrameY = buff:ReadFloat(), beginFrameZ = buff:ReadFloat(),--beginFrame
        beginDrX = buff:ReadFloat(), beginDrY = buff:ReadFloat(), beginDrZ = buff:ReadFloat(),--beginDr
        beginLookAtX = buff:ReadFloat(), beginLookAtY = buff:ReadFloat(), beginLookAtZ = buff:ReadFloat(),--beginLookAt
        endFrameX = buff:ReadFloat(), endFrameY = buff:ReadFloat(), endFrameZ = buff:ReadFloat(),--endFrame
        endDrX = buff:ReadFloat(), endDrY = buff:ReadFloat(), endDrZ = buff:ReadFloat(),--endDr
        endLookAtX = buff:ReadFloat(), endLookAtY = buff:ReadFloat(), endLookAtZ = buff:ReadFloat(),--endLookAt
        fov = buff:ReadFloat(),
        tweenType = buff:ReadByte(),
        pos1X = 0,
        pos1Y = 0,
        pos2X = 0,
        pos2Y = 0,
        timeLength = self.eventData_.timeLength_,
    };
    if eventFile.tweenType == 0 then
        eventFile.pos1X = buff:ReadFloat();
        eventFile.pos1Y = buff:ReadFloat();
        eventFile.pos2X = buff:ReadFloat();
        eventFile.pos2X = buff:ReadFloat();
    end
    return self:_setParam(eventFile);

end

-- param是一个table
function prototype.createObject(param)
    if param == nil then return nil; end
    local obj = prototype:create()
    if obj:_setParam(param) == false then
        return nil;
    end 
    return obj;
end


function prototype:_setParam(param)
    if misc.checkParam(self.createParameters, param) == false then return false; end
    self.eventData_ = {
        beginFrame_ = Vector3.New(param.beginFrameX, param.beginFrameY, param.beginFrameZ),
        beginDr_ = Quaternion.Euler(param.beginDrX, param.beginDrY, param.beginDrZ),
        beginLookAt_ = Vector3.New(param.beginLookAtX, param.beginLookAtY, param.beginLookAtZ),
        endFrame_ = Vector3.New(param.endFrameX, param.endFrameY, param.endFrameZ),
        endDr_ = Quaternion.Euler(param.endDrX, param.endDrY, param.endDrZ),
        endLookAt_ = Vector3.New(param.endLookAtX, param.endLookAtY, param.endLookAtZ),
        tweenType_ = param.tweenType,
        fov_ = param.fov,
        pos1_ = {x = param.pos1X, y = param.pos1Y},
        pos2_ = {x = param.pos2X, y = param.pos2Y},
        timeLength_ = param.timeLength,
    };
    return true;
end

return prototype;
