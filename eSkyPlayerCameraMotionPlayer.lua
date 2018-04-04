local prototype = class("eSkyPlayerCameraMotionPlayer",require "eSkyPlayer/eSkyPlayerBase");


function prototype:ctor(director)
    prototype.super.ctor(self, director);
    self.trackObj_ = nil;
    self.isNeedAdditionalCamera_ = false;
    self.cameras_ = {};
end


function prototype:initialize(trackObj)
    prototype.super.initialize(self, trackObj);
    self.trackObj_ = trackObj;
    --self.cameras_目前有两个Camera，第一个默认为主Camera，第二个为需要时另外创建的Camera。
    self.cameras_ = {{camera_ = self.director_.camera_;
    isUsed_ = false},};
    self:_isNeedAdditionalCamera();
    return self.base:initialize(trackObj);
end


function prototype:play()
    if self.trackObj_ == nil  then
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
    cam.camera_ = camera;
    cam.isUsed_ = false;
    self.cameras_[#self.cameras_ + 1] = cam;
end


function prototype:onEventEntered(eventObj, beginTime)
    local cam = self:_requestCamera();
    if cam ~= nil then
        self.playingEvents_[#self.playingEvents_].camera_ = cam;
    end
end


function prototype:onEventLeft(eventObj)
    for i = 1, #self.playingEvents_ do
        local event = self.playingEvents_[i];
        if event.obj_ == eventObj then
            if self:_returnCamera(event.camera_) == false then    --true表示返回Camera后面没有其他Camera
                for j = i + 1, #self.playingEvents_ do
                    self:_returnCamera(self.playingEvents_[j].camera_);
                end
                for j = i + 1, #self.playingEvents_ do
                    local cam = self:_requestCamera();
                    if cam ~= nil then
                        self.playingEvents_[j].camera_ = cam;
                    end
                end
            end
            break;
        end
    end
end


function prototype:_update()
    self.base:_update();

    for index = 1, #self.playingEvents_ do
        self:_transformCamera(self.playingEvents_[index]);
    end
end

function prototype:_transformCamera(queue)
    local camera = queue.camera_;
    local eventObj = queue.obj_;
    local deltaTime = self.director_.timeLine_ - queue.beginTime_;
    if eventObj.eventData_.tweenType_ == 0 then
        deltaTime = self:_getTime(deltaTime, eventObj.eventData_.timeLength_, eventObj.eventData_.pos1_, eventObj.eventData_.pos2_);
        if deltaTime > eventObj.eventData_.timeLength_ then
            deltaTime = eventObj.eventData_.timeLength_;
        end
    end
    local ratio = deltaTime / eventObj.eventData_.timeLength_ ;
    local quater = Quaternion.Lerp (eventObj.eventData_.beginDr_, eventObj.eventData_.endDr_, ratio );
    local lookPos = Vector3.Lerp (eventObj.eventData_.beginLookAt_, eventObj.eventData_.endLookAt_, ratio );
    local beginDistance = Vector3.Distance(eventObj.eventData_.beginFrame_, eventObj.eventData_.beginLookAt_);
    local endDistance = Vector3.Distance(eventObj.eventData_.endFrame_, eventObj.eventData_.endLookAt_);
    local distance = beginDistance + (endDistance - beginDistance) * ratio;
    local pos = self:_getPosByAngle(quater.eulerAngles, lookPos, distance);
    camera.transform:SetPositionAndRotation(pos, quater)
-----------------------
--TODO:fov要用起来；cameraMotionPlayer的播放要在cameraEffectPlayer的前面
end

function prototype:_getPosByAngle(angle, offsetPos, distance)
    distance = math.max(distance, 0);
    local radiusVes = Vector3.New(0, 0, - distance);
    local qn = Quaternion.Euler(angle.x, angle.y, angle.z);
    local pos = qn * radiusVes + Vector3.New(offsetPos.x, offsetPos.y, offsetPos.z);
    return pos;
end

function prototype:_requestCamera()
    for i = 1,#self.cameras_ do
        if self.cameras_[i].isUsed_ == false then
            self.cameras_[i].isUsed_ = true;
            if i > 1 then    --i>1时表示主camera已经在播放event，申请的camera需要enable
                self.cameras_[i].camera_.enabled = true;
            end
            return self.cameras_[i].camera_;
        end
    end
    return nil;
end

function prototype:_returnCamera(cam)
    for i = 1,#self.cameras_ do
        if self.cameras_[i].camera_ == cam then
            self.cameras_[i].isUsed_ = false;
            if i > 1 then
                self.cameras_[i].camera_.enabled = false;
            end
            for j = i,#self.cameras_ do
                if self.cameras_[j].isUsed_ == true then
                    return false;
                end
            end
            return true;  --true表示返回Camera后面没有其他Camera在被使用
        end
    end
    logError("未找到要归还的Camera！");
    return true;
end

function prototype:_isNeedAdditionalCamera()
    if self.trackObj_:isNeedAdditionalCamera() == true then
        self.isNeedAdditionalCamera_ = true;
    else 
        self.isNeedAdditionalCamera_ = false;
    end
end


function prototype:_getTime(time, totalTime, ctrlPoint1, ctrlPoint2)
    if time < 0 then
        time = 0;
    end
    if totalTime < 0 then
        totalTime = 0;
    end
    local timeRatio = Mathf.Clamp(time / totalTime, 0, 1);
    if time > totalTime then
        timeRatio = 1;
    end
    if timeRatio == 0 or timeRatio == 1 then
        return time;
    end
    local curveResultData = {};
    curveResultData.pos = Vector2.New(x,y);
    curveResultData.minTime = 0;
    curveResultData.maxTime = 1;
    while (true) do
        curveResultData = self:_getNearPoint(timeRatio, curveResultData.minTime, curveResultData.maxTime, ctrlPoint1, ctrlPoint2);
        local value = curveResultData.pos.y - timeRatio;
        if value < 0.0001 and value >= 0 then
            break;
        end
    end
    return curveResultData.pos.x * totalTime;
end

function prototype:_getNearPoint(posY, minTimeRatio, maxTimeRatio, ctrlPoint1, ctrlPoint2)
    local curveResultData = {};
    local middleTimeRatio = self:_getMiddleTimeRatio(minTimeRatio, maxTimeRatio);
    curveResultData.pos = self:_getPosByTime(middleTimeRatio, self:_getPoints(ctrlPoint1, ctrlPoint2, Rect.New(0, 0, 1, 1)));
    curveResultData.minTime = middleTimeRatio;
    curveResultData.maxTime = maxTimeRatio;
    if posY < curveResultData.pos.y then
        curveResultData.minTime = minTimeRatio;
        curveResultData.maxTime = middleTimeRatio;
    end

    return curveResultData;
end

function prototype:_getMiddleTimeRatio(minTimeRatio, maxTimeRatio)
    local middleTimeRatio = (maxTimeRatio - minTimeRatio) * 0.5 + minTimeRatio;
    return middleTimeRatio;
end

function prototype:_getPoints(ctrlPoint1, ctrlPoint2, rect)
    local points = {};
    points[0] = Vector2.New(rect.x, rect.y);
    points[3] = Vector2.New(rect.width, rect.height);
    points[1] = Vector2.New(rect.width * ctrlPoint1.x, rect.height * ctrlPoint1.y);
    points[2] = Vector2.New(rect.width * ctrlPoint2.x, rect.height * ctrlPoint2.y); 
    return points;
end

function prototype:_getPosByTime(t, points)
    local p = Vector2.New(x,y);
    p.x = points[0].x * (1 - t) ^ 3 + 3 * points[1].x * t * (1 - t) ^ 2 + 3 * points[2].x * t ^ 2 * (1 - t) + points[3].x * t ^ 3;
    p.y = points[0].y * (1 - t) ^ 3 + 3 * points[1].y * t * (1 - t) ^ 2 + 3 * points[2].y * t ^ 2 * (1 - t) + points[3].y * t ^ 3;
    return p;
end


return prototype;