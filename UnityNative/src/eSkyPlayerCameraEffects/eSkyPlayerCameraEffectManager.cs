using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class eSkyPlayerCameraEffectManager {
	  
	protected Dictionary<int, IeSkyPlayerCameraEffectBase> m_effects = new Dictionary<int, IeSkyPlayerCameraEffectBase>();
	protected int m_effectIndexFactory = 0;
	protected Camera m_mainCamera = null;

	public eSkyPlayerCameraEffectManager() {
		
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

		eSkyPlayerCameraEffectBloom bloom = new eSkyPlayerCameraEffectBloom ();
		if (!bloom.create (m_mainCamera)) {
			return -1;
		}

		int index = getNewEffectIndex ();
		m_effects.Add (index, bloom);
		return index;
	}


	// common operations
	public bool start(int effectId) {
		var effect = getEffectObjectById (effectId);
		if (effect == null) {
			return false;
		}

		return effect.start ();
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

	public bool resume (int effectId) {
		var effect = getEffectObjectById (effectId);
		if (effect == null) {
			return false;
		}

		return effect.resume ();
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
