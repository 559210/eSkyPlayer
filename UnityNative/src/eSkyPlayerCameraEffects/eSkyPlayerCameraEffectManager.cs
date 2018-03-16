using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.PostProcessing;
using CameraTransitions;
using UnityStandardAssets.ImageEffects;
using System;

public class AdditionalComponent<T> : ReferenceCountBase where T : class {
	protected T m_object;

	public AdditionalComponent(T obj) {
		m_object = obj;
	}

	public T getObject() {
//		if (m_object == null) {
//			return null;
//		}
		this.addReference();
		return m_object;
	}

	// 如果引用计数到0，对象真正被删除：return true; 否则return false 
	public bool releaseObject() {
		if (this.decreaseReference() <= 0) {
			m_object = null;
			return true;
		}

		return false;
	}
}
public class eSkyPlayerCameraEffectManager {
	public enum ADDITIONAL_COMPONENT_TYPE{
		POST_PROCESSING_BEHAVIOUR,
		CAMERA_TRANSITIONS,
		SCREEN_OVERLAY,
	};

	protected Dictionary<ADDITIONAL_COMPONENT_TYPE, ReferenceCountBase> m_additionalComponents = new Dictionary<ADDITIONAL_COMPONENT_TYPE, ReferenceCountBase>();
	protected Dictionary<int, IeSkyPlayerCameraEffectBase> m_effects = new Dictionary<int, IeSkyPlayerCameraEffectBase>();
	protected int m_effectIndexFactory = 0;
	protected Camera m_mainCamera = null;
	protected Camera m_secondCamera = null;
	protected static int ms_gameObjectCount = 0;
	protected GameObject m_gameObject = null;

	public eSkyPlayerCameraEffectManager() {

	}

	public PostProcessingBehaviour getComponentPostProcessingBehaviour(){
		ADDITIONAL_COMPONENT_TYPE type = ADDITIONAL_COMPONENT_TYPE.POST_PROCESSING_BEHAVIOUR;
		if (m_additionalComponents.ContainsKey (type) == false) {
			PostProcessingBehaviour pp = m_mainCamera.gameObject.AddComponent<PostProcessingBehaviour> ();
			pp.profile = new PostProcessingProfile ();
			ReferenceCountBase value = new AdditionalComponent<PostProcessingBehaviour> (pp);
			m_additionalComponents.Add (type, value);
		}
		var obj = m_additionalComponents [type] as AdditionalComponent<PostProcessingBehaviour> ;
		return obj.getObject ();
	}
		
	public ScreenOverlay getComponentScreenOverlayBehaviour() {
		ADDITIONAL_COMPONENT_TYPE type = ADDITIONAL_COMPONENT_TYPE.SCREEN_OVERLAY;
		if (m_additionalComponents.ContainsKey(type) == false) {
			ScreenOverlay so = m_mainCamera.gameObject.AddComponent<ScreenOverlay> ();

			ReferenceCountBase value = new AdditionalComponent<ScreenOverlay> (so);
			m_additionalComponents.Add (type, value);
		}

		var obj = m_additionalComponents [type] as AdditionalComponent<ScreenOverlay>;
		return obj.getObject ();
	}
		
	public Component addComponent(Type c){
		Component component = m_gameObject.AddComponent(c);
		return component;
	}

	public void removeComponent(Type c){
		UnityEngine.Object.Destroy(m_gameObject.GetComponent(c));
	}

	public void releaseAdditionalComponent(ADDITIONAL_COMPONENT_TYPE type){
		switch(type){
		case eSkyPlayerCameraEffectManager.ADDITIONAL_COMPONENT_TYPE.POST_PROCESSING_BEHAVIOUR:
			{
				if (m_additionalComponents.ContainsKey (eSkyPlayerCameraEffectManager.ADDITIONAL_COMPONENT_TYPE.POST_PROCESSING_BEHAVIOUR) == true) {
					var obj = m_additionalComponents [type] as AdditionalComponent<PostProcessingBehaviour>;
					if (obj.releaseObject () == true) {
						m_additionalComponents.Remove (type);
						UnityEngine.Object.DestroyImmediate(m_mainCamera.gameObject.GetComponent<PostProcessingBehaviour> ());
					}
				}
			}
			break;
		case eSkyPlayerCameraEffectManager.ADDITIONAL_COMPONENT_TYPE.SCREEN_OVERLAY:
			{
				if (m_additionalComponents.ContainsKey (eSkyPlayerCameraEffectManager.ADDITIONAL_COMPONENT_TYPE.SCREEN_OVERLAY) == true) {
					var obj = m_additionalComponents [type] as AdditionalComponent<ScreenOverlay>;
					if (obj.releaseObject () == true) {
						m_additionalComponents.Remove (type);
						UnityEngine.Object.DestroyImmediate (m_mainCamera.gameObject.GetComponent<ScreenOverlay> ());
					}
				}
			}
			break;

		default:
			break;
		}
	}

	public void creatGameObject(){
		m_gameObject = new GameObject();
		m_gameObject.name = "GameObject" + ms_gameObjectCount;
		ms_gameObjectCount++;
	}
		
