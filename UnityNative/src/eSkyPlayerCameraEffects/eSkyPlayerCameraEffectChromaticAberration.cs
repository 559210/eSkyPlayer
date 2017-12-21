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
    protected PostProcessingBehaviour m_pp = null;
	protected ChromaticAberrationModel.Settings m_chromaticAberrationModelSettings;

    public bool create(Camera ca) {
        if (ca == null)
        {
            return false;
        }

        m_camera = ca;
        return true;
    }

    public void dispose() {
        if (m_pp != null)
        {
            UnityEngine.GameObject.Destroy(m_pp);
            m_pp = null;
        }

        if (m_camera != null)
        {
            m_camera = null;
        }

//        m_bloomModelSettings = null;
//        m_bloomModelBloomSetting = null;
    }

    public bool start() {
        m_pp = m_camera.gameObject.GetComponent<PostProcessingBehaviour>();
        if (m_pp == null) {
            m_pp = m_camera.gameObject.AddComponent<PostProcessingBehaviour> ();
            m_pp.profile = new PostProcessingProfile ();
        }
		m_pp.profile.chromaticAberration.enabled = true;

		m_chromaticAberrationModelSettings = m_pp.profile.chromaticAberration.settings;

        return true;
    }

    public bool stop() {
        dispose ();
        return true;
    }

    public bool pause() {
        if (m_pp == null) {
            return false;
        }

		m_pp.profile.chromaticAberration.enabled = false;

        return true;
    }

    public bool resume() {
        if (m_pp == null) {
            return false;
        }
		m_pp.profile.chromaticAberration.enabled = true;

        return true;
    }

    public bool setParam(eSkyPlayerCameraEffectParamBase param) {
        if (m_pp == null) {
            return false;
        }

		if (param is eSkyPlayerCameraEffectChromaticAberrationParam) {
			eSkyPlayerCameraEffectChromaticAberrationParam p = param as eSkyPlayerCameraEffectChromaticAberrationParam;
			if (m_pp.profile.chromaticAberration.enabled == false) {
                return false;
            }
			m_chromaticAberrationModelSettings.spectralTexture = p.spectralTexture;
			m_chromaticAberrationModelSettings.intensity = p.intensity;

			m_pp.profile.chromaticAberration.settings = m_chromaticAberrationModelSettings;
        } else {
            return false;
        }

        return true;
    }

    public eSkyPlayerCameraEffectParamBase getParam() {
        if (m_pp == null) {
            return null;
        }

		eSkyPlayerCameraEffectChromaticAberrationParam p = new eSkyPlayerCameraEffectChromaticAberrationParam ();
		p.spectralTexture = m_chromaticAberrationModelSettings.spectralTexture;
		p.intensity = m_chromaticAberrationModelSettings.intensity;

        return p;
    }
}
