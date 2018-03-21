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

function prototype.readAllBytes(path)
    if prototype.isEditorModel() == true then
        return FileUtils.readAllBytes(path);
    else
        local index = string.find(path, G.const.rootName);

        path = string.sub(path, index);
        return ddResManager.readBinaryFile(path);
    end
end


function prototype.isEditorModel()
    if defineSymbol.isFixedPlay == true then
        return false;
    end
    if defineSymbol.isEditor == true then
        return true;
    else
        return false;
    end
end


function prototype.getValuesByInfo(valueInfo)
    local values = {};
    if #valueInfo.ranges  == 1 then
        values[1] = valueInfo.ranges[1] * valueInfo.weights[1];
    else
        for _, weight in ipairs(valueInfo.weights) do
            values[#values + 1] = weight * (valueInfo.ranges[2] - valueInfo.ranges[1]) + valueInfo.ranges[1];
        end
    end
    
    return values;
end


function prototype.checkParam(proto, param)
    if param == nil then return false; end
    for k,v in pairs(proto) do
        if param[k] == nil or type(param[k]) ~= v then
            return false;
        end
    end
    return true;
end

return prototype;