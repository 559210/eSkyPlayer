local prototype = class("eSkyPlayerScenePlayer",require "eSkyPlayer/eSkyPlayerBase");

function prototype:ctor()
	self.resList_ = {};
	self.trackObj = nil;
	self.objList_ = {};
end


function prototype:initialize(trackObj)
	self.trackObj = trackObj;
	return self.base:initialize(trackObj);
end

function prototype:uninitialize(resManager)
    self.trackObj = nil;
    for i = 1, #self.resList_ do
    	resManager:releaseResource(self.resList_[i]);
    	destroy(self.objList_[i]);
    end
    self.resList_ = {};
    self.objList_ = {};
    return true;
end


function prototype:setMainSceneVirtualTrack(trackObj)
	if self.resList_ == nil then self.resList_ = {};end
	local path = trackObj:getResources();
	self.resList_[#self.resList_ + 1] = path;
end

function prototype:getResources()
	self.resList_ = self.trackObj:getResources();
	return self.resList_;
end

function prototype:onResourceLoaded(resManager)
	for i = 1, #self.resList_ do
		local target = resManager:getResource(self.resList_[i]);
		local obj = newObject(target);
		self.objList_[#self.objList_ + 1] = obj;
	end

 end


function prototype:setResouces(resPath)
	if self.resList_ == nil then self.resList_ = {};end
	if resPath ~= nil and resPath ~= "0" then
		self.resList_[#self.resList_ + 1] = resPath;
	end
end

function prototype:play()
<<<<<<< HEAD
	logError("self.trackObj =" ..inspect(self.trackObj));
=======
>>>>>>> 1d71da900a5290accefce6c0b171ed5628b81f9d
    return true;
end

function prototype:stop()
    return true;
end

function prototype:seek(time)
    return true;
end

function prototype:_update()
	-- logError("sceneplayer._update");
end

return prototype;