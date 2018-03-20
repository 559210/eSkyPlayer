local prototype = class("eSkyPlayerSceneTrackPlayer",require "eSkyPlayer/eSkyPlayerBase");
local resourceManager = require("eSkyPlayer/eSkyPlayerResourceManager");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");

function prototype:ctor(director)
    self.base:ctor(director);
	self.isEventPlay_ = false;--event播放标记
	self.resPath_ = nil;
	self.animators_ = nil; --动画
	self.particleSys_ = nil;--粒子  self.trackObj_
	self.eventCount_ = 0;
	self.speed_ = 0;
end

function prototype:initialize(trackObj)
	self.eventCount_ = trackObj:getEventCount();
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

function prototype:onEventLeft(eventObj)
	self:_stopEvent();
end

function prototype:_update()
	if self.director_.timeLine_ > self.director_.timeLength_ then
        self:changePlayState(definations.PLAY_STATE.PLAYEND);
        self:_stopEvent();
        return;
    end

    self:preparePlayingEvents(function(done)
        -- body
    end);

	if self:getPlayState() == definations.PLAY_STATE.PLAY then
		for j = 1, #self.playingEvents_ do
			local queue = self.playingEvents_[j];
			-- if self.director_.timeLine_ >= queue.beginTime and self.director_.timeLine_ <= queue.endTime then
				if self.animators_ ~= nil then
					local eventTime = queue.endTime_ - queue.beginTime_;
					local progress = (self.director_.timeLine_ - queue.beginTime_) / eventTime; --当前播放在event中的比例
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
	self.base:seek(time);
	self:changePlayState(definations.PLAY_STATE.PLAY);
    return true;
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