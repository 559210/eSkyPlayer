using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class eSkyPlayerCameraEffectParamBase {
}

public interface IeSkyPlayerCameraEffectBase {
    bool create(Camera cam);
    void dispose();
    bool start();
    bool stop();
    bool setParam(eSkyPlayerCameraEffectParamBase param);
    eSkyPlayerCameraEffectParamBase getParam();
}
