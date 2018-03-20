local prototype = class("eSkyPlayerCameraEffectBlackEventData", require("eSkyPlayer/eSkyPlayerEventDataBase"));
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");

function prototype:ctor()
    prototype.super.ctor(self);
    self.motionType_ = definations.CAMERA_EFFECT_TYPE.BLACK;
    self.eventType_ = definations.EVENT_TYPE.BLACK;
    self.createParameters = {
        motionType = "number", --运动类型
        blendMode = "number", --混合模式
        textureID = "number", --贴图索引
        intensity = "table", --相机效果,由2个table构成(weights={}表示权重,ranges={}表示范围值)weights和ranges分别有2个值:
                                                --weights[1]表示起始点权值,weights[2]结束点权值 weights具体赋值只能是0或者1.比如wegihts{1,0}
                                                --ranges[1]范围最小值,ranges[2]范围最大值 
        timeLength = "number", --
    };
end


function prototype:initialize()
    prototype.super.initialize(self);
end


function prototype:_loadFromBuff(buff)
    local eventFile = {};
    eventFile.motionType = buff:ReadByte();
    eventFile.blendMode = buff:ReadByte();
    eventFile.textureID = buff:ReadByte();
    local info = {weights = {},ranges = {}};
    for i = 1, 2 do
        info.weights[#info.weights + 1] = buff:ReadFloat();
        info.ranges[#info.ranges + 1] = buff:ReadFloat();
    end
    eventFile.intensity = info;
    eventFile.timeLength = self.eventData_.timeLength_;
    if self:_setParam(eventFile) == false then
        return false;
    end
    return true;
end

 -- param是一个table
function prototype.createObject(param)
    if param == nil then
        return nil;
    end
    local obj = prototype:create();
    if obj:_setParam(param) == false then
        return nil
    end
    return obj;
end

function prototype:_setParam(param)
    if misc.checkParam(self.createParameters,param) == false then return false; end
    local textures_ = {
        "camera/textures/Overlay",
        "camera/textures/Overlay01",
    };

    local texturePath_ = textures_[param.textureID];
    local res = {};
    res.path = texturePath_;
    res.count = 1;
    self.resourcesNeeded_[#self.resourcesNeeded_ + 1] = res;

    local eventData_ = {};
    eventData_.motionType_ = param.motionType;
    eventData_.blendMode = param.blendMode;
    eventData_.timeLength_ = param.timeLength;

    misc.setValuesByWeight(param.intensity);
    eventData_.intensity = param.intensity;
    self.eventData_ = eventData_;
end

return prototype;