using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class eSkyPlayerCameraEffectManager {

    protected static eSkyPlayerCameraEffectManager _instance = null;
    public static eSkyPlayerCameraEffectManager inst {
        get {
            if (_instance == null)
            {
                _instance = new eSkyPlayerCameraEffectManager();
            }

            return _instance;
        }
    }

//    public 
}
