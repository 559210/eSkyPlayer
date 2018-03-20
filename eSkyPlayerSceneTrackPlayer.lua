local prototype = class("eSkyPlayerSceneTrackPlayer",require "eSkyPlayer/eSkyPlayerBase");
local resourceManager = require("eSkyPlayer/eSkyPlayerResourceManager");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");

function prototype:ctor(director)
    self.base:ctor(director);
    -- self.sceneTrack_ = nil;
    self.sceneEventQueue_ = {};--event播放队列
	self.isEventPlay_ = false;--event播放标记
	self.resPath_ = nil;
	self.animators_ = nil; --动画
	self.particleSys_ = nil;--粒子  self.trackObj_
	self.eventCount_ = 0;
	self.speed_ = 0;
end

function prototype:initialize(trackObj)
	self.eventCount_ = trackObj:getEventCount();
    -- self.sceneTrack_ = trackObj;
    self.sceneEventQueue_ = {};
    
    return self.base:initialize(trackObj);
end

function prototype:getResources()
	local loadResList = {};
	local res = {};
	res.path = self.trackObj_.stagePath;
	res.count = 1;
	loadResList[#loadResList + 1] = res;
	return loadResList;
end

function prototype:onResourceLoaded()
	if self.trackObj_.stagePath ~= nil then
		local target = resourceManager:getResource(self.trackObj_.stagePath);
		local obj = newObject(target);
		self.obj = obj;
		self.animators_ = obj:GetComponentsInChildren(typeof(Animator));
		self.particleSys_ = obj:GetComponentsInChildren(typeof(ParticleSystem));
		self:_setAnimSpeed();
	end
end

function prototype:_setAnimSpeed()
	if self.animators_ ~= nil and self.animators_.Length > 0
		and self.particleSys_ ~= nil and self.particleSys_.Length > 0 then
		self.speed_ = 1;
	end
end

function prototype:play()
    if self.trackObj_ == nil then
        return false; 
    end
    self.base:play();
    return true;
end

function prototype:_update()
	if self.director_.timeLine_ > self.director_.timeLength_ then
        self:changePlayState(definations.PLAY_STATE.PLAYEND);
        self:_stopEvent();
        return;
    end

    --修改event播放规则
	if self:getPlayState() == definations.PLAY_STATE.PLAY then
		local eventData = self.trackObj_;
		for j = 1, self.eventCount_ do
			local event = eventData.events_[j];
			local beginTime = event.eventFile_.beginTime_;
			local eventObj = event.eventObj_;
	        local endTime = beginTime + eventObj.eventData_.timeLength_;
	        if self.director_.timeLine_ >= beginTime and self.director_.timeLine_ <= endTime then
	        	self:_refreshQueue(beginTime,endTime,eventObj);
	        end
	        if self.director_.timeLine_ >= endTime or self.director_.timeLine_ <= beginTime then
	            for k = 1, #self.sceneEventQueue_ do
	                local queue = self.sceneEventQueue_[k];
	                if queue.eventObj == eventObj then
	                	self.isEventPlay_ = false;
	                	self:_stopEvent();
	                    table.remove(self.sceneEventQueue_, k);
	                    break;
	                end
	            end
	        end
		end
		for j = 1, #self.sceneEventQueue_ do
			local queue = self.sceneEventQueue_[j];
			-- if self.director_.timeLine_ >= queue.beginTime and self.director_.timeLine_ <= queue.endTime then
				if self.animators_ ~= nil then
					local eventTime = queue.endTime - queue.beginTime;
					local progress = (self.director_.timeLine_ - queue.beginTime) / eventTime; --当前播放在event中的比例
					self:_playEventAnim(progress);	
				end
				if self.particleSys_ ~= nil then
					if not self.isEventPlay_ then
						self:_playEventParticle();
						self.isEventPlay_ = true;
					end	
				end
			-- end
		end
	end
end

function prototype:stop()
	self.base:stop();
	self:_stopEvent();
end

function prototype:seek(time)
	self:changePlayState(definations.PLAY_STATE.PLAY);
    return true;
end

function prototype:_refreshQueue(beginTime,endTime,eventObj)
	local startEvent = true;
	if #self.sceneEventQueue_ > 0 then
		for i = 1, #self.sceneEventQueue_ do
			local queue = self.sceneEventQueue_[i];
			if queue.eventObj == eventObj then
                startEvent = false;
            end
		end
	end
	if startEvent then
		local queue = {};
		queue.beginTime = beginTime;
		queue.endTime = endTime;
		queue.eventObj = eventObj;
		self.sceneEventQueue_[#self.sceneEventQueue_ + 1] = queue;
	end
end

function prototype:_playEventParticle()
	if self.particleSys_ ~= nil then
		for i = 0, self.particleSys_.Length - 1 do
			local emission = self.particleSys_[i].emission;
			emission.enabled = true;
			self.particleSys_[i]:Play();
		end
	end
	
end

function prototype:_playEventAnim(progress)
	if self.animators_ ~= nil then
		for i = 0, self.animators_.Length - 1 do
			local anim = self.animators_[i];
			anim.enabled = true;
			anim.speed = self.speed_;
			local num = anim:GetCurrentAnimatorClipInfoCount(0);
			if num > 0 then
				anim:Play(anim.runtimeAnimatorController.name,0,progress);
			end
		end
	end
end

function prototype:_stopEvent()
	if self.isEventPlay_ then self.isEventPlay_ = false; end
	if self.particleSys_ ~= nil then
		for i = 0, self.particleSys_.Length - 1 do
			self.particleSys_[i]:Stop();
			self.particleSys_[i]:Clear();
		end
	end
	if self.animators_ ~= nil then
		for i = 0, self.animators_.Length - 1 do
			local anim = self.animators_[i];
			anim.enabled = false;
			anim.speed = 0;
		end
	end
end

return prototype;