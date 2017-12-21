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
	public Texture2D lenDirtTexture;
}

// TODO: 有4张预置的lenDirt贴图，需要考虑何时加载和释放

public class eSkyPlayerCameraEffectBloom : IeSkyPlayerCameraEffectBase {
    protected Camera m_camera = null;
    protected PostProcessingBehaviour m_pp = null;
    protected BloomModel.Settings m_bloomModelSettings;
    protected BloomModel.BloomSettings m_bloomModelBloomSetting;

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
        m_pp.profile.bloom.enabled = true;

        m_bloomModelSettings = m_pp.profile.bloom.settings;
        m_bloomModelBloomSetting = m_bloomModelSettings.bloom;

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

		m_pp.profile.bloom.enabled = false;

		return true;
	}

	public bool resume() {
		if (m_pp == null) {
			return false;
		}
		m_pp.profile.bloom.enabled = true;

		return true;
	}

    public bool setParam(eSkyPlayerCameraEffectParamBase param) {
		if (m_pp == null) {
			return false;
		}

		if (param is eSkyPlayerCameraEffectBloomParam) {
			eSkyPlayerCameraEffectBloomParam p = param as eSkyPlayerCameraEffectBloomParam;
			if (m_pp.profile.bloom.enabled == false) {
				return false;
			}
			m_bloomModelBloomSetting.intensity = p.intensity;
			m_bloomModelBloomSetting.threshold = p.threshold;
			m_bloomModelBloomSetting.softKnee = p.softKnee;
			m_bloomModelBloomSetting.radius = p.radius;
			m_bloomModelBloomSetting.antiFlicker = p.antiFlicker;

			m_bloomModelSettings.lensDirt.texture = p.lenDirtTexture;

			m_bloomModelSettings.bloom = m_bloomModelBloomSetting;
			m_pp.profile.bloom.settings = m_bloomModelSettings;
		} else {
			return false;
		}

        return true;
    }

    public eSkyPlayerCameraEffectParamBase getParam() {
		if (m_pp == null) {
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
