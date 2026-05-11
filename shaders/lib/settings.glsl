#if !defined(SETTINGS_GLSL)
#define SETTINGS_GLSL

#define RENDER_CLOUDS // Whether to render clouds

#define MODE_RGB 0
#define MODE_CMY 1
#define MODE_FLAT 2

#define ARMOR_COLOR_MODE MODE_RGB // Armor rendering mode [MODE_RGB MODE_CMY MODE_FLAT]
#define SKIN_LAYER1_MODE MODE_CMY // First skin layer rendering mode [MODE_RGB MODE_CMY MODE_FLAT]
#define SKIN_LAYER2_MODE MODE_CMY // Second skin layer rendering mode [MODE_RGB MODE_CMY MODE_FLAT]
#define SKIN_LAYER2_INVERT 1 // [0 1] Invert second skin layer colors
#define SKIN_LAYER2_DEBUG 0 // [0 1] Paint detected second skin layer magenta

#endif // SETTINGS_GLSL
