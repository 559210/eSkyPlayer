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
        CHARACTER = 11,
        ADDON = 12,
        AVATAR_PART = 13,
        TWO_D_OBJECT = 14,
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
        CHARACTER = 17,
        ADDON = 18,
        AVATAR_PART = 19,
        TWO_D_OBJECT = 20,
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
        ROLE = 8,
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

    EDITOR_RES_TYPE = {
        PLAN = 0,
        PROJECT = 1,
        EVENT = 2,
        MUSICS = 3,
        MOTIONS = 4,
        SCENES = 5, 
        SCENE_ELEMENTS = 6,
        TEXTURES = 7,
        PLAYERS = 8,
        CAMERA_MOTIONS = 9,
        MORPH = 10,
        SCENE_LABELS = 11,
        ROLE = 12,
        MUSICS_CONFIG = 13,
        SCENE_CONFIGS = 14,
        MORPH_CURVE_COMFIG = 15,
        EFFECT = 16,
        AVATAR_PART = 17,
        DEFAULT_CONFIG = 18,
        TWO_D_OBJECT_TYPE = 19,
        FEMALE_ROLE = 20,
        MALE_ROLE = 21,
        AVATAR_ROLE = 22,
        CAMERA = 23,
    };

    SKY_EDITOR_RES_TYPE_ROLE_TYPE_RELATION = {
    --     [EDITOR_RES_TYPE.FEMALE_ROLE] = {roleType = SkyRoleType.People, gender = SexEnum.FEMALE},
    --     [EDITOR_RES_TYPE.MALE_ROLE] = {roleType = SkyRoleType.People, gender = SexEnum.MALE},
    --     [EDITOR_RES_TYPE.AVATAR_ROLE] = {roleType = SkyRoleType.Avatar, gender = SexEnum.BOTH},
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
        EVENT_WAIT_ADD = 2, --等待event结束后添加
        EVENT_REPLACEMORE_ADD = 3,--替换添加多个
        EVENT_REPLACEONE_ADD = 4,--替换1个
    };

    EVENT_PLAYER_STATE = {
        EVENT_START = 1,
        EVENT_UPDATE = 2,
        EVENT_END = 3,
    };

    AVATAR_URL = {
        [AvatarResourceType.PREFAB]= "avatars/prefabs/",
        [AvatarResourceType.TEXTURE] = "avatars/textures/",
        [AvatarResourceType.EFFECT]= "avatars/prefabs/"
    };

    RESOURCE_TYPE = {
        DEFAULT = 1,
        UI = 2,
    };

}

definations.SKY_EDITOR_RES_TYPE_ROLE_TYPE_RELATION[definations.EDITOR_RES_TYPE.FEMALE_ROLE] = {roleType = SkyRoleType.People, gender = SexEnum.FEMALE};
definations.SKY_EDITOR_RES_TYPE_ROLE_TYPE_RELATION[definations.EDITOR_RES_TYPE.MALE_ROLE] = {roleType = SkyRoleType.People, gender = SexEnum.MALE};
definations.SKY_EDITOR_RES_TYPE_ROLE_TYPE_RELATION[definations.EDITOR_RES_TYPE.AVATAR_ROLE] = {roleType = SkyRoleType.Avatar, gender = SexEnum.BOTH};

return definations;