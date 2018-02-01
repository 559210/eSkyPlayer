local prototype = class("eSkyMainSceneVirtualTrack", require("eSkyPlayer/eSkyPlayerTrackDataBase"));


function prototype:ctor()
    self.base:ctor();
    -- self.stageName = nil;
    self.stagePath = nil;
end

function prototype:initialize()
	
end

function prototype:_loadFromBuff(buff)
    return false;
end

function prototype.createObject(param)      -- param是一个table,里面存放具体创建某个track需要的参数
	if param.stagePath == nil or type(param.stagePath) ~= "string" then
		return nil;
	end

    local obj = prototype:create()--newClass("eSkyPlayer/eSkyMainSceneVirtualTrack");
    obj.stagePath = param.stagePath;
    return obj;
end


function prototype:getResources()
	return self.stagePath;
end

return prototype;