local prototype = class("eSkyPlayerCameraPlayer");


function prototype:ctor()
	self.startTime_ = 0;
	self.currentTime_ = 0;
	self.targetCamera_ = nil;
	self.cameraTrack_ = nil;
	self.timeLine_ = 0;
	self.eventCount_ = 0;
	self.isPlaying_ = false;
	self.timerId_ = 0;
end

function prototype:initialize()
	self.timerId_ = TimersEx.Add(0, 0, delegate(self, self._update_));
end

function prototype:_update()

	if self.isPlaying_ == false then
		return;
	end

	self.currentTime_ = Time.time;
	self.timeLine_ += (self.currentTime_ - self.startTime_);
	

	if self.timeLine_ > self.cameraTrack_.trackFile_.events[self.eventCount_].beginTime + self.cameraTrack_.trackFile_.events[self.eventCount_].timeLength then
		self.isPlaying_ = false;
		return;
	end

	for i = 1 , self.eventCount_ do
		local event = self.cameraTrack_.trackFile_.events[i];
		if (event.beginTime <= self.timeLine_ <= event.beginTime + event.timeLength) then
			local deltaTime = (self.timeLine_ - event.beginTime) / event.timeLength;
			self.targetCamera_.transform.position = Vector3.Lerp (event.beginFrame, event.endFrame, deltaTime);
	        self.targetCamera_.transform.rotation = Quaternion.Lerp (event.beginRotation, event.endRotation, deltaTime);
	    end
	end
end

function prototype:play(trackObj, camera, time)
	time = time or 0;
	if trackObj == nil || camera == nil then
		return false;
	end

	self.timeLine_ = time;
	self.startTime_ = Time.time;
	self.targetCamera_ = camera;
	self.cameraTrack_ = trackObj;
	self.isPlaying_ = true;
	self.eventCount_ = #self.cameraTrack_.trackFile_.events;

	return true;
end


return prototype;

