# Daily Engineering Commands Guide (`COMMANDS_GUIDE.md`)

> A practical guide for developers and AI agents in **Task Tracker** explaining **which command to use, when to use it in daily production work, and why** — with concrete Flutter/Dart technical examples.

---

## 🧭 Quick Decision Matrix: "What do you want to do?"

| Situation / Problem | Recommended Command | What It Does (In 5 Words) |
| :--- | :--- | :--- |
| **"I have a big task and want everything handled end-to-end."** | `/run` | Autonomous end-to-end project manager |
| **"I have a new feature idea or architecture question."** | `/analyze` | Compares trade-offs with pros & cons |
| **"I know what to build, now I need a step-by-step roadmap."** | `/plan` | Detailed phased blueprint before coding |
| **"I want an inspection of flaws, bugs, and UI issues."** | `/code-review` | Non-destructive audit by severity level |
| **"I already know the exact bug; just fix the code directly."** | `/fix` | Fast, surgical targeted code change |
| **"I want to build a feature or fix a bug with unit tests first."** | `/tdd` | Test-first (Red → Green → Refactor) |
| **"My screen looks stretched or broken on tablet/landscape."** | `/adaptive-ui` | Phone, Tablet & Landscape layout fix |
| **"I'm about to push code to GitHub or publish to the Play Store."** | `/security` | Scans for leaked keys, tokens, secrets |
| **"flutter analyze / build_runner failed with red errors."** | `/build-fix` | Surgically resolves compiler/codegen errors |
| **"I want to verify all tests and analysis pass before committing."** | `/verify` | Automated quality & regression gate |
| **"I need to update context.md, README.md, or CHANGELOG.md."** | `/document` | Auto-generates clean project documentation |

---

## 1. 🧑‍✈️ `/run` — The Master Orchestrator

### In Simple Words
Think of `/run` as your **Senior Project Manager**. Instead of running 5 separate commands in order, you tell `/run` your goal. It asks you two quick questions (What to do? Which screens?), then autonomously chains planning, coding, responsive design, testing, and verification from start to finish without you orchestrating each step.

### When to Use in Daily Production
- When starting a major feature and you want the agent to handle the full pipeline.
- When doing a whole-app quality cleanup (bug audit + UI + security in one shot).
- When you're in a hurry and don't want to decide which sub-commands to invoke.

### Technical Example
```
/run
```
> **Prompt Dialogue:**
> *Agent:* "What would you like me to do?"
> *Developer:* `2` *(Implement a New Feature)*
> *Agent:* "What is the target scope?"
> *Developer:* `lib/presentation/screens/task/`
>
> **Result:** The agent reads `context.md` + `AGENTS.md`, loads `flutter-dart.md` + `flutter-firebase.md` + `provider-state.md`, runs the analyzer to inspect `TaskProvider` and `TaskFilterState`, creates a phased plan, implements it with TDD, and runs the full verification loop — producing a **Final Handover Report**.

### What It Asks You (The 2-Question Intake)

> **Question 1 — What to do?** (pick one or combine, e.g. `1 + 5`)
> 1. Audit & Fix Bugs / Crashes
> 2. Implement a New Feature
> 3. UI/UX Redesign & Adaptive Layout
> 4. Holistic Screen Testing (TDD)
> 5. Public GitHub Security & Readiness Audit
>
> **Question 2 — Target Scope?**
> - Specific file: `lib/presentation/screens/task/task_screen.dart`
> - Layer / module: `task`, `auth`, `profile`, `setting`, `notifications`
> - Entire app: `all` *(processes screen-by-screen)*

---

## 2. 🏛️ `/analyze` — The System Architect

### In Simple Words
Think of `/analyze` as a **Senior Architect brainstorm session**. Before anyone writes code, `/analyze` looks at your existing codebase, challenges weak assumptions, and presents **2–3 different ways to solve the problem** — each with concrete Pros, Cons, and a declared winner. It writes **zero production code**.

