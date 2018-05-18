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
        CAMERA_EFFECT_BLOOM = 6,
        CAMERA_EFFECT_BLACK = 7,
        CAMERA_EFFECT_DEPTH_OF_FIELD = 8,
        CAMERA_EFFECT_CROSS_FADE = 9,
        CAMERA_EFFECT_FIELD_OF_VIEW = 10,
        CAMERA_EFFECT_CHROMATIC_ABERRATION = 11,
        CAMERA_EFFECT_VIGNETTE = 12,
        SCENE_MOTION = 13,
        SCENE_EFFECT = 14,
        ROLE_MOTION = 15,
        ROLE_MORPH = 16,
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
        LOAD_ON_THE_FLY_RELEASE_IMMEDIATELY = 3,
        LOAD_ON_THE_FLY_SYNC_RELEASE_IMMEDIATELY = 4,
    };

    PLAY_STATE = {
        NORMAL = 0, --就绪
        PLAY = 1,--开始播放
        PLAYING = 2,--播放中
        PLAYEND = 3, --播放结束
    };

    EVENT_ADDTYPE = {
        NORMAL = 0, --正常顺序添加
        EVENT_BREAK_ADD = 1,--中断event然后添加
        EVENT_LAST_ADD = 2, --等待event结束后添加
        EVENT_REPLACE_MORE_ADD = 3,--替换添加多个
        EVENT_REPLACE_ONE_ADD = 4,--替换1个
    };

    EVENT_PLAYER_STATE = {
        EVENT_START = 1,
        EVENT_UPDATE = 2,
        EVENT_END = 3,
    };

}

return definations;