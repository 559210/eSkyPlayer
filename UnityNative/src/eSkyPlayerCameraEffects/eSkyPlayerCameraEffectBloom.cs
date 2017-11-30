using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.PostProcessing;

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
        m_pp = m_camera.gameObject.AddComponent<PostProcessingBehaviour>();
        m_pp.profile = new PostProcessingProfile();
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
		if (m_pp.profile.bloom.enabled == false) {
			return false;
		}
//        BloomModel.Settings setting = this.m_pp.profile.bloom.settings;
//        BloomModel.BloomSettings bloomSetting = setting.bloom;
//        bloomSetting.intensity = m_intensity;
//        setting.bloom = bloomSetting;
//        this.m_pp.profile.bloom.settings = setting;

        return true;
    }

    public eSkyPlayerCameraEffectParamBase getParam() {

        return null;
    }
}
