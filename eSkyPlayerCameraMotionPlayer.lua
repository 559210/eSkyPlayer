local prototype = class("eSkyPlayerCameraMotionPlayer",require "eSkyPlayer/eSkyPlayerBase");


function prototype:ctor(director)
    self.base:ctor(director);
    self.cameraTrack_ = nil;
    self.additionalCamera_ = nil;
    self.isNeedAdditionalCamera_ = false;
end


function prototype:initialize(trackObj)
    self.cameraTrack_ = trackObj;
    self.cameras_ = {};
    self.cameraJobsQueue_ = {};
    self.cameras_[1] = {};
    self.cameras_[1].camera = self.director_.camera_;
    self.cameras_[1].isUsed = false;
    self.cameras_[2] = {};
    self.cameras_[2].camera = self.additionalCamera_;
    self.cameras_[2].isUsed = false;
    self:_isNeedAdditionalCamera();
    return self.base:initialize(trackObj);
end

function prototype:play()
    if self.cameraTrack_ == nil  then
        return false; 
    end
    if self.director_.camera_ == nil then
        return false;
    end

    self.cameras_[2].camera = self.additionalCamera_;
    self.base:play();
    return true;
end

function prototype:isNeedAdditionalCamera()
    return self.isNeedAdditionalCamera_;
end

function prototype:setAdditionalCamera(camera)
    self.additionalCamera_ = camera;
end

function prototype:_update()
    if self.director_.timeLine_ > self.trackLength_ then
        self.base.isPlaying_ = false;
        return;
    end
    
    for i = 1, self.eventCount_  do
        local beginTime = self.cameraTrack_:getEventBeginTimeAt(i);
        local event = self.cameraTrack_:getEventAt(i);
        local endTime = beginTime + event.eventData_.timeLength;

        if self.director_.timeLine_ >= beginTime and self.director_.timeLine_ <= endTime then
            local isEnterEvent = true;
            if #self.cameraJobsQueue_ > 0 then 
                for j = 1, #self.cameraJobsQueue_ do
                    local queue = self.cameraJobsQueue_[j];
                    if queue.event == event then
                        isEnterEvent = false;
                    end
                end
            end

            if isEnterEvent == true then
                local cam = self:_giveCamera();
                if cam ~= nil then
                    local queue = {};
                    queue.camera = cam;
                    queue.event = event;
                    queue.beginTime = beginTime;
                    self.cameraJobsQueue_[#self.cameraJobsQueue_ + 1] = queue;
                end
            end
        end

        if self.director_.timeLine_ >= endTime or self.director_.timeLine_ <= beginTime then
            for j = 1, #self.cameraJobsQueue_ do
                local queue = self.cameraJobsQueue_[j];
                if queue.event == event then
                    table.remove(self.cameraJobsQueue_, j);
                    if self:_returnCamera(queue.camera) == false then    --true表示返回Camera后面没有其他Camera
                        for k = j,#self.cameraJobsQueue_ do
                            self:_returnCamera(self.cameraJobsQueue_[j].camera);
                        end
                        for k = j,#self.cameraJobsQueue_ do
                            local cam = self:_giveCamera();
                            if cam ~= nil then
                                self.cameraJobsQueue_[k].camera = cam;
                            end
                        end
                    end
                    break;
                end
            end
        end

        for index = 1, #self.cameraJobsQueue_ do
            self:_transformCamera(self.cameraJobsQueue_[index]);
        end
    end
end

function prototype:_transformCamera(queue)
    local camera = queue.camera;
    local event = queue.event;
    local deltaTime = (self.director_.timeLine_ - queue.beginTime) / event.eventData_.timeLength ;
    camera.transform.position = Vector3.Lerp (event.eventData_.beginFrame, event.eventData_.endFrame, deltaTime );
    camera.transform.rotation = Quaternion.Lerp (event.eventData_.beginDr, event.eventData_.endDr, deltaTime );
end

function prototype:_giveCamera()
    for i = 1,#self.cameras_ do
        if self.cameras_[i].isUsed == false then
            self.cameras_[i].isUsed = true;
            if i == 2 then
                self.director_:setAdditionalCameraEnabled(true);
            end
            return self.cameras_[i].camera;
        end
    end
    return nil;
end

function prototype:_returnCamera(cam)
    for i = 1,#self.cameras_ do
        if self.cameras_[i].camera == cam then
            self.cameras_[i].isUsed = false;
            if i == 2 then
                self.director_:setAdditionalCameraEnabled(false);
            end
            for j = i,#self.cameras_ do
                if self.cameras_[j].isUsed == true then
                    return false;
                end
            end
            return true;
        end
    end
    logError("未找到要归还的Camera！");
    return true;
end

function prototype:_isNeedAdditionalCamera()
    if self.cameraTrack_:isOverlapped() == true then
        self.isNeedAdditionalCamera_ = true;
    else 
        self.isNeedAdditionalCamera_ = false;
    end
end

return prototype;