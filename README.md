# Arma 3 Client-Side SQF Utility Addon
An experimental client-side addon developed to explore Arma 3 SQF scripting and execution flow. Tested for performance in high-density multiplayer scenarios (up to 50v50).

### Current Limitations
* Hardcoded keybinds and search logic.
* Requires server configuration with `allowSignatures = 0` (unsigned mod support) and disabled BattlEye due to client-side code loading.

### Planned Features
* Custom GUI for dynamic in-game keybinding.
* Interactive search mechanism configuration.

### Installation & Usage

#### Option 1: Quick Install (Compiled PBO)
1. Download the pre-compiled `.pbo` file from the latest release or root folder.
2. Move the file to your Arma 3 Mods folder (e.g., `@MyAddon/addons/`).
3. Enable the mod in the Arma 3 Launcher.

#### Option 2: Source Files (For Customization)
If you don't have a PBO Manager or want to inspect/modify the SQF scripts directly:
* All uncompressed source files (`config.cpp`, `functions/`, etc.) are available in the `src/` directory of this repository.
* You can modify the scripts and pack them using **PBO Manager**, **Mikero's Tools**, or the official **Arma 3 Tools**.

> **Note:** Ensure target server runs with `allowSignatures = 0` (unsigned mods allowed).

> [!NOTE]
> **Feedback & Contributions Welcome!**
> Feel free to edit, modify, or use this addon however you like. Since I'm still learning Arma 3 SQF scripting, I'd really appreciate any feedback, bug reports, or advice on how to improve the code.

> [!WARNING]
> **Important Note on Recompiling:**
> If you unpack and rebuild the PBO yourself, make sure your PBO Manager sets the prefix to `pp_markers`. If you use a custom prefix, update the script directory path inside `config.cpp` accordingly, otherwise the `execVM` call will fail to locate `init_sys.sqf`.
