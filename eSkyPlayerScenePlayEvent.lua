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
	self.playing = false;--正在播放
end

function prototype:initialize(event,obj)
	self.eventData_ = event;
	self.gameObject_ = obj;
	self.isPlay_ = false;
	self.beginTime_ = event.eventFile_.beginTime_;
	self.endTime_ = self.beginTime_ + event.eventObj_.eventData_.timeLength_;
	self.particleSys_ = self.gameObject_:GetComponentsInChildren(typeof(ParticleSystem))
end

function prototype:playParticleSys(isPlay)
	if self.particleSys_ ~= nil then
		for i = 0, self.particleSys_.Length -1 do
			local emission = self.particleSys_[i].emission;
			emission.enabled = isPlay;
			if isPlay then
				self.particleSys_[i]:Play();
			else
				self.particleSys_[i]:Stop();
				self.particleSys_[i]:Clear();	
			end
			
		end
	end
end


function prototype:play()
	-- 开始播放
	self.isPlay_ = true;
	return true;
end

function prototype:stop()
	--停止播放
	self:playParticleSys(false);
	self.isPlay_ = false;
	self.playing = false;
	return true;
end

function prototype:seek(time)
	if time < self.endTime_ then
		self.playing = false;
		self:play();
	end
    return true;
end



function prototype:startPlay(time)
	if self.isPlay_ then
		if time >= self.beginTime_ and time <= self.endTime_ then
			-- self.timer_ = TimersEx.Add(self.endTime_, 0, delegate(self, self.onPlayEnd));
			-- self.isPlay_ = false;
			if not self.playing then
				self:playParticleSys(true);
				self.playing = true;
			end
		elseif time >= self.endTime_ then 
			self:stop();
			self.playing = false;
		end
	end

end

function prototype:onPlayEnd()
	self:stop();
end

return prototype;