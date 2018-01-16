using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using CameraTransitions;

public class eSkyPlayerCameraEffectTransitionParam : eSkyPlayerCameraEffectParamBase {
	public float progress;
}


public class eSkyPlayerCameraEffectTransitions : IeSkyPlayerCameraEffectBase {
	protected eSkyPlayerCameraEffectManager m_manager = null;
	protected CameraTransition m_cameraTransition = null;

	protected float m_duration = 0.0f;

	public float duration {
		set {
			m_duration = value;
		}
		get {
			return m_duration;
		}
	}

	public eSkyPlayerCameraEffectTransitions(eSkyPlayerCameraEffectManager obj){
		m_manager = obj;
		m_cameraTransition = m_manager.getComponentCameraTransitionBehaviour ();
	}


	public void dispose()
	{
		m_manager.releaseAdditionalComponent (eSkyPlayerCameraEffectManager.ADDITIONAL_COMPONENT_TYPE.POST_PROCESSING_BEHAVIOUR);
	}


	public bool start()
	{
		if (m_cameraTransition == null || m_manager == null || m_duration <= 0) {
			return false;
		}
		Camera from = m_manager.getMainCamera ();
		Camera to = m_manager.getSecondCamera ();
		if (from == null || to == null) {
			return false;
		}

		m_cameraTransition.DoTransition (CameraTransitionEffects.CrossFade, from, to, m_duration, null);
		return true;
	}

	public bool close(){
		return true;
	}

	public bool stop()
	{
		dispose ();
		return true;
	}


	public bool pause ()
	{
		return false;
	}


	public bool setParam(eSkyPlayerCameraEffectParamBase param)
	{	
		if (m_cameraTransition == null) {
			return false;
		}

		eSkyPlayerCameraEffectTransitionParam p = param as eSkyPlayerCameraEffectTransitionParam;
		m_cameraTransition.Progress = p.progress;

		return true;
	}


	public eSkyPlayerCameraEffectParamBase getParam()
	{
		if (m_cameraTransition == null) {
			return null;
		}

		eSkyPlayerCameraEffectTransitionParam p = new eSkyPlayerCameraEffectTransitionParam ();
		p.progress = m_cameraTransition.Progress;

		return p;
	}
}
