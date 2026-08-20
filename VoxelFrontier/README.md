# VOXEL FRONTIER

**Version:** Alpha 0.1.0

A procedurally generated voxel sandbox survival game for Windows PC.

## What Is This Game?

Voxel Frontier is an original first-person voxel sandbox game inspired by the survival crafting genre. Explore procedurally generated worlds, gather resources, craft tools, build structures, survive against creatures, and discover diverse biomes.

**This is NOT Minecraft.** All assets, names, creatures, textures, and systems are original creations.

---

## Current Features (Alpha 0.1.0)

### Implemented
- [x] Procedural terrain generation with multiple biomes
- [x] Chunk-based voxel world with efficient meshing
- [x] First-person movement (walk, sprint, jump, look)
- [x] Block mining and placement
- [x] Basic inventory system with hotbar
- [x] Item drops and collection
- [x] Day/night cycle
- [x] Health and hunger systems
- [x] Basic crafting system
- [x] Tool tiers (wood, stone, iron)
- [x] World save/load system
- [x] Creative and Survival game modes
- [x] Main menu and pause menu
- [x] Settings (video, audio, controls)
- [x] Windows export configuration

### In Progress
- [ ] Creature AI and spawning
- [ ] Combat system
- [ ] Water physics
- [ ] Advanced lighting
- [ ] Audio implementation

### Planned
- [ ] Storage containers
- [ ] Furnace/processing
- [ ] More biomes and blocks
- [ ] Weather system
- [ ] Farming

---

## Controls

| Key | Action |
|-----|--------|
| W | Move Forward |
| A | Move Left |
| S | Move Backward |
| D | Move Right |
| Space | Jump / Fly Up (Creative) |
| Left Shift | Sprint / Fly Down (Creative) |
| Mouse | Look Around |
| Left Click | Mine Block / Attack |
| Right Click | Place Block |
| Mouse Wheel | Change Hotbar Slot |
| 1-9 | Select Hotbar Slot |
| E | Open Inventory |
| Esc | Pause Menu / Release Mouse |
| F3 | Toggle Debug Overlay |
| F5 | Quick Save |

---

## System Requirements

### Minimum
- **OS:** Windows 10 64-bit
- **Processor:** Dual-core 2.0 GHz
- **Memory:** 4 GB RAM
- **Graphics:** DirectX 11 compatible GPU with 2GB VRAM
- **Storage:** 500 MB available space

### Recommended
- **OS:** Windows 10/11 64-bit
- **Processor:** Quad-core 3.0 GHz
- **Memory:** 8 GB RAM
- **Graphics:** DirectX 11 compatible GPU with 4GB VRAM
- **Storage:** 1 GB available space

---

## How to Run

### From Editor (Development)
1. Install Godot 4.x from https://godotengine.org
2. Open the project in Godot
3. Press F5 or click the Play button

### From Build (Windows)
1. Download `VoxelFrontier-Windows-x64.zip`
2. Extract the ZIP file
3. Navigate to the extracted folder
4. Double-click `VoxelFrontier.exe`
5. Play!

---

## Building for Windows

See `BUILD_WINDOWS.md` for detailed build instructions.

Quick start:
```powershell
# Run the build script
.\build_windows.ps1

# Package into ZIP
.\package_windows.ps1
```

---

## Save File Location

World saves are stored in:
```
%APPDATA%\VoxelFrontier\worlds\
```

Settings are stored in:
```
%APPDATA%\VoxelFrontier\settings\
```

Logs are stored in:
```
%APPDATA%\VoxelFrontier\logs\
```

---

## Known Limitations

- Water flow is basic (no complex fluid simulation)
- Creature AI is simple state-based behavior
- Lighting uses basic propagation (not full global illumination)
- Some block types may have placeholder textures
- Audio uses placeholder sounds in alpha

---

## Troubleshooting

### Game Won't Start
- Ensure you have Windows 10/11 64-bit
- Check that your GPU supports DirectX 11
- Try running as Administrator
- Check logs in `%APPDATA%\VoxelFrontier\logs\`

### Low FPS
- Reduce render distance in Settings → Video
- Lower graphics quality
- Close other applications

### World Not Saving
- Ensure you have write permissions
- Check disk space
- Look for error messages in logs

### Corrupted World
- Backup worlds regularly
- Don't force-close the game during save
- Use "Save World" before quitting

---

## Architecture Overview

```
VoxelFrontier/
├── assets/          # Textures, audio, fonts
├── scenes/          # Godot scene files
├── scripts/         # Game logic code
│   ├── core/        # Core systems (game manager, events)
│   ├── world/       # Voxel world, chunks, blocks
│   ├── generation/  # Terrain generation, noise
│   ├── player/      # Player controller, camera
│   ├── inventory/   # Inventory, items, crafting
│   ├── entities/    # Creatures, AI
│   └── saving/      # Save/load systems
├── shaders/         # Custom shaders
├── data/            # JSON data files
│   ├── blocks/      # Block definitions
│   ├── items/       # Item definitions
│   ├── recipes/     # Crafting recipes
│   └── biomes/      # Biome configurations
└── builds/          # Build outputs
```

---

## Adding Content

### Adding a New Block
1. Create a new entry in `data/blocks/blocks.json`
2. Add textures to `assets/textures/blocks/`
3. Register the block ID in the block registry

### Adding a New Recipe
1. Create entry in `data/recipes/recipes.json`
2. Define input items and output
3. Specify crafting station if needed

### Adding a New Biome
1. Create entry in `data/biomes/biomes.json`
2. Define noise parameters
3. Set surface/subsurface blocks
4. Configure vegetation and features

---

## Development Status

See `DEVELOPMENT_STATUS.md` for current development progress.

See `CHANGELOG.md` for version history.

---

## License

This is an original indie game project. All code and assets are created for this project.

---

## Credits

Developed as an original voxel sandbox game project.

---

## Support

For issues, suggestions, or feedback, please refer to the project documentation.
