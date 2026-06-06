# Harvest Haven

A farming and exploration simulator developed in **Godot 4.7 beta 4**.

## Project Status
The project is fully functional with a stable game loop, data-driven systems, and procedural content.

## Key Features Implemented

### 1. Farming & Agriculture
- **Area-Based Mechanics:** Tools (Hoe, Axe, Sword, Pickaxe, Watering Can) interact with a **3x3 grid** centered on the target.
- **Tree System:** Fruit seeds can be planted anywhere; they grow into fruit trees. Fruits are color-mapped to seed types and use dedicated icon assets.
- **Area Highlights:** Visual grid-based highlight system for interaction areas.

### 2. Fishing System
- **Data-Driven Species:** Fishing mechanic uses `FISH_DATA` (rarity, difficulty, specific icon mapping) rather than generic items. Includes freshwater and coastal American species (Sunfish, Crappie, Bass, Pike, Muskie, Catfish, Carp).

### 3. Mining & Procedural Spawning
- **Mining Objects:** Rocks and gems spawn daily via a global probability system defined in `Data.gd`.
- **Harvest Mechanics:** Mining requires 3 hits; drops are randomized based on the ore type (Stone, Gold, Silver, Gems).

### 4. Inventory & UI
- **Expanded Inventory:** Accessible via **`I`**. Includes tabs for General Items, Ores, and Seeds.
- **Direct Seed Selection:** Clicking a seed in the Inventory UI sets it as the active item.
- **Dynamic Icons:** Procedural and file-based icon resolution for all items, with specific mappings for all fish and ore types.
- **Debug Console:** Toggle via **`'`** (apostrophe) for testing commands (`set_stamina`).

### 5. Persistence
- **JSON Save/Load:** Automatically saves state, inventory, and farm layout on day transition.
- **New Game Reset:** Clear progress, stats, and delete existing save files via the main menu.
