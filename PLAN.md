# Fix: Overlay/armor detection incorrectly triggers on non-skin-format entities

## Context
The shader applies RGB/CMY normal-based coloring to all entities. It also detects player skin overlay regions (second skin layer) and armor textures. The bug: overlay detection triggers on ALL entities with square textures, and armor detection triggers on ALL entities with 2:1 textures — causing a patchwork rainbow mess on mobs that don't use the player skin UV layout.

## Approach

### Two-part fix:

**1. Shader: Map vanilla entities in `shaders.properties`**
Vanilla mobs that use the player skin format (64x64, same UV layout) get overlay detection. Others don't. Armor detection (2:1 texture) stays universal since armor textures are always 64x32 regardless of who wears them.

**2. NPC Mod: Register two entity types instead of one**
The mod currently uses `newnpc:newnpc_entity` for all NPCs. Split into:
- `newnpc:player_npc` — player-model NPCs (skin format, gets LAYER1 + LAYER2 + armor)
- `newnpc:mob_npc` — mob-model and custom-model NPCs (LAYER1 only)

The mod already branches these at line 460 (`isPlayerModel()`) in NewNpcRenderer.java.

---

## Shader changes

### [shaders.properties](shaders/shaders.properties)
Add entity ID mappings for all skin-format entities:
```properties
# Player
entityId.101 = minecraft:player

# NPC mod - player model
entityId.102 = newnpc:player_npc

# Vanilla humanoid mobs (skin format - same UV layout as player)
entityId.110 = minecraft:zombie
entityId.111 = minecraft:husk
entityId.112 = minecraft:drowned
entityId.113 = minecraft:zombie_villager
entityId.114 = minecraft:skeleton
entityId.115 = minecraft:stray
entityId.116 = minecraft:wither_skeleton
entityId.117 = minecraft:piglin
entityId.118 = minecraft:piglin_brute
entityId.119 = minecraft:zombified_piglin
```
(List can be expanded as needed)

### [gbuffers_entities.vsh](shaders/gbuffers_entities.vsh)
- Add `in vec4 mc_Entity;` input attribute
- Add `flat out int entityId;` output
- Set `entityId = int(mc_Entity.x);` in main()

### [gbuffers_entities.fsh](shaders/gbuffers_entities.fsh)
- Add `flat in int entityId;` input
- Check if entity is skin-format: `bool isSkinFormat = (entityId >= 101 && entityId <= 119);`
  - This uses a contiguous ID range for easy checking
- Gate overlay detection behind `isSkinFormat`
- Armor detection stays universal (any entity wearing armor gets it)
- Non-skin-format entities get uniform LAYER1 coloring with faceBrightness

### Updated shader logic:
```glsl
// Armor detection — universal (armor texture is always 2:1)
ivec2 texSize = textureSize(gtexture, 0);
bool isArmor = (texSize.x == texSize.y * 2);

if (isArmor) {
    // existing armor coloring...
    return;
}

// Overlay detection — only for skin-format entities
bool isSkinFormat = (entityId >= 101 && entityId <= 119);
bool overlay = isSkinFormat && (texSize.x == texSize.y) && isOverlayRegion(texCoord);

if (overlay) {
    // LAYER2 coloring...
} else {
    // LAYER1 coloring (all entities)...
}
```

---

## NPC Mod changes

### Entity registration (NewNpcMod.java)
Replace the single `newnpc:newnpc_entity` registration with two:
- `newnpc:player_npc` — same dimensions/tracking as current (0.6x1.8)
- `newnpc:mob_npc` — same dimensions/tracking as current (0.6x1.8)

### Renderer (NewNpcRenderer.java)
The mod already branches at line 460 based on `isPlayerModel(data)`:
- `isPlayerModel() == true` → render as `newnpc:player_npc`
- `isPlayerModel() == false` (mob or custom model) → render as `newnpc:mob_npc`

### Entity class
Both types can use the same `NewNpcEntity` class — the type only matters for shader identification.

---

## What changes for each entity type

| Entity | Before (broken) | After (fixed) |
|--------|-----------------|---------------|
| Player | LAYER1 + LAYER2 + armor | LAYER1 + LAYER2 + armor (unchanged) |
| Player-model NPC | LAYER1 + LAYER2 + armor | LAYER1 + LAYER2 + armor (unchanged) |
| Zombie (vanilla) | Wrong patchwork coloring | LAYER1 + LAYER2 + armor (correct) |
| Zombie-model NPC | Wrong patchwork coloring | LAYER1 only |
| Iron golem (vanilla) | Wrong patchwork coloring | LAYER1 only (correct) |
| Golem-model NPC | Wrong patchwork coloring | LAYER1 only (correct) |
| Enderman (vanilla) | Wrong patchwork coloring | LAYER1 only (correct) |
| Custom-model NPC | Wrong patchwork coloring | LAYER1 only (correct) |
| Any entity with armor | Armor detected | Armor detected (unchanged) |

---

## Verification
1. Load shader pack with Iris
2. Player: confirm LAYER1 + LAYER2 overlay detection + armor coloring
3. Player-model NPC: same as player
4. Zombie: confirm LAYER1 + LAYER2 (skin format), armor works if wearing
5. Iron golem: confirm LAYER1 only, no overlay patchwork
6. Golem-model NPC: confirm LAYER1 only
7. Custom-model NPC: confirm LAYER1 only
8. Any entity wearing armor: confirm armor coloring works

## Files to modify
- Shader: `shaders/shaders.properties`, `shaders/gbuffers_entities.vsh`, `shaders/gbuffers_entities.fsh`
- Mod: `NewNpcMod.java` (entity registration), `NewNpcRenderer.java` (use correct entity type)
