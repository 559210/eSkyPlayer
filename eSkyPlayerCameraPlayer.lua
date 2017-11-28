local prototype = class("eSkyPlayerCameraPlayer");


function prototype:ctor()
	self.targetCamera_ = nil;
	self.cameraTrack_ = nil;
	self.timeLine_ = 0;
	self.eventCount_ = 0;
	self.isPlaying_ = false;
	self.timerId_ = 0;
	self.trackTimeLength_ = 0;

end

function prototype:initialize()
	self.timerId_ = TimersEx.Add(0, 0, delegate(self, self._update));
end

function prototype:_update()

	if self.isPlaying_ == false then
		return;
	end

	self.timeLine_ = self.timeLine_ + Time.deltaTime;

	if self.timeLine_ > self.trackTimeLength_ then
		self.isPlaying_ = false;
		return;
	end

	for i = 1 , self.eventCount_ do
		local event = self.cameraTrack_.trackFile_.events[i];
		if (self.timeLine_ >= event.beginTime and self.timeLine_ <= event.beginTime + event.data.timeLength) then
			local deltaTime = (self.timeLine_ - event.beginTime) / event.data.timeLength ;
			self.targetCamera_.transform.position = Vector3.Lerp (event.data.beginFrame, event.data.endFrame, deltaTime );
	        self.targetCamera_.transform.rotation = Quaternion.Lerp (event.data.beginDr, event.data.endDr, deltaTime );
	    end
	end
end

function prototype:play(trackObj, camera)

	if trackObj == nil or camera == nil then
		return false; 
	end

	self.targetCamera_ = camera;
	self.cameraTrack_ = trackObj;
	self.isPlaying_ = true;
	self.eventCount_ = #self.cameraTrack_.trackFile_.events;
	self.trackTimeLength_ = self.cameraTrack_.trackFile_.events[self.eventCount_].beginTime + self.cameraTrack_.trackFile_.events[self.eventCount_].data.timeLength;

	return true;
end

function prototype:stop()
	self.currentTime_ = Time.time;
	if self.isPlaying_ == false then
		return false;
	end
	self.timeLine_ = self.timeLine_ + Time.deltaTime; 

	self.isPlaying_ = false;
	return true;
end

function prototype:seek(time)
	if time < 0 or time > self.trackTimeLength_ then
		return false;
	end
	self.timeLine_ = time; 
	if (self.isPlaying_ == false) then
		self.isPlaying_ = true;
		self:_update();
		self.isPlaying_ = false;
	end
	return true;
end

return prototype;