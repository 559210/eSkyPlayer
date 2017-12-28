using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.PostProcessing;


public class eSkyPlayerCameraEffectBloomParam : eSkyPlayerCameraEffectParamBase {
	public float intensity;
	public float threshold;
	public float softKnee;
	public float radius;
	public bool antiFlicker;
	public float lenDirtIntensity;
	public Texture lenDirtTexture;
}

// TODO: 有4张预置的lenDirt贴图，需要考虑何时加载和释放

public class eSkyPlayerCameraEffectBloom : IeSkyPlayerCameraEffectBase {
//    protected Camera m_camera = null;
    protected PostProcessingBehaviour pp = null;
	protected eSkyPlayerCameraEffectManager manager = null;
    protected BloomModel.Settings m_bloomModelSettings;
    protected BloomModel.BloomSettings m_bloomModelBloomSetting;


	public eSkyPlayerCameraEffectBloom(eSkyPlayerCameraEffectManager obj){
		manager = obj;
	}


    public void dispose() {
		var type = eSkyPlayerCameraEffectManager.ADDITIONAL_COMPONENT_TYPE.POST_PROCESSING_BEHAVIOUR;
		manager.releaseAdditionalComponent (type);

//        m_bloomModelSettings = null;
//        m_bloomModelBloomSetting = null;
//		return true;
    }

    public bool start() {
		pp = manager.getComponentPostProcessingBehaviour ();
		if (pp == null) {
			return false;
		}

		pp.profile.bloom.enabled = true;

        m_bloomModelSettings = pp.profile.bloom.settings;
        m_bloomModelBloomSetting = m_bloomModelSettings.bloom;

        return true;
    }

    public bool stop() {
		dispose ();
		return true;
    }

	public bool pause() {
		if (pp == null) {
			return false;
		}

		return true;
	}

//	public bool resume() {
//		if (pp == null) {
//			return false;
//		}
////		pp.profile.bloom.enabled = true;
//
//		return true;
//	}

    public bool setParam(eSkyPlayerCameraEffectParamBase param) {
		if (pp == null) {
			return false;
		}

		if (param is eSkyPlayerCameraEffectBloomParam) {
			eSkyPlayerCameraEffectBloomParam p = param as eSkyPlayerCameraEffectBloomParam;
			if (pp.profile.bloom.enabled == false) {
				return false;
			}
			m_bloomModelBloomSetting.intensity = p.intensity;
			m_bloomModelBloomSetting.threshold = p.threshold;
			m_bloomModelBloomSetting.softKnee = p.softKnee;
			m_bloomModelBloomSetting.radius = p.radius;
			m_bloomModelBloomSetting.antiFlicker = p.antiFlicker;

			m_bloomModelSettings.lensDirt.texture = p.lenDirtTexture;

			m_bloomModelSettings.bloom = m_bloomModelBloomSetting;
			pp.profile.bloom.settings = m_bloomModelSettings;
		} else {
			return false;
		}

        return true;
    }

    public eSkyPlayerCameraEffectParamBase getParam() {
		if (pp == null) {
			return null;
		}

		eSkyPlayerCameraEffectBloomParam p = new eSkyPlayerCameraEffectBloomParam ();
		p.intensity = m_bloomModelBloomSetting.intensity;
		p.threshold = m_bloomModelBloomSetting.threshold;
		p.softKnee = m_bloomModelBloomSetting.softKnee;
		p.radius = m_bloomModelBloomSetting.radius;
		p.antiFlicker = m_bloomModelBloomSetting.antiFlicker;
		p.lenDirtTexture = m_bloomModelSettings.lensDirt.texture;

        return p;
    }
}
