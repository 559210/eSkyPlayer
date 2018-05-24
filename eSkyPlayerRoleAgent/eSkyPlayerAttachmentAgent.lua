local prototype = class("eSkyPlayerAttachmentAgent");



function prototype:ctor(item)
    self.item_ = item;
end


function prototype:initialize()

end


function prototype:getItem()
    return self.item_;
end

return prototype;