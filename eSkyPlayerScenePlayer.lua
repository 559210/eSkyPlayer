local prototype = class("eSkyPlayerScenePlayer",require "eSkyPlayer/eSkyPlayerBase");
local resourceManager = require("eSkyPlayer/eSkyPlayerResourceManager");

function prototype:ctor(director)
	self.base:ctor(director);
	self.resList_ = {};--需要加载的资源路径列表
	self.trackObj_ = nil;
	self.objList_ = {};--实例化出的物体列表.GameObject类型
	self.trackAndObj_ = {};
	self.playEvents_ = {};
	self.isPlay_ = false;
end


function prototype:initialize(trackObj)
	self.isPlay_ = false;
	self.trackObj_ = trackObj;
	return self.base:initialize(trackObj);
end

function prototype:uninitialize()
    self.trackObj_ = nil;
    for i = 1, #self.resList_ do
    	resourceManager:releaseResource(self.resList_[i]);
    	destroy(self.objList_[i]);
    end
    self.resList_ = {};
    self.objList_ = {};
    self.playEvents_ = {};
    return true;
end


function prototype:getResources()
	self.resList_ = self.trackObj_:getResources();
	local loadResList = {}
	for i = 1, #self.resList_ do
		local res = {}
		res.path = self.resList_[i];
		res.count = 1;
		loadResList[#loadResList + 1] = res;
	end
	return loadResList;
end


function prototype:onResourceLoaded()
	for i = 1, #self.resList_ do
		local target = resourceManager:getResource(self.resList_[i]);
		local obj = newObject(target);
		self.objList_[#self.objList_ + 1] = obj;
		local t = {}
		t.path = self.resList_[i];
		t.gameObject = obj;
		self.trackAndObj_[#self.trackAndObj_ + 1] = t;
	end

	local trackData = self.trackObj_:getTrackData();
	if nil ~= trackData then
		for i = 1, #trackData do
			if trackData[i].events_ ~= nil and #trackData[i].events_ > 0 then
				self:setPlayEvent(trackData[i]);
			end
		end
	end
 end

 function prototype:setPlayEvent(trackData)
	for i = 1, #trackData.events_ do
		local playEvent = newClass("eSkyPlayer/eSkyPlayerScenePlayEvent");
		local obj = self:getGameObjectByPath(trackData.mainSceneModelPath_);
		playEvent:initialize(trackData.events_[i],obj);
		self.playEvents_[#self.playEvents_ + 1] = playEvent;
	end
 end

function prototype:getGameObjectByPath(path)
	if nil ~= self.trackAndObj_ then
		for i = 1, #self.trackAndObj_ do
			if path == self.trackAndObj_[i].path then
				return self.trackAndObj_[i].gameObject;
			end
		end
	end
	return nil;
end

function prototype:setResouces(resPath)
	if self.resList_ == nil then self.resList_ = {};end
	if resPath ~= nil and resPath ~= "0" then
		self.resList_[#self.resList_ + 1] = resPath;
	end
end

function prototype:play()
	--if self:isEnd() then return; end --如果时间线的值大于eventtime中最小值则返回,说明播放已经开始
	for i = 1, #self.playEvents_ do
		self.playEvents_[i]:play();
	end
	self.isPlay_ = true;
    return true;
end

function prototype:stop()
	if not self.isPlay_ then return false; end
	for i = 1, #self.playEvents_ do
		self.playEvents_[i]:stop();
	end
	self.isPlay_ = false;
    return true;
end

function prototype:seek(time)
	for i = 1, #self.playEvents_ do
		self.playEvents_[i]:seek(time);
	end
	self.isPlay_ = true;
    return true;
end

function prototype:_update()
	if self.isPlay_ then
		for i = 1, #self.playEvents_ do
			self.playEvents_[i]:startPlay(self.director_.timeLine_);
		end
	end
end

--找出所有eventtime中最小的时间,与时间线比较,返回结果供play()使用.
function prototype:isEnd()
	local trackData = self.trackObj_:getTrackData();
	local timelength = {}
	for i = 1, #trackData do
		if trackData[i].events_ ~= nil and #trackData[i].events_ > 0 then
			local _events = trackData[i].events_;
			for j = 1, #_events do
				timelength[#timelength + 1] = _events[j].eventFile_.beginTime_;
			end
		end
	end
	local minTimelength = math.min(unpack(timelength));
	return self.director_.timeLine_ > minTimelength;
end

return prototype;