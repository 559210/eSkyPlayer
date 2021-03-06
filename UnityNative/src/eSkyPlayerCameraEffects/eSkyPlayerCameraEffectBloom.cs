﻿using System.Collections;
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
	protected PostProcessingBehaviour m_postProcessing = null;
	protected eSkyPlayerCameraEffectManager m_manager = null;


    protected BloomModel.Settings m_bloomModelSettings;
    protected BloomModel.BloomSettings m_bloomModelBloomSetting;


	public eSkyPlayerCameraEffectBloom(eSkyPlayerCameraEffectManager obj){
		m_manager = obj;
	}


    public void dispose() {
		var type = eSkyPlayerCameraEffectManager.ADDITIONAL_COMPONENT_TYPE.POST_PROCESSING_BEHAVIOUR;
		m_postProcessing.profile.bloom.enabled = false;
		m_manager.releaseAdditionalComponent (type);
    }

    public bool start() {
		if (m_postProcessing != null) {
			return false;
		}
		m_postProcessing = m_manager.getComponentPostProcessingBehaviour ();
		m_postProcessing.profile.bloom.enabled = true;

		m_bloomModelSettings = m_postProcessing.profile.bloom.settings;
        m_bloomModelBloomSetting = m_bloomModelSettings.bloom;

        return true;
    }
		
	public bool destroy() {
		dispose ();
		return true;
    }

	public bool pause() {
		if (m_postProcessing == null) {
			return false;
		}

		return true;
	}


    public bool setParam(eSkyPlayerCameraEffectParamBase param) {
		if (m_postProcessing == null) {
			return false;
		}

		if (param is eSkyPlayerCameraEffectBloomParam) {
			eSkyPlayerCameraEffectBloomParam p = param as eSkyPlayerCameraEffectBloomParam;
			if (m_postProcessing.profile.bloom.enabled == false) {
				return false;
			}
			m_bloomModelBloomSetting.intensity = p.intensity;
			m_bloomModelBloomSetting.threshold = p.threshold;
			m_bloomModelBloomSetting.softKnee = p.softKnee;
			m_bloomModelBloomSetting.radius = p.radius;
			m_bloomModelBloomSetting.antiFlicker = p.antiFlicker;

			m_bloomModelSettings.lensDirt.intensity = p.lenDirtIntensity;
			m_bloomModelSettings.lensDirt.texture = p.lenDirtTexture;

			m_bloomModelSettings.bloom = m_bloomModelBloomSetting;
			m_postProcessing.profile.bloom.settings = m_bloomModelSettings;
		} else {
			return false;
		}

        return true;
    }

    public eSkyPlayerCameraEffectParamBase getParam() {
		if (m_postProcessing == null) {
			return null;
		}

		eSkyPlayerCameraEffectBloomParam p = new eSkyPlayerCameraEffectBloomParam ();
		p.intensity = m_bloomModelBloomSetting.intensity;
		p.threshold = m_bloomModelBloomSetting.threshold;
		p.softKnee = m_bloomModelBloomSetting.softKnee;
		p.radius = m_bloomModelBloomSetting.radius;
		p.antiFlicker = m_bloomModelBloomSetting.antiFlicker;

		p.lenDirtIntensity = m_bloomModelSettings.lensDirt.intensity;
		p.lenDirtTexture = m_bloomModelSettings.lensDirt.texture;

        return p;
    }
}
