---
name: context-and-decisions
description: Protocol for updating context.md, README.md, and CHANGELOG.md with quality-gated, architecture-level content only. Prevents implementation bloat in all project documentation.
---

# Context & Decisions Skill

Execute this skill whenever a major architectural decision is made, a new core library is integrated, the project phase changes, or any project documentation file needs updating.

---

## ⛔ STEP 0 — Quality Classifier (Run Before Every Write)

Before writing a single word to any documentation file, classify each piece of information through the three filters below. **Reject anything that fails.**

### Filter 1 — WHY vs WHAT Test
Ask: *Does this explain a technology choice or trade-off (WHY), or does it describe implementation mechanics (WHAT)?*

| ✅ INCLUDE (WHY) | ❌ REJECT (WHAT) |
|---|---|
| "Chose Provider over Riverpod for lower boilerplate" | "Using `Consumer<TaskProvider>` with `_disposed` bool" |
| "Firestore offline cache avoids duplicate task Hive boxes" | "`HiveType(typeId: 1)` with `@HiveField(0..12)`" |
| "Enforced 3-tier viewport breakpoints for tablet scaling" | "38% left pane, 62% right pane split" |
| "Adaptive layout across Phone/Tablet/Desktop" | "3-page `PageView.builder` with `NestedScrollView`" |

### Filter 2 — Stability Test
Ask: *Is this information stable over months, or will it change with the next sprint?*

| ✅ INCLUDE (Stable) | ❌ REJECT (Volatile) |
|---|---|
| "Firebase Auth + email verification gate app access" | "Current task: fixing button padding on Tuesday" |
| "Saved credentials stored in `flutter_secure_storage`" | "Hardcoded local Firebase project IDs or keys" |
| "Timezone-aware local notifications via `NotificationService`" | "Debug print token strings or build paths" |

### Filter 3 — Audience Test
Ask: *Does this help a developer understand the architecture, or does it teach them general OS/framework history?*

| ✅ INCLUDE | ❌ REJECT |
|---|---|
| "Battery optimization exemption link in Settings" | "Android Doze mode was introduced in Marshmallow because…" |
| "Private Firebase configs stay untracked in `.gitignore`" | "How Git ignore matching algorithms work" |

---

## Step 1 — Read Before Writing

1. Locate and read the target file (`context.md`, `README.md`, or `CHANGELOG.md`) in full.
2. If `context.md` does not exist, create it using the template: Stack & Architecture table → Folder Structure table → Key Decisions table → Current Focus list.
3. Never overwrite content that is still accurate. Only append or prune.

---

## Step 2 — Per-Document Writing Rules

### `context.md` Rules
- **Allowed**: Technology name, the alternative rejected, the rationale in one sentence.
- **Forbidden**: Widget class names, pixel values (`380dp`, `44dp`), layout percentages (`38/62`), drawing details, and any code that belongs in source comments.
- **Format**: New decisions go in the Key Decisions table as `YYYY-MM | Decision title | One-sentence rationale`.
- **Length gate**: File must stay **strictly under 150 lines**. If adding a row would exceed the limit, prune the oldest "Current Focus" item or merge two related decisions into one row first.

### `CHANGELOG.md` Rules
- Follow Keep-a-Changelog format: `## [version] - YYYY-MM-DD` with `Added / Changed / Fixed / Removed` subsections.
- **Fixed entries must describe user-visible behaviour**, not code mechanics.
  - ❌ `Fixed _disposed check in TaskProvider.notifyListeners()` → ✅ `Fixed crash when task updates arrive after leaving the screen`
  - ❌ `Resolved NestedScrollView outer-extent physics` → ✅ `Eliminated empty scroll space on mobile boundaries`
- **No code variable names, class names, or method names** in any changelog bullet.
- **No pixel math or exact layout ratios** in changelog bullets (`38% left pane`, `380dp max-width`).
- **No GitHub release artifact prose** (`Assets Included Below: Please download the APK`). Link to the GitHub Releases page instead.

### `README.md` Rules
- **No real credentials or private config values** (only placeholder schemas like `YOUR_ANDROID_MAPS_KEY`).
- **No tutorial or Q&A sections** teaching OS history — keep concise behavioral notes (like battery optimization caveats) and link to official docs when needed.
- **No duplicate feature sections.** Each capability belongs once in its best section.
- **No widget-tree-level detail in architecture sections.**

---

## Step 3 — Prune & Format

1. After writing, re-read the full file and apply Filter 1–3 again to the final output.
2. Remove any "Current Focus" items in `context.md` older than the active sprint.
3. Run a final length check on `context.md` — must remain under 150 lines.
4. Confirm no code variable names, sensitive data, or OS tutorial content survived the edit.

---

## Step 4 — Report

Output a brief summary table:

| Document | Action | Lines Added | Lines Removed | Quality Issues Rejected |
|---|---|---|---|---|
| `context.md` | Appended 1 decision | 1 | 0 | 2 (pixel math, widget names) |
