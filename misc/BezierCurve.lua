local prototype = class("BezierCurve");
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");

prototype.SERIALIZE_FIELD = {
    "keyFrame_",
    "controlPoints_",
    "duration_",
    "value_",
    "controlPointsCount_",
}

function prototype:ctor()
    self.keyFrame_ = {};  --数组，用来存放控制点的关键帧，关键帧也是数组，包括：time，value，leftPosition，rightPosition；
    self.controlPoints_ = {};
    self.duration_ = 0;
    self.value_ = 0;
    self.controlPointsCount_ = 0;
end


function prototype:initialize(controlPoints, duration, value)
    self.controlPoints_ = controlPoints;
    self.duration_ = duration;
    self.value_ = value;
    self.controlPointsCount_ = #controlPoints / 3;
end


function prototype:creatCurve()
    local posIndex = 1;
    for i = 1, self.controlPointsCount_ do
        local position = self.controlPoints_[posIndex];
        posIndex = posIndex + 1;
        local leftPosition = self.controlPoints_[posIndex];
        local newLeftPosition = Vector2.New(leftPosition.x * self.duration_, leftPosition.y * self.value_);
        posIndex = posIndex + 1;
        local rightPosition = self.controlPoints_[posIndex];
        local newRightPosition = Vector2.New(rightPosition.x * self.duration_, rightPosition.y * self.value_);
        self:_addKeyFrame(position.x * self.duration_, position.y * self.value_, newLeftPosition, newRightPosition);
        posIndex = posIndex + 1;
    end
end


function prototype:evaluate(time)
    local index = self:_getTimeIndex(time);
    if index > 0 then
        return self.keyFrame_[index].value;
    end
    if #self.keyFrame_ < 2 then
        return 0;
    end
    time = math.max(time, self.keyFrame_[1].time);
    time = math.min(time, self.keyFrame_[#self.keyFrame_].time)
    local insertIndex = self:_findNearKeyIndex(time);
    local preFrame = self.keyFrame_[insertIndex];
    local nextFrame = self.keyFrame_[insertIndex + 1];
    local points = {};
    points[0] = Vector2.New(preFrame.time, preFrame.value);
    points[1] = preFrame.rightPosition;
    points[2] = nextFrame.leftPosition;
    points[3] = Vector2.New(nextFrame.time, nextFrame.value); 
    local factor = Mathf.InverseLerp(preFrame.time, nextFrame.time, time);
    local position = misc.getPosByTime(factor, points);
    return position.y;
end

function prototype:_addKeyFrame(time, value, leftPosition, rightPosition)  --插入排序
    local point = {};
    point.time = time;
    point.value = value;
    point.leftPosition = leftPosition;
    point.rightPosition = rightPosition;

    for i = 1, #self.keyFrame_ do 
        if self.keyFrame_[i].time > point.time then
            for j = i, #self.keyFrame_ do
                local index = #self.keyFrame_ - j + i;
                self.keyFrame_[index + 1] = self.keyFrame_[index];
            end
            self.keyFrame_[i] = point;
        end
    end
    self.keyFrame_[#self.keyFrame_ + 1] = point;
end


function prototype:_getTimeIndex(time)
    for i = 1, #self.keyFrame_ do
        if self.keyFrame_[i].time == time then
            return i;
        end
    end
    return -1;
end


function prototype:_findNearKeyIndex(time)
    local nearestIndex = 0;
    for i = 1, #self.keyFrame_ do 
        if time > self.keyFrame_[i].time then
            nearestIndex = i;
        else
            return nearestIndex;
        end
    end
    return -1;
end


return prototype;