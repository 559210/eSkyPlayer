-- RESOURCE_BINDING 
-- made by editor 
-- don't need to modify 
-- 
--[[ 
eSkyPlayerCameraView.RESOURCE_BINDING = {
    component = {
        { path = "btnReturn", id = "n0_mhj1" },
        { path = "btnReturn.n1", id = "n0_mhj1.n1" },
        { path = "btnReturn.n2", id = "n0_mhj1.n2" },
        { path = "btnReturn.n3", id = "n0_mhj1.n3" },
        { path = "btnReturn.title", id = "n0_mhj1.n4" },
        { path = "btnPlay", id = "n1_sc9b" },
        { path = "btnPlay.n1", id = "n1_sc9b.n1" },
        { path = "btnPlay.n2", id = "n1_sc9b.n2" },
        { path = "btnPlay.n3", id = "n1_sc9b.n3" },
        { path = "btnPlay.title", id = "n1_sc9b.n4" },
        { path = "btnPause", id = "n5_dohc" },
        { path = "btnPause.n1", id = "n5_dohc.n1" },
        { path = "btnPause.n2", id = "n5_dohc.n2" },
        { path = "btnPause.n3", id = "n5_dohc.n3" },
        { path = "btnPause.title", id = "n5_dohc.n4" },
        { path = "btnLoad", id = "n6_dohc" },
        { path = "btnLoad.n1", id = "n6_dohc.n1" },
        { path = "btnLoad.n2", id = "n6_dohc.n2" },
        { path = "btnLoad.n3", id = "n6_dohc.n3" },
        { path = "btnLoad.title", id = "n6_dohc.n4" },
        { path = "sliderPlay", id = "n8_dohc" },
        { path = "sliderPlay.n1", id = "n8_dohc.n1" },
        { path = "sliderPlay.bar", id = "n8_dohc.n2" },
        { path = "sliderPlay.grip", id = "n8_dohc.n3" },
        { path = "sliderPlay.grip.n1", id = "n8_dohc.n3.n1" },
        { path = "sliderPlay.grip.n2", id = "n8_dohc.n3.n2" },
        { path = "sliderPlay.grip.n3", id = "n8_dohc.n3.n3" },
    }
}]] 

local prototype = class("eSkyPlayerCameraView", mvc.viewBase)


-- 默认值 PKG_NAME: eSkyPlayerCamera, MAIN_VIEW: main
-- prototype.PKG_NAME = "eSkyPlayerCamera";
-- prototype.MAIN_VIEW = "main";


-- ViewType: MAIN_UI, COMPONENT, WINDOW, FULL_WINDOW
-- 默认值: MAIN_UI
-- prototype.VIEW_TYPE = prototype.ViewType.MAIN_UI;


prototype.RESOURCE_BINDING = {
    component = {
        { path = "btnReturn", id = "n0_mhj1", gevents = { onClick = G.events.SKYPLAYER_CAMERA_RETURN_BUTTON_CLICKED } },
        { path = "btnLoad", id = "n6_dohc", gevents = { onClick = G.events.SKYPLAYER_CAMERA_LOAD_BUTTON_CLICKED } },
        { path = "btnPlay", id = "n1_sc9b", gevents = { onClick = G.events.SKYPLAYER_CAMERA_PLAY_BUTTON_CLICKED } },
        { path = "btnPause", id = "n5_dohc", gevents = { onClick = G.events.SKYPLAYER_CAMERA_PAUSE_BUTTON_CLICKED } },
        slider_ = { path = "sliderPlay", id = "n8_dohc" },
    }
}


-- 构造函数后立即执行，现有构架资源此时已经加载完毕
function prototype:onCreate()
    
end


-- 所有资源加载完毕后调用
function prototype:onStart()
    local go = GameObject.Find("Main Camera");
    self.camera = go:GetComponent(typeof(Camera));

    self.slider_.onChanged:Add(self, self.onSliderChanged);
end


-- ViewType: Window初始化函数
-- function prototype:onWindowInit(window)
--     window.modal = true;
--     window:Center();
-- end


-- 销毁时调用，此处ui还没有从Root中摘除，主要做ui的清理工作
function prototype:onPreDestroy()

end


-- 销毁时调用，此时ui已经被从Root中摘除，这里是释放在此View中自己加载的资源。另外负责View的清理工作
function prototype:onDestroy()

end


function prototype:getCamera()
    return self.camera;
end


function prototype:setSliderMax(max)
    self.slider_.max = max;
end


function prototype:setSliderTouchable(isTrue)
    self.slider_.touchable = isTrue;
end

function prototype:getSliderValue()
    return self.slider_.value;
end

function prototype:setSliderValue(val)
    self.slider_.value = val;
end


function prototype:onSliderChanged(eventContext)
    self:triggerEvent(G.events.SKYPLAYER_CAMERA_PLAY_SLIDER_CHANGED);
end

return prototype;