### When to Use in Daily Production
- Before adding a significant feature that touches multiple layers (`data/` and `presentation/`).
- When unsure whether state belongs in `TaskProvider`, `SharedPreferences`, or `Hive`.
- When evaluating offline sync vs. Firestore offline persistence vs. notification rescheduling strategies.

### Technical Example
```
/analyze Should recurring tasks store recurrence rules in TaskModel (Hive + Firestore) or schedule rolling instances inside NotificationService?
```
> **Result:** The agent outputs an Architectural Report:
> - **Approach A (Recurrence field on `TaskModel` + `build_runner`):** Pros (syncs across devices via Firestore, single source of truth). Cons (requires new `@HiveField` migration and `build_runner` regeneration).
> - **Approach B (Local-only schedule metadata in `SharedPreferences`):** Pros (no Hive schema migration). Cons (lost on device change or reinstall).
> - **Approach C (Separate `RecurrenceRule` Firestore subcollection):** Pros (extensible). Cons (extra read queries and N+1 sync complexity).
>
> *Architect's Recommendation:* Approach A with a nullable `@HiveField` on `TaskModel` so existing binary records deserialize safely and sync cleanly to Firestore.

---

## 3. 📐 `/plan` — The Blueprint Planner

### In Simple Words
Think of `/plan` as the **Construction Blueprint before the first brick is laid**. Once you've approved an architecture decision, `/plan` maps out the exact steps: which files will be created, which Hive `typeId` or `@HiveField` indices to assign, what `ChangeNotifier` / repository contracts look like, and in what order to write tests — before a single line of production code is written.

### When to Use in Daily Production
- Right after `/analyze` selects an approach.
- Before any multi-file feature implementation.
- Before fixing a bug that touches more than 2 files.

### Technical Example
```
/plan Add recurring daily task support to TaskModel, TaskRepository, TaskProvider, and NotificationService.
```
> **Result:** Generates a 5-part implementation plan:
> 1. **Problem & Scope:** Add optional recurrence to `TaskModel` and auto-reschedule on completion. Out of scope: weekly custom day masks.
> 2. **Impact Analysis:** `lib/data/models/task_model.dart` (modify), `lib/data/models/task_model.g.dart` (regenerate), `lib/presentation/providers/task_provider.dart` (modify), `lib/core/services/notification_service.dart` (modify). Requires `build_runner`.
> 3. **Interface Contract:** `@HiveField(13) final bool isRecurring;`, `TaskProvider.completeTask()` schedules next occurrence, typed `StorageFailure` / `TaskFailure` handling via `EffectBus`.
> 4. **TDD Phases:** Phase 1 → `TaskModel` serialization tests. Phase 2 → `TaskRepository` update with fake Firestore. Phase 3 → `TaskProvider` state transition tests. Phase 4 → UI toggle in add/edit task sheet.
> 5. **Verification:** `dart run build_runner build --delete-conflicting-outputs` → `dart format .` → `flutter analyze` → `flutter test`.

---

## 4. 🔍 `/code-review` — The Quality Inspector

### In Simple Words
Think of `/code-review` as a **Thorough Building Inspector**. It reads your code and flags bugs, memory leaks, security holes, and async hazards. It is **100% read-only** — it never modifies your files without permission. Findings are grouped by severity so you know exactly what must be fixed vs. what is optional polish.

### When to Use in Daily Production
- Before every git commit or pull request.
- After completing a feature implementation — catch edge cases you missed.
- When you suspect a memory leak (`ValueNotifier`, `StreamSubscription`, `TabController`) or missing `mounted` check.

