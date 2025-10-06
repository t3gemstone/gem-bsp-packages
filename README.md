# GEM BSP Packages

Debian packaging repository for GEM Board Support Package (BSP) files. This repository builds and distributes bootloader and device tree files for embedded Linux boards as installable DEB packages.

## Supported Boards

| Board | Package Name | SoC |
|-------|-------------|-----|
| T3 GEM O1 | `gem-t3-gem-o1-bsp` | TI AM67A |
| BeagleY-AI | `gem-beagley-ai-bsp` | TI AM67A |

### What's Included

Each BSP package contains:
- TI boot firmware (`tiboot3.bin`)
- Device tree blob(s) (`*.dtb`)
- Device tree overlays (`*.dtbo`)

All files are installed to `/boot/`.

## Building Packages

### Prerequisites

- Debian-based system with `debhelper`, `devscripts`, `build-essential`
- Access to Yocto build artifacts
- Git repository checkout

Install build dependencies:
```bash
sudo apt install debhelper devscripts build-essential fakeroot
```

### Local Build

1. **Update the changelog for your board:**
   ```bash
   cd t3-gem-o1/

   # Create a new version entry with proper format
   DEBFULLNAME="Gemstone Dev Team" \
   DEBEMAIL="dev@t3gemstone.org" \
   dch -v "1.0.0-1" "Initial release"

   # Add U-Boot version info
   dch -a "U-Boot version: edf35564dddfda461567771082cf61a95c870d87"

   # Mark as released (finalizes the entry)
   dch -D unstable -r ""
   ```

   Example result:
   ```
   gem-t3-gem-o1-bsp (1.0.0-1) unstable; urgency=medium

     * Initial release
     * U-Boot version: edf35564dddfda461567771082cf61a95c870d87

    -- Gemstone Dev Team <dev@t3gemstone.org>  Fri, 04 Oct 2025 10:40:35 +0300
   ```

2. **Place Yocto artifacts in the board directory:**
   ```bash
   <board-name>/
   ├── tiboot3.bin
   ├── k3-am67a-<board-name>.dtb
   └── *.dtbo
   ```

3. **Build using the helper script:**
   ```bash
   ./scripts/build-board-deb.sh <board-name>
   ```

4. **Install the built package:**
   ```bash
   sudo dpkg -i ../gem-<board-name>-bsp_*.deb
   ```

### GitHub Actions Build

Packages are built automatically via GitHub Actions workflows.

**Prerequisites:**
- Yocto build artifacts stored in `t3gemstone/sdk` repository
- Workflow run ID from the Yocto build

**Steps:**

1. **Update the changelog and push:**
   ```bash
   cd t3-gem-o1/

   # Set maintainer info
   DEBFULLNAME="Gemstone Dev Team" \
   DEBEMAIL="dev@t3gemstone.org" \
   dch -v "1.0.1-1" "Update bootloader"

   # Add version details
   dch -a "U-Boot version: <commit-hash>"

   # Finalize
   dch -D unstable -r ""

   # Commit and push
   git add debian/changelog
   git commit -m "Bump T3-GEM-O1 BSP to 1.0.1-1"
   git push
   ```

2. **Trigger the workflow:**
   - Go to Actions → Select workflow
   - Click "Run workflow"
   - Enter the Yocto workflow run ID
   - The version will be read automatically from `debian/changelog`

3. **Download the package:**
   - Check the workflow run artifacts
   - Or download from the created release

### Finding Yocto Run ID

```bash
# List recent workflow runs in your Yocto repository
gh run list --repo t3gemstone/sdk --limit 10

# Get the run ID (first column)
# Example output:
# STATUS  TITLE           WORKFLOW     BRANCH  EVENT    ID          ELAPSED  AGE
# ✓       Yocto Build     Build        main    push     1234567890  45m      2h
```

Use the ID (`1234567890`) as input to the DEB build workflow.

### Changelog Format

Follow Debian changelog format with version format `MAJOR.MINOR.PATCH-REVISION`:
```
gem-t3-gem-o1-bsp (1.0.0-1) unstable; urgency=medium

  * Initial release
  * U-Boot version: edf35564dddfda461567771082cf61a95c870d87

 -- Gemstone Dev Team <dev@t3gemstone.org>  Fri, 04 Oct 2025 10:40:35 +0300
```

**Version Format:**
- `1.0.0` - Semantic version (MAJOR.MINOR.PATCH)
- `-1` - Debian revision (increment for packaging changes with same upstream version)

**Versioning Rules:**

1. **When binaries change** (new bootloader, new firmware, etc.):
   - Increment semantic version: `1.0.0` → `1.1.0` or `1.0.1`
   - Reset Debian revision to `-1`: `1.1.0-1`
   - Example: `1.0.0-3` → `1.1.0-1` (new bootloader)

2. **When only packaging changes** (debian/ files modified, same binaries):
   - Keep semantic version unchanged
   - Increment Debian revision: `-1` → `-2` → `-3`
   - Example: `1.0.0-1` → `1.0.0-2` (fixed package description)

### Binary Files in Git

**IMPORTANT:** Do not commit binary files to this repository!

The following files should NEVER be committed:
- `*.img`, `*.bin`
- `*.dtb`, `*.dtbo`
- `*.deb` packages
- Build artifacts

These are excluded by `.gitignore` and should only exist temporarily during builds.
