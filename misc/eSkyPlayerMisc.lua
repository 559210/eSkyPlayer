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


return prototype;