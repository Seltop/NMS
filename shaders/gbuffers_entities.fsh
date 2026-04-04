#version 330 compatibility

#include "/lib/settings.glsl"

uniform sampler2D gtexture;
uniform float alphaTestRef = 0.1;

in vec2 texCoord;
in vec3 normal;
in vec4 vertColor;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

// Overlay regions of the standard 64x64 Minecraft skin layout.
//
//   V [0.00, 0.25]: U [0.00, 0.50) = head base
//                    U [0.50, 1.00] = hat overlay
//
//   V [0.25, 0.50]: right-leg base, body base, right-arm base (no overlays)
//
//   V [0.50, 0.75]: right-leg overlay, jacket overlay, right-arm overlay
//                    (entire row is overlay)
//
//   V [0.75, 1.00]: U [0.00, 0.25) = left-leg overlay
//                    U [0.25, 0.50) = left-leg base
//                    U [0.50, 0.75) = left-arm base
//                    U [0.75, 1.00] = left-arm overlay
bool isOverlayRegion(vec2 uv) {
	// Hat overlay
	if (uv.y < 0.25 && uv.x >= 0.5) return true;
	// Right leg, jacket, right arm overlays
	if (uv.y >= 0.5 && uv.y < 0.75) return true;
	// Left leg overlay
	if (uv.y >= 0.75 && uv.x < 0.25) return true;
	// Left arm overlay
	if (uv.y >= 0.75 && uv.x >= 0.75) return true;
	return false;
}

// Per-face brightness based on the world-space normal direction.
// Each dominant axis/sign gets a distinct multiplier so that adjacent
// faces of the same limb or body part are visually separable.
float faceBrightness(vec3 n) {
	vec3 a = abs(n);
	if (a.y >= a.x && a.y >= a.z) {
		return n.y > 0.0 ? 1.10 : 0.80;   // top / bottom
	} else if (a.x >= a.z) {
		return n.x > 0.0 ? 0.95 : 0.85;   // east / west
	} else {
		return n.z > 0.0 ? 1.00 : 0.90;   // south / north
	}
}

void main() {
	vec4 baseColor = texture(gtexture, texCoord);
	if (baseColor.a < alphaTestRef) {
		discard;
	}

	float brightness = faceBrightness(normal);

	// --- armour detection via texture aspect ratio (64x32 = 2:1) ---------
	ivec2 texSize = textureSize(gtexture, 0);
	bool isArmor = (texSize.x == texSize.y * 2);

	if (isArmor) {
		#if ARMOR_COLOR_MODE == MODE_RGB
			color = vec4(max(normal, 0.0), 1.0);
		#elif ARMOR_COLOR_MODE == MODE_CMY
			color = vec4(normal * 0.5 + 0.5, 1.0);
		#else // MODE_FLAT
			color = vec4(0.5, 0.5, 0.5, 1.0);
		#endif
		return;
	}

	// --- overlay detection (skin-format 64x64 textures) ------------------
	bool isSkinFormat = (texSize.x == texSize.y);
	bool overlay = isSkinFormat && isOverlayRegion(texCoord);

	if (overlay) {
		#if SKIN_LAYER2_MODE == MODE_FLAT
			color = vec4(0.5, 0.5, 0.5, 1.0);
		#else
			#if SKIN_LAYER2_MODE == MODE_RGB
				vec3 skin2 = max(normal, 0.0);
			#else // MODE_CMY
				vec3 skin2 = normal * 0.5 + 0.5;
			#endif
			#ifdef SKIN_LAYER2_INVERT
				color = vec4((1.0 - skin2) * brightness, 1.0);
			#else
				color = vec4(skin2 * brightness, 1.0);
			#endif
		#endif
	} else {
		#if SKIN_LAYER1_MODE == MODE_RGB
			color = vec4(max(normal, 0.0) * brightness, 1.0);
		#elif SKIN_LAYER1_MODE == MODE_CMY
			color = vec4((normal * 0.5 + 0.5) * brightness, 1.0);
		#else // MODE_FLAT
			color = vec4(0.5, 0.5, 0.5, 1.0);
		#endif
	}
}
