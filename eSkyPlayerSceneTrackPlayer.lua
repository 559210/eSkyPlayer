local prototype = class("eSkyPlayerSceneTrackPlayer",require "eSkyPlayer/eSkyPlayerBase");
local resourceManager = require("eSkyPlayer/eSkyPlayerResourceManager");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");

function prototype:ctor(director)
    self.base:ctor(director);
	self.resPath_ = nil;
	self.animators_ = nil; --动画
	self.particleSys_ = nil;--粒子  self.trackObj_
	self.isSeeking_ = false;
	self.currentEvent_ = {};
end

function prototype:initialize(trackObj)
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
	end
end


function prototype:play()
    if self.trackObj_ == nil then
        return false; 
    end
    self.base:play();
    self.isSeeking_ = false;
    if self.currentEvent_.beginTime_ ~= nil then
    	self:_playEventAnim(self.currentEvent_.beginTime_, self.currentEvent_.endTime_);
    	self:_playEventParticle(self.currentEvent_.endTime_);
    end
    
    return true;
end

function prototype:onEventLeft(eventObj)
	self:_stopEvent();
end


function prototype:onEventEntered(eventObj)
	local beginTime = eventObj:getDataBeginTime();
	local endTime = beginTime + eventObj:getDataLength();
	self.currentEvent_.beginTime_ = beginTime;
	self.currentEvent_.endTime_ = endTime;
	if self.particleSys_ ~= nil then
		self:_playEventParticle(endTime);
	end
	if self.animators_ ~= nil then
		self:_playEventAnim(beginTime, endTime);
	end	
	
end


function prototype:stop()
	self.base:stop();
	self:_stopEvent();
end

function prototype:seek(time)
	self.base:seek(time);
	self.isSeeking_ = true;
	self:changePlayState(definations.PLAY_STATE.PLAY);
	if self.currentEvent_.beginTime_ ~= nil then
		self:_playEventAnim(self.currentEvent_.beginTime_, self.currentEvent_.endTime_);		
	end

    return true;
end

function prototype:_playEventParticle(endTime)
	if self.particleSys_ ~= nil and self.director_.timeLine_ < endTime then
		for i = 0, self.particleSys_.Length - 1 do
			local emission = self.particleSys_[i].emission;
			emission.enabled = true;
			self.particleSys_[i]:Play();
		end
	end
	
end

function prototype:_playEventAnim(beginTime, endTime)
	if self.animators_ ~= nil then
		for i = 0, self.animators_.Length - 1 do
			local anim = self.animators_[i];
			anim.enabled = true;
			local eventTime = endTime - beginTime;
			local num = anim:GetCurrentAnimatorClipInfoCount(0);
			local animLength = anim:GetCurrentAnimatorClipInfo(0)[0].clip.length;
			local progress = (self.director_.timeLine_ - beginTime) / eventTime;--当前播放在event中的比例
			if self.isSeeking_ and num > 0 then
				anim.speed = 0;
				anim:Play(anim.runtimeAnimatorController.name, 0, progress);
			else
				anim.speed = animLength / eventTime;
				if num > 0 then
					anim:Play(anim.runtimeAnimatorController.name, 0, progress);
				end
			end
		end
	end
end


function prototype:_stopEvent()
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
	self.isSeeking_ = false;
end

return prototype;