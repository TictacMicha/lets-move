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

## 6. Implementasi Fitur

### Sprint Button (`src/client/UI/SprintButton.client.luau`)
- **Style**: Liquid glass, persegi (100×100), UICorner radius 12, UIGradient putih-biru, transparency 70%
- **Animasi**: Pulse effect, press feedback shrink, drag smooth via `UserInputService.InputChanged`
- **Interaksi**: Toggle sprint speed 16↔32, warna berubah dari putih ke orange saat sprint aktif
- **Struktur**: ScreenGui → TextButton

### Graphics Quality Popup (`src/client/UI/GraphicsQuality.client.luau`)
- **Style**: Liquid glass Apple — UIGradient + UIStroke + transparency berlapis pada card dan tombol
- **Pilihan**: LOW / MEDIUM / HIGH dengan icon, label, deskripsi
- **Animasi**: Spring bounce in/out via TweenService, selected state highlight biru
- **Responsive**: UIScale auto-adjust berdasarkan ViewportSize, clamp 55%–100%
- **Struktur**: ScreenGui → overlay Frame → card Frame → tombol

**`applyGraphicsQuality` — cara yang benar:**
- `settings().Rendering.QualityLevel` dan `UserGameSettings.SavedQualityLevel` **tidak bisa diubah dari LocalScript** — diproteksi engine Roblox
- Solusi: ubah properti secara manual:
  - `Lighting.GlobalShadows` — matikan/nyalakan bayangan
  - `Terrain.Decoration` — matikan/nyalakan rumput 3D
  - `Terrain.WaterWaveSize` / `Terrain.WaterReflectance` — kualitas air

### Box Pickup & Carry System (`src/client/UI/PickupSystem.client.luau`)
- **Deteksi**: Raycast dari crosshair tengah layar (max 15 studs) menuju part bernama `box`
- **UI Prompt**: Liquid glass prompt "E — Pick Up" dan "E — Drop" dengan anim in/out
- **Fisika Carry**:
  - `AlignPosition` + `AlignOrientation` mode `OneAttachment` untuk stabilitas
  - `NoCollisionConstraint` dengan karakter saat digendong agar tidak terjadi fling/terbang
  - Delay & inersia berat (`Responsiveness = 12`, `MaxVelocity = 22`)
  - Dynamic Sagging: box melorot kebawah seiring kecepatan berjalan
  - Slowdown: `WalkSpeed` berkurang 30% saat menggendong
  - Non-bouncing: `CustomPhysicalProperties` (`Elasticity = 0`, `Density = 3.5`, `Friction = 0.9`)

---

## 7. Catatan Dev Penting (Roblox Luau)

- Rojo convention: `.client.luau` = LocalScript, `.server.luau` = Script, `.luau` = ModuleScript
- Semua UI wajib dibungkus `ScreenGui` dulu, baru parent ke `PlayerGui`
- `button.Draggable` tidak ada — harus custom drag logic
- Drag gunakan `UserInputService.InputChanged` bukan `button.InputChanged` agar smooth saat kursor keluar frame
- Jangan pakai `rojo build` atau buat `.rbxlx` — pakai live sync `rojo serve` via plugin Roblox Studio
- Port default `34872`, alternatif `34873` jika bentrok
