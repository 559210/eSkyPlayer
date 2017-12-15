local prototype = class("eSkyPlayerTimeLine");

function prototype:ctor()
    self.timeLine_ = 0;
end


function prototype:initialize()

end


function prototype:getTime()
    return self.timeLine_;
end


function prototype:setTime(time)
    self.timeLine_ = time;
end


return prototype;