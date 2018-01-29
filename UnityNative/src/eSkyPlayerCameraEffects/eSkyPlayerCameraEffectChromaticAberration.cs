using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.PostProcessing;


public class eSkyPlayerCameraEffectChromaticAberrationParam : eSkyPlayerCameraEffectParamBase {
	public Texture2D spectralTexture;
	public float intensity;
}

// TODO: 有4张预置的lenDirt贴图，需要考虑何时加载和释放

public class eSkyPlayerCameraEffectChromaticAberration : IeSkyPlayerCameraEffectBase {
    protected Camera m_camera = null;
	protected PostProcessingBehaviour m_postProcessing = null;
	protected eSkyPlayerCameraEffectManager m_manager = null;
	protected ChromaticAberrationModel.Settings m_chromaticAberrationModelSettings;

	public eSkyPlayerCameraEffectChromaticAberration(eSkyPlayerCameraEffectManager obj){
		m_manager = obj;
	}


    public void dispose() {
		var type = eSkyPlayerCameraEffectManager.ADDITIONAL_COMPONENT_TYPE.POST_PROCESSING_BEHAVIOUR;
		m_postProcessing.profile.chromaticAberration.enabled = false;
		m_manager.releaseAdditionalComponent(type);

//        m_bloomModelSettings = null;
//        m_bloomModelBloomSetting = null;
    }

    public bool start() {
		if (m_postProcessing != null) {
			return false;
		}
		m_postProcessing = m_manager.getComponentPostProcessingBehaviour ();
		m_postProcessing.profile.chromaticAberration.enabled = true;

		m_chromaticAberrationModelSettings = m_postProcessing.profile.chromaticAberration.settings;

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

		if (param is eSkyPlayerCameraEffectChromaticAberrationParam) {
			eSkyPlayerCameraEffectChromaticAberrationParam p = param as eSkyPlayerCameraEffectChromaticAberrationParam;
			if (m_postProcessing.profile.chromaticAberration.enabled == false) {
                return false;
            }
			m_chromaticAberrationModelSettings.spectralTexture = p.spectralTexture;
			m_chromaticAberrationModelSettings.intensity = p.intensity;

			m_postProcessing.profile.chromaticAberration.settings = m_chromaticAberrationModelSettings;
        } else {
            return false;
        }

        return true;
    }

    public eSkyPlayerCameraEffectParamBase getParam() {
		if (m_postProcessing == null) {
            return null;
        }

		eSkyPlayerCameraEffectChromaticAberrationParam p = new eSkyPlayerCameraEffectChromaticAberrationParam ();
		p.spectralTexture = m_chromaticAberrationModelSettings.spectralTexture;
		p.intensity = m_chromaticAberrationModelSettings.intensity;

        return p;
    }
}
