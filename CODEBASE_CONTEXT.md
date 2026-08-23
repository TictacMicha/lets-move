# Codebase Context: Let's Move (Roblox Luau Project)

Dokumen ini berisi gambaran umum struktur proyek, arsitektur, dependensi, serta alur kerja AI Agent untuk pengembangan game ini.

---

## 1. Ringkasan Proyek

- **Nama Proyek**: `lets-move`
- **Platform**: Roblox
- **Bahasa**: Luau (`.luau` / `.lua`)
- **Tooling**:
  - **Rojo**: Sinkronisasi file lokal ke Roblox Studio via `default.project.json`.
  - **Wally**: Package manager (`wally.toml`, `wally.lock`).
  - **Rokit**: Toolchain manager (`rokit.toml`).
  - **Selene**: Linter Luau (`selene.toml`).

---

## 2. Struktur Direktori

```text
lets-move/
├── .vscode/             # Konfigurasi editor VSCode
├── Packages/            # Shared & Client dependencies (Wally)
│   ├── Networker.lua
│   └── Promise.lua
├── ServerPackages/      # Server-only dependencies (Wally)
│   └── profileservice.lua
├── src/                 # Source code utama
│   ├── client/          # Code berjalan di StarterPlayerScripts
│   │   └── init.client.luau
│   ├── server/          # Code berjalan di ServerScriptService
│   │   └── init.server.luau
│   └── shared/          # Code berjalan di ReplicatedStorage
│       └── Hello.luau
├── default.project.json # Pemetaan Rojo ke Roblox DataModel
├── wally.toml           # Konfigurasi dependensi Wally
├── sourcemap.json       # Luau LSP / Autocompletion sourcemap
└── CODEBASE_CONTEXT.md  # File konteks ini
```

---

## 3. Pemetaan Rojo (`default.project.json`)

| Path Lokal | Path Roblox DataModel | Deskripsi |
| :--- | :--- | :--- |
| `src/shared` | `ReplicatedStorage.Shared` | Shared modules |
| `Packages` | `ReplicatedStorage.Packages` | Client & Shared packages |
| `src/server` | `ServerScriptService.Server` | Server scripts |
| `ServerPackages` | `ServerScriptService.ServerPackages` | Server-only packages |
| `src/client` | `StarterPlayerScripts.Client` | Client scripts |

---

## 4. Dependensi Utama (Wally)

1. **Promise (`evaera/promise@4.0.0`)**: Penanganan async operation / asynchronous logic.
2. **Networker (`leifstout/networker@0.3.1`)**: Networking / Client-Server Remote Event & Function abstraction.
3. **ProfileService (`firebird702/profileservice@1.1.0`)**: Session locking DataStore manager untuk data pemain di server.

---

## 5. Instruksi Pengembangan AI Agent

### A. UI & Client Logic (`src/client/`)
- Mengurus render ScreenGui, User Input Handling, Camera, Animation, dan Local Effects.
- Komunikasi dengan server wajib melalui `Networker` package.

### B. Game & Server Logic (`src/server/`)
- Mengurus kewenangan server (Authoritative Server), DataStore (`ProfileService`), game loop, validation, dan state management.
- Jangan percaya data dari client (selalu validasi input di server).

### C. Shared Modules (`src/shared/`)
- Berisi utilitas, tipe data (Type definitions), kontanta, dan helper yang dibutuhkan server & client.

### D. Alur Git & Github Otonom
- Bebas melakukan commit dan push secara otonom sesuai perkembangan fitur/task.
- Menggunakan pesan commit yang terstruktur dan jelas (misal: `feat: add player movement controller`, `fix: ui layout alignment`).
- **Tidak perlu rojo build atau membuat .rbxlx** — kita pakai live sync (rojo serve) via plugin di Roblox Studio.
- Port default `34872` bisa dipakai atau alternatif `34873` jika port sudah digunakan.

---

## 6. Implementasi Fitur (Contoh: Sprint Button Liquid Glass)

**File**: `src/client/UI/SprintButton.client.luau`

**Fitur UI Liquid Glass**:
- **Bentuk**: Persegi (100×100) dengan rounded corners (UICorner radius 12)
- **Style**: Liquid glass dengan gradien putih-biru muda (UIGradient), transparency 70%
- **Animasi**: Pulse effect, press feedback shrink, drag dengan smooth tracking via UserInputService
- **Interaksi**: Toggle sprint speed 16↔32, warna berubah dari putih ke orange saat sprint aktif
- **Struktur**: ScreenGui → PlayerGui (wrapper wajib untuk UI di Roblox)

**Catatan Dev**:
- LocalScript `.client.luau` vs ModuleScript `.luau` (Rojo convention)
- TweenService untuk animasi smooth
- Proper cleanup connections saat dragging berakhir
