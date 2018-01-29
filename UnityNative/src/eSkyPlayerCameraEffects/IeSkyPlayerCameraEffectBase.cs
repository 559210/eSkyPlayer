using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class eSkyPlayerCameraEffectParamBase {
}

public interface IeSkyPlayerCameraEffectBase {
//    bool create(Camera cam);
    void dispose();
    bool start();
	bool destroy();
	bool pause ();
    bool setParam(eSkyPlayerCameraEffectParamBase param);
    eSkyPlayerCameraEffectParamBase getParam();
}