### Technical Example
```
/code-review Review lib/presentation/screens/setting/setting_screen.dart and lib/core/services/notification_service.dart
```
> **Result:** Categorized report:
>
> **[CRITICAL]**
> - `setting_screen.dart:142` — `Navigator.pop(context)` called after `await NotificationService.requestNotificationPermissionsIfNeeded()` without checking `if (!context.mounted) return;`.
>
> **[HIGH]**
> - `task_screen.dart:38` — Listener attached to `widget.tabController` in `initState()` must be removed in `dispose()` to avoid leaking callbacks.
>
> **[MEDIUM]**
> - `task_screen.dart:49` — `Consumer<TaskProvider>` wraps a large subtree; narrow it with `Selector<TaskProvider, int>` observing `tabviewIndex`.
>
> **[LOW / NIT]**
> - `notification_service.dart:325` — Variable `overdue` can be `final overdueCount` for clarity.

---

## 5. 🔧 `/fix` — The Surgical Mechanic

### In Simple Words
Think of `/fix` as a **Fast Mechanic**. When you already know what is broken and don't need an architecture discussion or 5-step plan, `/fix` jumps straight to the exact file, changes only the required lines, runs `flutter analyze`, and confirms the build is clean.

### When to Use in Daily Production
- Fixing a specific bug identified by `/code-review`.
- Quick corrections: adding a `mounted` check, fixing a localization key typo in `AppLocalizations`, or guarding a null `reminderAt`.
- Applying a targeted fix when the root cause is already known.

### When NOT to Use
- If the fix requires touching 3+ files or redesigning a data flow → use `/plan` first.
- If you're unsure of the root cause → use `/analyze` first.

### Technical Example
```
/fix Guard task.reminderAt null check in notification_service.dart:80 before calling tz.TZDateTime.from
```
> **Result:** Opens `notification_service.dart`, replaces `final reminderTime = task.reminderAt!;` with a safe null check, runs `dart format` and `flutter analyze` to confirm zero issues, and outputs a 2-line diff summary.

---

## 6. 🧪 `/tdd` — The Test-First Engineer

### In Simple Words
Think of `/tdd` as a **Test Lab Scientist**. The golden rule: **the test is written before the solution exists**. This forces clear thinking about what the code must do before how it does it, and guarantees every new filter rule, provider action, or storage mapper is covered by a test that proves it works.

### When to Use in Daily Production
- When adding or modifying `TaskFilterState` / `applyTaskFilter` logic.
- When adding a new `ChangeNotifier` method in `TaskProvider` or `AuthProvider`.
- When adding a new `@HiveType` serialization field or `fromMap` / `toJson` mapper.
- When fixing a reported bug — write a test that *reproduces* the bug first.

### When NOT to Use
- Pure UI layout changes with no logic (use `/adaptive-ui` instead).
- Renaming variables or extracting widgets with zero logic change.

### Technical Example
```
/tdd Add unit tests for applyTaskFilter() when filtering Completed tasks by CompletionTimeStatus.overdue
```

> **RED Phase** *(write first, must fail)*:
> ```dart
> // test/data/models/task_filter_state_test.dart
> test('keeps only overdue completed tasks when timeStatus is overdue', () {
>   final result = applyTaskFilter(
>     [onTimeTask, overdueTask],
>     const TaskFilterState(timeStatus: CompletionTimeStatus.overdue),
>     isCompletedTab: true,
>   );
>   expect(result, [overdueTask]);
> });
> // flutter test → ❌ FAIL
> ```

> **GREEN Phase** *(minimum code to pass)*:
> Implement/fix the `timeStatus` filter check in `lib/data/models/task_filter_state.dart` until `flutter test` passes.

> **REFACTOR Phase** *(clean up, stay green)*:
> Keep `applyTaskFilter` pure and re-run `flutter test` to confirm all tests stay green.

---

## 7. 📱 `/adaptive-ui` — The Responsive Layout Engineer

### In Simple Words
Think of `/adaptive-ui` as a **Responsive Design Specialist**. It makes your app look professional on everything from a compact phone to a foldable or tablet — all by applying the project's 3-tier breakpoint system in `ContextExtensions` (`isCompact`, `isMedium`, `isExpanded`) while **never touching your business logic, state, or routes**.

