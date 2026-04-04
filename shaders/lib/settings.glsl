#if !defined(SETTINGS_GLSL)
#define SETTINGS_GLSL

#define RENDER_CLOUDS // Whether to render clouds

#define SCALE_NORM 0
#define SCALE_FULL 1
#define NORMAL_SCALE SCALE_NORM // Scale of the displayed normal vectors [SCALE_FULL SCALE_NORM]

#define ARMOR_MODE_NORMALS 0
#define ARMOR_MODE_TEXTURE 1
#define ARMOR_MODE_FLAT 2
#define ARMOR_COLOR_MODE ARMOR_MODE_NORMALS // Armor rendering mode [ARMOR_MODE_NORMALS ARMOR_MODE_TEXTURE ARMOR_MODE_FLAT]

#endif // SETTINGS_GLSL