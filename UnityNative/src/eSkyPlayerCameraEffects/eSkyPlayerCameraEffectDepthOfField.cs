using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.PostProcessing;


public class eSkyPlayerCameraEffectDepthOfFieldParam : eSkyPlayerCameraEffectParamBase {
	public float focusDistance;
    public float aperture;
	public float focalLength;
	public bool useCameraFov;
	public int kernelSize;
}


public class eSkyPlayerCameraEffectDepthOfField : IeSkyPlayerCameraEffectBase {
//    protected Camera m_camera = null;
    protected PostProcessingBehaviour pp = null;
	protected eSkyPlayerCameraEffectManager manager = null;
    protected DepthOfFieldModel.Settings m_depthOfFieldModelSettings;

	public eSkyPlayerCameraEffectDepthOfField(eSkyPlayerCameraEffectManager obj){
		manager = obj;
	}


    public void dispose() {
		var type = eSkyPlayerCameraEffectManager.ADDITIONAL_COMPONENT_TYPE.POST_PROCESSING_BEHAVIOUR;
		manager.releaseAdditionalComponent(type);
//        m_depthOfFieldModelSettings = null;
//        m_depthOfFieldModelDepthOfFieldSetting = null;
    }

    public bool start() {
		pp = manager.getComponentPostProcessingBehaviour ();
		if (pp == null) {
			return false;
		}
		pp.profile.depthOfField.enabled = true;

		m_depthOfFieldModelSettings = pp.profile.depthOfField.settings;

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

//    public bool resume() {
//		if (pp == null) {
//            return false;
//        }
////		pp.profile.depthOfField.enabled = true;
//
//        return true;
//    }

    public bool setParam(eSkyPlayerCameraEffectParamBase param) {
		if (pp == null) {
            return false;
        }

        if (param is eSkyPlayerCameraEffectDepthOfFieldParam) {
            eSkyPlayerCameraEffectDepthOfFieldParam p = param as eSkyPlayerCameraEffectDepthOfFieldParam;
			if (pp.profile.depthOfField.enabled == false) {
                return false;
            }
			m_depthOfFieldModelSettings.focusDistance = p.focusDistance;
			m_depthOfFieldModelSettings.aperture = p.aperture;
			m_depthOfFieldModelSettings.focalLength = p.focalLength;
			m_depthOfFieldModelSettings.useCameraFov = p.useCameraFov;
			switch (p.kernelSize)
			{
			case 1:
				m_depthOfFieldModelSettings.kernelSize = UnityEngine.PostProcessing.DepthOfFieldModel.KernelSize.Small;
				break;
			case 2:
				m_depthOfFieldModelSettings.kernelSize = UnityEngine.PostProcessing.DepthOfFieldModel.KernelSize.Medium;
				break;
			case 3:
				m_depthOfFieldModelSettings.kernelSize = UnityEngine.PostProcessing.DepthOfFieldModel.KernelSize.Large;
				break;
			case 4:
				m_depthOfFieldModelSettings.kernelSize = UnityEngine.PostProcessing.DepthOfFieldModel.KernelSize.VeryLarge;
				break;
			}

			pp.profile.depthOfField.settings = m_depthOfFieldModelSettings;
        } else {
            return false;
        }

        return true;
    }

    public eSkyPlayerCameraEffectParamBase getParam() {
		if (pp == null) {
            return null;
        }

        eSkyPlayerCameraEffectDepthOfFieldParam p = new eSkyPlayerCameraEffectDepthOfFieldParam ();
		p.focusDistance = m_depthOfFieldModelSettings.focusDistance;
		p.aperture = m_depthOfFieldModelSettings.aperture;
		p.focalLength = m_depthOfFieldModelSettings.focalLength;
		p.useCameraFov = m_depthOfFieldModelSettings.useCameraFov;
		switch (m_depthOfFieldModelSettings.kernelSize)
		{
		case UnityEngine.PostProcessing.DepthOfFieldModel.KernelSize.Small:
			p.kernelSize = 1;
			break;
		case UnityEngine.PostProcessing.DepthOfFieldModel.KernelSize.Medium:
			p.kernelSize = 2;
			break;
		case UnityEngine.PostProcessing.DepthOfFieldModel.KernelSize.Large:
			p.kernelSize = 3;
			break;
		case UnityEngine.PostProcessing.DepthOfFieldModel.KernelSize.VeryLarge:
			p.kernelSize = 4;
			break;
		}

        return p;
    }
}