### When to Use in Daily Production
- A screen's task cards, dialogs, or filter chips stretch unnaturally wide on tablet.
- The soft keyboard covers form fields with no scroll escape.
- A new screen needs to be built responsive from scratch.
- A short/split-screen viewport (`height <= 550`) overflows vertically.

### When NOT to Use
- Fixing a bug in `TaskProvider` or `TaskRepository` — use `/tdd` or `/fix`.
- Changing navigation logic — use `/plan` first.

### Technical Example
```
/adaptive-ui Refactor lib/presentation/screens/task/task_screen.dart for tablet portrait and tablet landscape
```
> **What runs internally (the 4-step pipeline):**
>
> **Step 1 — Non-Destructive Discovery**
> Opens `task_screen.dart`, traces `TaskProvider` bindings, `TabController`, `AppLocalizations`, and `ContextExtensions` (`context.horizontalPadding`, `context.isCompact`, `context.isMedium`, `context.isExpanded`). These are **locked** — business logic stays untouched.
>
> **Step 2 — Responsive Layout Planning**
> Plans the 3-tier layout using `skills/adaptive-flutter-screen/templates/adaptive-screen-blueprint-design.md`:
> | Viewport | Condition | Layout Plan |
> |---|---|---|
> | Compact | `width < 600 \|\| height <= 550` | Single vertical scrollable column (`SingleChildScrollView` / `ListView`) |
> | Landscape / Split Guard | `height <= 550` even if wide | Treat strictly as Compact — never 2-column |
> | Medium | `600 <= width <= 840 && height > 550` | `ConstrainedBox(maxWidth: 600)` or 2-column grid |
> | Expanded | `width > 840 && height > 550` | Split-pane `Row` (task list + filter/detail pane) |
>
> **Step 3 — Modular Implementation**
> Splits large trees into `const`-friendly local sub-widgets inside `lib/presentation/screens/task/widgets/`, using `Selector<TaskProvider, ...>` and `AppLocalizations`.
>
> **Step 4 — Verification**
> Runs `dart format lib/presentation/screens/task/` and `flutter analyze lib/presentation/screens/task/` with 0 issues.

---

## 8. 🔒 `/security` — The Vault Guard

### In Simple Words
Think of `/security` as the **Airport Security Checkpoint before boarding**. Before your code goes public to GitHub or the Play Store, `/security` scans every file for accidentally committed Firebase configs or `secrets.json`, insecure credential storage, overly permissive Firestore rules, `MethodChannel` input hazards, and manifest permissions.

### When to Use in Daily Production
- Before every `git push origin main`.
- After modifying `StorageService`, `AuthProvider`, or saved credential handling (`flutter_secure_storage`).
- When updating Firestore collections (`TaskTrackerUsers`, `TaskTrackerTasks`, `TaskTrackerNotifications`) or `AndroidManifest.xml` / `Info.plist`.

### Technical Example
```
/security Scan the entire project before pushing to GitHub
```
> **Result:**
> - **[CRITICAL]** `lib/firebase_options.dart` is untracked check failed / staged for commit — unstage immediately (`git reset HEAD lib/firebase_options.dart`).
> - **[HIGH]** `StorageService`: confirm `StorageKeys.savedPassword` is only ever written to `_secureStorage`, never `_prefs` or Hive.
> - **[OK]** `.gitignore` excludes `.env`, `secrets.json`, `google-services.json`, `GoogleService-Info.plist`, `lib/firebase_options.dart`, `*.jks`, `*.keystore` ✅
> - **[OK]** All Android permissions in `AndroidManifest.xml` match notifications, exact alarms, battery optimization, camera, and media access ✅

---

## 9. 🏗️ `/build-fix` — The Emergency Doctor

