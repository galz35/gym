# Maintenance & Production Plan — GymPro

## Objective
Finalize the codebase, resolve all lint errors, prepare the backend for Render deployment, and generate the release APK.

---

## 🛠 Phase 1: Flutter Code Cleanup (Lint Fixes)
- [ ] Fix Null-aware markers `?` in Providers (`auth`, `inventario`, `sucursal`, `usuario`).
- [ ] Fix `BuildContext` across async gaps in feature screens (`clientes`, `membresias`, `planes`).
- [ ] Replace deprecated `value` with `initialValue` in `TextFormField` widgets.
- [ ] Enclose `if` statements in blocks as per Dart style guide.
- [ ] Remove unnecessary `toList()` and string interpolations.
- [ ] Address remaining TODOs in `CajaScreen`.

## ⚙️ Phase 2: Backend Production & Keep-Alive
- [ ] **Database Schema**: Add `SistemaStatus` table (1 record: `activo = true`).
- [ ] **Infrastructure**: Create `HealthController` to query `SistemaStatus`.
- [ ] **Security**: Configure CORS in `main.ts` to allow requests from any origin (or specific production domains).
- [ ] **Deployment**: Review `package.json` scripts (`start`, `build`, `start:prod`).
- [ ] **Maintenance**: Plan for `cron-job.org` (ping every 10 mins).

## 📦 Phase 3: Build & Release
- [ ] **Flutter**: Run `flutter build apk --release`.
- [ ] **Git**: Prepare for push to `https://github.com/galz35/gym.git`.
- [ ] **Backend**: Verify environment variables for Render.

## 🕒 Phase 4: Maintenance (Cron-Job)
- [ ] Detailed steps to configure `cron-job.org` hitting `/health/ping`.

---
Status: 🔄 In Progress
