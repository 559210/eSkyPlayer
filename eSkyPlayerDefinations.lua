local definations = {
    
    TRACK_TYPE = {
        UNKOWN = 0,
        CAMERA_PLAN = 1,
        ROLE_PLAN = 2,
        MUSIC_PLAN = 3,
        SCENE_PLAN = 4,
        CAMERA_MOTION = 5,
        CAMERA_EFFECT = 6,
        SCENE_MOTION = 7,
        SCENE_EFFECT = 8,
        ROLE_MOTION = 9,
        ROLE_MORPH = 10,
    };

    EVENT_TYPE = {
        UNKOWN = 0,
        CAMERA_PLAN = 1,
        ROLE_PLAN = 2,
        MUSIC_PLAN = 3,
        SCENE_PLAN = 4,
        CAMERA_MOTION = 5,
        CAMERA_EFFECT = 6,
        BLOOM = 7,
        BLACK = 8,
        DEPTH_OF_FIELD = 9,
        CROSS_FADE = 10,
        FIELD_OF_VIEW = 11,
        CHROMATIC_ABERRATION = 12,
        VIGNETTE = 13,
        SCENE_MOTION = 14,
        SCENE_EFFECT = 15,
        ROLE_MOTION = 16,
        ROLE_MORPH = 17,
    };

    TRACK_FILE_TYPE = {
        UNKOWN = 0,
        MOTION = 1,
        MUSIC = 2,
        MOUTH_MOTION = 3,
        MORPH = 4,
        CAMERA = 5,
        SCENE = 6,
        CAMERA_MOTION = 7,
        FEMALE_ROLE = 8,
        MALE_ROLE = 9,
        EFFECT = 10,
        AVATAR_PART = 11,
        TWO_D_OBJECT = 12,
    };

    CAMERA_EFFECT_TYPE = {
        UNKNOW = 0,
        BLOOM = 1,
        BLACK = 2,
        DEPTH_OF_FIELD = 3,
        CROSS_FADE = 4,
        FIELD_OF_VIEW = 5,
        CHROMATIC_ABERRATION = 6,
        USER_LUT = 7,
        VIGNETTE = 8,
    };

    MANAGER_TACTIC_TYPE = {
        NO_NEED = 0,
        LOAD_INITIALLY_RELEASE_LASTLY = 1,
        LOAD_INITIALLY_SYNC_RELEASE_LASTLY = 2,
        LOAD_IMMEDIATELY_RELEASE_IMMEDIATELY = 3,
        LOAD_IMMEDIATELY_SYNC_RELEASE_IMMEDIATELY = 4,
    };

    PLAY_STATE = {
        NORMAL = 0, --就绪
        PLAY = 1,--开始播放
        PLAYING = 2,--播放中
        PLAYEND = 3 --播放结束
    };
}

return definations;