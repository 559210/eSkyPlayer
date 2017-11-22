local prototype = {};

function prototype.getByteByBool(value)
    if value == true then
        return 1;
    else
        return 0;
    end
end


function prototype.getBoolByByte(value)
    if value == 1 then
        return true;
    else
        return false;
    end
end

return prototype;