	//实现手动删除不需要的资源的功能，未完善
//	public void clear(){
//		List<ADDITIONAL_COMPONENT_TYPE> list = new List<ADDITIONAL_COMPONENT_TYPE>();
//		foreach (KeyValuePair<ADDITIONAL_COMPONENT_TYPE, ReferenceCountBase> item in m_additionalComponents) {
//			var obj = m_additionalComponents [item.Key] as AdditionalComponent<PostProcessingBehaviour>;
//			if (obj.releaseObject () == true) {
//				list.Add (item.Key);
//			}
//		}
//		foreach (ADDITIONAL_COMPONENT_TYPE type in list) {
//			releaseAdditionalComponent (type);
//			//m_additionalComponents.Remove (type);
//		}
//	}
	//播放完成后清空资源
	public void dispose(){
		if (m_mainCamera != null) {
			UnityEngine.Object.DestroyImmediate(m_mainCamera.gameObject.GetComponent<PostProcessingBehaviour>());
			UnityEngine.Object.DestroyImmediate(m_mainCamera.gameObject.GetComponent<ScreenOverlay>());
			UnityEngine.Object.DestroyImmediate(m_gameObject.GetComponent<CameraTransition>());
			m_additionalComponents = null;
			m_mainCamera = null;
			GameObject.Destroy (m_gameObject);
		}
//		foreach (KeyValuePair<ADDITIONAL_COMPONENT_TYPE, ReferenceCountBase> item in m_additionalComponents) {
//			releaseAdditionalComponent (item.Key);
//		}
	}

	public Camera getMainCamera() {
		return m_mainCamera;
	}


	public Camera getSecondCamera() {
		return m_secondCamera;
	}

	public bool initialize(Camera cam, Camera secondCam = null) {
		if (cam == null || m_mainCamera != null) {
			return false;
		}
		m_mainCamera = cam;
		m_secondCamera = secondCam;
		if (m_gameObject == null) {
			creatGameObject ();
		}

		return true;
	}

	protected int getNewEffectIndex() {
		m_effectIndexFactory++;
		return m_effectIndexFactory;
	}

	protected IeSkyPlayerCameraEffectBase getEffectObjectById(int effectId) {
		if (!m_effects.ContainsKey (effectId)) {
			return null;
		}

		return m_effects [effectId];
	}

	public int createBloomEffect() {
		if (m_mainCamera == null) {
			return -1;
		}

		eSkyPlayerCameraEffectBloom bloom = new eSkyPlayerCameraEffectBloom (this);
		int index = getNewEffectIndex ();
		m_effects.Add (index, bloom);
		return index;
	}

	public int createDepthOfFieldEffect() {
		if (m_mainCamera == null) {
			return -1;
		}

		eSkyPlayerCameraEffectDepthOfField depthOfField = new eSkyPlayerCameraEffectDepthOfField (this);
		int index = getNewEffectIndex ();
		m_effects.Add (index, depthOfField);
		return index;
	}

	public int createChromaticAberrationEffect() {
		if (m_mainCamera == null) {
			return -1;
		}

		eSkyPlayerCameraEffectChromaticAberration chromaticAberration = new eSkyPlayerCameraEffectChromaticAberration (this);
		int index = getNewEffectIndex ();
		m_effects.Add (index, chromaticAberration);
		return index;
	}

	public int createVignetteEffect() {
		if (m_mainCamera == null) {
			return -1;
		}

		eSkyPlayerCameraEffectVignette vignette = new eSkyPlayerCameraEffectVignette (this);
		int index = getNewEffectIndex ();
		m_effects.Add (index, vignette);
		return index;
	}


	public int createCrossFadeEffect(float duration) {
		if (m_mainCamera == null) {
			return -1;
		}

		eSkyPlayerCameraEffectTransitions effect = new eSkyPlayerCameraEffectTransitions (this);
		effect.duration = duration;

		int index = getNewEffectIndex ();
		m_effects.Add (index, effect);
		return index;
	}

	public int createScreenOverlayEffect() {
		if (m_mainCamera == null) {
			return -1;
		}

		eSkyPlayerCameraEffectScreenOverlay effect = new eSkyPlayerCameraEffectScreenOverlay (this);
		int index = getNewEffectIndex ();
		m_effects.Add (index, effect);
		return index;
	}

	// common operations
	public bool start(int effectId) {
		var effect = getEffectObjectById (effectId);
		if (effect == null) {
			return false;
		}
			
		effect.start ();
		return true;
	}

	public bool destroy(int effectId) {
		var effect = getEffectObjectById (effectId);
		if (effect == null) {
			return false;
		}
		m_effects.Remove (effectId);
		return effect.destroy ();
	}

	public bool pause (int effectId) {
		var effect = getEffectObjectById (effectId);
		if (effect == null) {
			return false;
		}

		return effect.pause ();
	}
		
	public bool setParam(int effectId, eSkyPlayerCameraEffectParamBase param) {
		var effect = getEffectObjectById (effectId);
		if (effect == null) {
			return false;
		}

		return effect.setParam (param);
	}

	public eSkyPlayerCameraEffectParamBase getParam(int effectId) {
		var effect = getEffectObjectById (effectId);
		if (effect == null) {
			return null;
		}

		return effect.getParam ();
	}
}
