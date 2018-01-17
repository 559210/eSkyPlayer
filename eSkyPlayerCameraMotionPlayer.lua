local prototype = class("eSkyPlayerCameraMotionPlayer",require "eSkyPlayer/eSkyPlayerBase");


function prototype:ctor(director)
    self.base:ctor(director);
    self.cameraTrack_ = nil;
    self.isNeedAdditionalCamera_ = false;
end


function prototype:initialize(trackObj)
    self.cameraTrack_ = trackObj;
    --self.cameras_目前有两个Camera，第一个默认为主Camera，第二个为需要时另外创建的Camera。
    self.cameras_ = {{camera = self.director_.camera_;
    isUsed = false},};
    self.cameraJobsQueue_ = {};
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


    self.base:play();
    return true;
end

function prototype:isNeedAdditionalCamera()
    return self.isNeedAdditionalCamera_;
end

function prototype:setAdditionalCamera(camera)
    local cam = {};
    cam.camera = camera;
    cam.isUsed = false;
    self.cameras_[#self.cameras_ + 1] = cam;
end

function prototype:_update()
    if self.director_.timeLine_ > self.director_.timeLength_ then
        self.base.isPlaying_ = false;
        return;
    end

    for i = 1, self.eventCount_  do
        local beginTime = self.cameraTrack_:getEventBeginTimeAt(i);
        local event = self.cameraTrack_:getEventAt(i);
        local endTime = beginTime + event.eventData_.timeLength;

        if self.cameraTrack_:isSupported(event) == false then
            return;
        end
        
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
                local cam = self:_requestCamera();
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
                            local cam = self:_requestCamera();
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

function prototype:_requestCamera()
    for i = 1,#self.cameras_ do
        if self.cameras_[i].isUsed == false then
            self.cameras_[i].isUsed = true;
            if i > 1 then    --i>1时表示主camera已经在播放event，申请的camera需要enable
                self.cameras_[i].camera.enabled = true;
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
            if i > 1 then
                self.cameras_[i].camera.enabled = false;
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