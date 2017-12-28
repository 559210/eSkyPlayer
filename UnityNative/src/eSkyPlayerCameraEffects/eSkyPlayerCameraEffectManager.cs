using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.PostProcessing;



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
	};

	protected Dictionary<ADDITIONAL_COMPONENT_TYPE, ReferenceCountBase> m_additionalComponents = new Dictionary<ADDITIONAL_COMPONENT_TYPE, ReferenceCountBase>();
	protected Dictionary<int, IeSkyPlayerCameraEffectBase> m_effects = new Dictionary<int, IeSkyPlayerCameraEffectBase>();
	protected int m_effectIndexFactory = 0;
	protected Camera m_mainCamera = null;
	protected List<ADDITIONAL_COMPONENT_TYPE> _list = new List<ADDITIONAL_COMPONENT_TYPE>();

	public eSkyPlayerCameraEffectManager() {

	}

	public PostProcessingBehaviour getComponentPostProcessingBehaviour(){
		ADDITIONAL_COMPONENT_TYPE type = ADDITIONAL_COMPONENT_TYPE.POST_PROCESSING_BEHAVIOUR;
		if (m_additionalComponents.ContainsKey (type) == false) {
			PostProcessingBehaviour m_pp = m_mainCamera.gameObject.AddComponent<PostProcessingBehaviour> ();
			m_pp.profile = new PostProcessingProfile ();
//			m_additionalComponents [type] = new AdditionalComponent<PostProcessingBehaviour> (m_pp);
			ReferenceCountBase value = new AdditionalComponent<PostProcessingBehaviour> (m_pp);
			m_additionalComponents.Add(type,value);
		}
		var obj = m_additionalComponents [type] as AdditionalComponent<PostProcessingBehaviour> ;
		return obj.getObject ();
	}

	public void releaseAdditionalComponent(ADDITIONAL_COMPONENT_TYPE type){
		switch(type){
		case eSkyPlayerCameraEffectManager.ADDITIONAL_COMPONENT_TYPE.POST_PROCESSING_BEHAVIOUR:
			{
				if (m_additionalComponents.ContainsKey (eSkyPlayerCameraEffectManager.ADDITIONAL_COMPONENT_TYPE.POST_PROCESSING_BEHAVIOUR) == true) {
					var obj = m_additionalComponents [type] as AdditionalComponent<PostProcessingBehaviour>;
					if (obj.releaseObject () == true)
//						m_additionalComponents [type] = null;
					m_additionalComponents.Remove (type);
				}
				break;
			}
		default:
			break;
		}
	}
		

	public void clear(){
		List<ADDITIONAL_COMPONENT_TYPE> list = new List<ADDITIONAL_COMPONENT_TYPE>();
		foreach (KeyValuePair<ADDITIONAL_COMPONENT_TYPE, ReferenceCountBase> item in m_additionalComponents) {
			var obj = m_additionalComponents [item.Key] as AdditionalComponent<PostProcessingBehaviour>;
			if (obj.releaseObject () == true) {
				list.Add (item.Key);
			}
		}
		foreach (ADDITIONAL_COMPONENT_TYPE type in list) {
			m_additionalComponents.Remove (type);
		}
	}

	public void dispose(){
		if (m_mainCamera != null) {
			m_mainCamera = null;
		}
		m_additionalComponents.Clear ();
//		foreach (KeyValuePair<ADDITIONAL_COMPONENT_TYPE, ReferenceCountBase> item in m_additionalComponents) {
//			Debug.LogError ("111111111111111111");
//			releaseAdditionalComponent (item.Key);
//		}
	}


	public bool initialize(Camera cam) {
		if (cam == null) {
			return false;
		}
		m_mainCamera = cam;

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

	// common operations
	public bool start(int effectId) {
		var effect = getEffectObjectById (effectId);
		if (effect == null) {
			return false;
		}
			
		effect.start ();
//		foreach (KeyValuePair<ADDITIONAL_COMPONENT_TYPE, ReferenceCountBase> item in m_additionalComponents)
//			Debug.LogError ("11111111111111111111111111111");
		return true;
	}

	public bool stop(int effectId) {
		var effect = getEffectObjectById (effectId);
		if (effect == null) {
			return false;
		}
		return effect.stop ();
	}

	public bool pause (int effectId) {
		var effect = getEffectObjectById (effectId);
		if (effect == null) {
			return false;
		}

		return effect.pause ();
	}

//	public bool resume (int effectId) {
//		var effect = getEffectObjectById (effectId);
//		if (effect == null) {
//			return false;
//		}
//
//		return effect.resume ();
//	}

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
