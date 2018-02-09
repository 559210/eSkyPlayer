local prototype = class("eSkyPlayerScenePlayEvent",require "eSkyPlayer/eSkyPlayerBase");

function prototype:ctor()
	self.eventData_ = nil;
	self.gameObject_ = nil;
	self.particleManager_ = nil;
	self.particleSys_ = nil
	self.timer_ = nil;
	self.isPlay_ = false;
	self.beginTime_ = 0;
	self.endTime_ = 0; --结束时间
end

function prototype:initialize(event,obj)
	self.eventData_ = event;
	self.gameObject_ = obj;
	self.isPlay_ = false;
	self.beginTime_ = event.eventFile_.beginTime_;
	self.endTime_ = self.beginTime_ + event.eventObj_.eventData_.timeLength_;
	self:setPlayData();
end

function prototype:setPlayData()
	self.particleSys_ = self.gameObject_:GetComponentInChildren(typeof(ParticleSystem))
	if self.particleSys_ ~= nil then
		self.particleManager_ = ParticleManager.New();
		self.particleManager_.prefab = self.gameObject_;
		self.particleManager_:Stop(true);
	end
end


function prototype:play()
	-- 开始播放
	self.isPlay_ = true;
	return true;
end

function prototype:stop()
	--停止播放
	self.particleManager_:Stop(true);
	self.isPlay_ = false;
	if self.timer_ ~= nil then 
		TimersEx.Remove(self.timer_)
	end
	return true;
end

function prototype:seek(time)
	if time < self.endTime_ then
		-- self.endTime_ = self.endTime_ - time;
		self:play();
	end
    return true;
end

function prototype:startPlay(time)
	if self.isPlay_ then
		if time >= self.beginTime_ and time <= self.endTime_ then
			self.timer_ = TimersEx.Add(self.endTime_, 0, delegate(self, self.onPlayEnd));
			self.isPlay_ = false;
			self.particleManager_:Play();
		end
	end
end

function prototype:onPlayEnd()
	-- self.endTime_ = self.beginTime_ + self.eventData_.eventObj_.eventData_.timeLength_;
	self:stop();
end

return prototype;