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
    for k, v in pairs(proto) do
        if param[k] == nil then
            return false;
        end

        local s, e = string.find(v, ",");
        if s ~= nil and e ~= nil then
            local pre = string.sub(v, 1, s - 1);
            local lst = string.sub(v, e + 1, string.len(v));
            if pre == "array" then
                local field = param[k];
                if type(field) ~= "table" then
                    return false;
                end

                for i = 1, #field do
                    if field[i] == nil or type(field[i]) ~= lst then
                        return false;
                    end
                end
            end
        else
            if type(param[k]) ~= v then
                return false;
            end
        end
    end
    return true;
end


function prototype.getPosByTime(t, points)
    local p = Vector2.New(x,y);
    p.x = points[0].x * (1 - t) ^ 3 + 3 * points[1].x * t * (1 - t) ^ 2 + 3 * points[2].x * t ^ 2 * (1 - t) + points[3].x * t ^ 3;
    p.y = points[0].y * (1 - t) ^ 3 + 3 * points[1].y * t * (1 - t) ^ 2 + 3 * points[2].y * t ^ 2 * (1 - t) + points[3].y * t ^ 3;
    return p;
end


return prototype;