### In Simple Words
Think of `/build-fix` as the **Emergency Room Doctor**. When `flutter analyze` reports red errors, `build_runner` fails with conflicting outputs, or `firebase_options.dart` is missing locally, `/build-fix` reads the full error log, identifies the **root cause** (not a cascade symptom), applies the smallest safe fix, and re-runs the tool to confirm it passes.

### When to Use in Daily Production
- `flutter analyze` reports errors after a merge or model edit.
- `build_runner` fails with `"conflicting outputs"` or `"duplicate typeId"`.
- Missing `lib/firebase_options.dart` on a fresh clone (since it is gitignored).
- After editing `TaskModel` or `UserModel` and getting `"Undefined class TaskModelAdapter"`.

### Common Errors This Command Fixes

| Error Message | Root Cause | Fix Applied |
|---|---|---|
| `Undefined class TaskModelAdapter` | `build_runner` not run after `@HiveType` edit | `dart run build_runner build --delete-conflicting-outputs` |
| `Conflicting outputs for task_model.g.dart` | Stale generated file | Re-run build_runner with `--delete-conflicting-outputs` |
| `Duplicate typeId '1'` | Two `@HiveType` classes share ID `0–3` | Assign next unused `typeId` (`>= 4`) |
| `Target of URI doesn't exist: 'firebase_options.dart'` | Gitignored local config not generated on this machine | Run `flutterfire configure` |
| `No Firebase App '[DEFAULT]'` | `Firebase.initializeApp()` missing or after `runApp()` | Ensure `await Firebase.initializeApp()` runs first in `main()` |
| `Use 'BuildContext's across async gaps` | Missing `mounted` check after `await` | Add `if (!context.mounted) return;` |

---

## 10. ✅ `/verify` — The Final Quality Gate

### In Simple Words
Think of `/verify` as the **Flight Pre-Check before takeoff**. It runs the entire local quality pipeline — secret/gitignore check, formatting, Hive codegen check, static analysis, and the full test suite — producing a clear pass/fail per gate. If any gate fails, it auto-loads the Build Error Resolver and fixes it until everything is green.

### The 5 Gates It Runs
```
Gate 1 — Diff & Secret Check
  ├── git status / git diff --stat
  └── Confirm secrets.json, firebase_options.dart, google-services.json, keystores are NOT staged

Gate 2 — Formatter
  └── dart format .

Gate 3 — Hive Codegen Check
  └── If UserModel, TaskModel, or enums.dart was modified:
      dart run build_runner build --delete-conflicting-outputs

Gate 4 — Static Analysis
  └── flutter analyze  (must report 0 issues)

Gate 5 — Test Suite
  └── flutter test  (must be 100% green)
```

---

## 11. 📝 `/document` — The Project Biographer

### In Simple Words
Think of `/document` as your **Project Biographer**. It inspects the codebase, `context.md`, and git history, then updates `context.md` (architectural decisions under 150 lines), `README.md` (project overview), and `CHANGELOG.md` (version history) while blocking code-level bloat.

### Technical Example
```
/document Log the decision to add TaskFilterState filtering in context.md
```

---

## 💡 Typical Daily Workflow

```
1. 💡 New idea or requirement           →  /analyze     (evaluate 2–3 options with trade-offs)
2. 📐 Architecture approved             →  /plan        (produce phased blueprint with file list)
3. 🧪 Core logic implementation         →  /tdd         (Red → Green → Refactor with tests first)
4. 📱 Responsive UI layout              →  /adaptive-ui (make it look good on all screen sizes)
5. 🔍 Quality inspection                →  /code-review (catch bugs, leaks, async hazards)
6. 🔒 Pre-push security check           →  /security    (no secrets or private Firebase files staged)
7. ✅ Final quality gate                →  /verify      (format + analyze + test suite — all green)
8. 📝 Log architectural decision        →  /document    (update context.md + README if needed)
```

