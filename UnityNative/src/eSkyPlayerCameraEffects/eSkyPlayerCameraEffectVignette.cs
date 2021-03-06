using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.PostProcessing;


public class eSkyPlayerCameraEffectVignetteParam : eSkyPlayerCameraEffectParamBase {
	public int mode;
	public Color color;
	public Vector2 center;
	public float intensity;
	public float smoothness;
	public float roundness;
	public Texture mask;
	public float opacity;
	public bool rounded;
}


public class eSkyPlayerCameraEffectVignette : IeSkyPlayerCameraEffectBase {
    protected Camera m_camera = null;
	protected PostProcessingBehaviour m_postProcessing = null;
	protected eSkyPlayerCameraEffectManager m_manager = null;
	protected VignetteModel.Settings m_vignetteModelSettings;

	public eSkyPlayerCameraEffectVignette(eSkyPlayerCameraEffectManager obj){
		m_manager = obj;
	}


    public void dispose() {
		var type = eSkyPlayerCameraEffectManager.ADDITIONAL_COMPONENT_TYPE.POST_PROCESSING_BEHAVIOUR;
		m_postProcessing.profile.vignette.enabled = false;
		m_manager.releaseAdditionalComponent(type);

//        m_depthOfFieldModelSettings = null;
//        m_depthOfFieldModelDepthOfFieldSetting = null;
    }

    public bool start() {
		if (m_postProcessing != null) {
			return false;
		}
		m_postProcessing = m_manager.getComponentPostProcessingBehaviour ();
		m_postProcessing.profile.vignette.enabled = true;
		m_vignetteModelSettings = m_postProcessing.profile.vignette.settings;

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

		if (param is eSkyPlayerCameraEffectVignetteParam) {
			eSkyPlayerCameraEffectVignetteParam p = param as eSkyPlayerCameraEffectVignetteParam;
			if (m_postProcessing.profile.vignette.enabled == false) {
                return false;
            }
			m_vignetteModelSettings.color = p.color;
			m_vignetteModelSettings.center = p.center;
			m_vignetteModelSettings.intensity = p.intensity;
			m_vignetteModelSettings.smoothness = p.smoothness;
			m_vignetteModelSettings.roundness = p.roundness;
			m_vignetteModelSettings.mask = p.mask;
			m_vignetteModelSettings.opacity = p.opacity;
			m_vignetteModelSettings.rounded = p.rounded;
			switch (p.mode)
            {
            case 1:
				m_vignetteModelSettings.mode = UnityEngine.PostProcessing.VignetteModel.Mode.Classic;
                break;
            case 2:
				m_vignetteModelSettings.mode = UnityEngine.PostProcessing.VignetteModel.Mode.Masked;
                break;
            }

			m_postProcessing.profile.vignette.settings = m_vignetteModelSettings;
        } else {
            return false;
        }

        return true;
    }

    public eSkyPlayerCameraEffectParamBase getParam() {
		if (m_postProcessing == null) {
            return null;
        }

		eSkyPlayerCameraEffectVignetteParam p = new eSkyPlayerCameraEffectVignetteParam ();
		p.color = m_vignetteModelSettings.color;
		p.center = m_vignetteModelSettings.center;
		p.intensity = m_vignetteModelSettings.intensity;
		p.smoothness = m_vignetteModelSettings.smoothness;
		p.roundness = m_vignetteModelSettings.roundness;
		p.mask = m_vignetteModelSettings.mask;
		p.opacity = m_vignetteModelSettings.opacity;
		p.rounded = m_vignetteModelSettings.rounded;
		switch (m_vignetteModelSettings.mode)
        {
		case UnityEngine.PostProcessing.VignetteModel.Mode.Classic:
			p.mode = 1;
            break;
		case UnityEngine.PostProcessing.VignetteModel.Mode.Masked:
			p.mode = 2;
            break;
        }
        return p;
    }
}