#version 330 core

#include "/lib/settings.glsl"

uniform sampler2D gtexture;
uniform float alphaTestRef;
uniform int entityId;
uniform int currentRenderedItemId;

in vec2 texCoord;
in vec3 normal;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

bool isOverlayRegion(vec2 uv) {
	if (uv.y < 0.25 && uv.x >= 0.5) return true;
	if (uv.y >= 0.5 && uv.y < 0.75) return true;
	if (uv.y >= 0.75 && uv.x < 0.25) return true;
	if (uv.y >= 0.75 && uv.x >= 0.75) return true;
	return false;
}

float faceBrightness(vec3 n) {
	vec3 a = abs(n);
	if (a.y >= a.x && a.y >= a.z) {
		return n.y > 0.0 ? 1.10 : 0.80;
	} else if (a.x >= a.z) {
		return n.x > 0.0 ? 0.95 : 0.85;
	} else {
		return n.z > 0.0 ? 1.00 : 0.90;
	}
}

void main() {
	vec4 baseColor = texture(gtexture, texCoord);
	if (baseColor.a < max(alphaTestRef, 0.001)) {
		discard;
	}

	if (baseColor.r + baseColor.g + baseColor.b < 0.02) {
		discard;
	}

	float brightness = faceBrightness(normal);

	ivec2 texSize = textureSize(gtexture, 0);
	bool mappedArmorItem = (currentRenderedItemId >= 2 && currentRenderedItemId <= 6);
	bool unmappedItemDraw = (currentRenderedItemId <= 0 || currentRenderedItemId == 65535);
	bool playerArmorTexture = (entityId == 101 && texSize.x == texSize.y * 2);
	bool isArmor = mappedArmorItem || (unmappedItemDraw && playerArmorTexture);

	if (isArmor) {
		#if ARMOR_COLOR_MODE == MODE_RGB
			color = vec4(max(normal, 0.0), 1.0);
		#elif ARMOR_COLOR_MODE == MODE_CMY
			color = vec4(normal * 0.5 + 0.5, 1.0);
		#else
			color = vec4(0.5, 0.5, 0.5, 1.0);
		#endif
		return;
	}

	bool overlay = (entityId == 101) && isOverlayRegion(texCoord);

	if (overlay) {
		#if SKIN_LAYER2_DEBUG == 1
			color = vec4(1.0, 0.0, 1.0, 1.0);
			return;
		#endif

		#if SKIN_LAYER2_MODE == MODE_FLAT
			color = vec4(0.5, 0.5, 0.5, 1.0);
		#else
			#if SKIN_LAYER2_MODE == MODE_RGB
				vec3 skin2 = max(normal, 0.0);
			#else
				vec3 skin2 = normal * 0.5 + 0.5;
			#endif
			#if SKIN_LAYER2_INVERT == 1
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
		#else
			color = vec4(0.5, 0.5, 0.5, 1.0);
		#endif
	}
}