**Short-circuit path for small fixes**: `Bug reported → /fix → /verify → commit`
**Short-circuit path for full automation**: `/run → answer 2 questions`

---

## 🗂️ Files Behind Every Command

```
📁 .agent/workflows/                  ← Antigravity slash commands
│   ├── run.md                        → /run
│   ├── analyze.md                    → /analyze
│   ├── plan.md                       → /plan
│   ├── fix.md                        → /fix
│   ├── tdd.md                        → /tdd
│   ├── adaptive-ui.md                → /adaptive-ui
│   ├── code-review.md                → /code-review
│   ├── security.md                   → /security
│   ├── build-fix.md                  → /build-fix
│   ├── verify.md                     → /verify
│   └── document.md                   → /document

📁 .codex/agents/                     ← 1:1 mirrored Codex agent TOMLs

📁 personas/                          ← Who the AI "becomes" for each task
│   ├── orchestrator.md               → /run
│   ├── analyzer.md                   → /analyze (architecture trade-offs)
│   ├── architect.md                  → /analyze (layer design)
│   ├── planner.md                    → /plan (Provider/Hive/Firebase/Notifications aware)
│   ├── provider-state.md             → ChangeNotifier & ValueNotifier patterns
│   ├── tdd-guide.md                  → /tdd
│   ├── flutter-adaptive-screen.md    → /adaptive-ui
│   ├── code-reviewer.md              → /code-review
│   ├── security-reviewer.md          → /security and /run option 5
│   ├── build-error-resolver.md       → /build-fix and /verify auto-heal
│   └── documentation-writer.md       → /document

📁 rules/common/                      ← Always-on universal standards
│   ├── coding_style.md               → naming, file size, linting, no // ignore:
│   ├── security.md                   → secure storage, gitignore secrets, Firestore rules
│   ├── testing.md                    → pyramid, Hive/Firebase mocks, filter & widget tests
│   └── development_workflow.md       → lifecycle, build_runner gate, git hygiene

📁 rules/platforms/                   ← Load only the matching one per task
│   ├── flutter-dart.md               → Provider, Hive, StorageService, lifecycle ← PRIMARY
│   ├── flutter-adaptive-ui.md        → breakpoints, ContextExtensions, scroll safety
│   ├── flutter-firebase.md           → init order, Auth, Firestore, FCM ← ALWAYS for Firebase
│   ├── android-kotlin.md             → native Android / DeviceSettingsService channel only
│   └── ios-swift.md                  → native iOS modules only

📁 skills/                            ← Step-by-step execution checklists
│   ├── tdd-workflow/SKILL.md                  → RED→GREEN→REFACTOR steps
│   ├── verification-loop/SKILL.md             → 5-gate pre-completion check
│   ├── adaptive-flutter-screen/SKILL.md       → 4-step responsive pipeline
│   ├── hive-database/SKILL.md                 → Hive model (typeId 0–3+) → codegen → StorageService
│   ├── local-notifications/SKILL.md           → flutter_local_notifications + timezone + exact alarms
│   └── context-and-decisions/SKILL.md         → Quality-gated docs updater

📄 AGENTS.md                ← Master project identity (always loaded)
📄 context.md               ← Active architectural decisions (always loaded)
📄 .gemini/GEMINI.md        ← Antigravity workspace configuration
📄 .codex/config.toml       ← Codex workspace configuration
```

---

## ⚡ CLI Quick Reference (Manual Commands)

```bash
# Format all Dart files
dart format .

# Static analysis — must show 0 issues before committing
flutter analyze

# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run the sample filter empty-state widget test
flutter test test/widget_test.dart

# Regenerate Hive type adapters (run after every @HiveType edit)
dart run build_runner build --delete-conflicting-outputs

# Regenerate firebase_options.dart locally (never commit — gitignored)
flutterfire configure

# Android native compile & lint check
./gradlew compileDebugKotlin
./gradlew lintDebug
```
