---
description: Create a structured implementation plan and architectural blueprint before coding
---

1. Read `AGENTS.md`, `context.md`, and `personas/planner.md`.
2. Inspect the target files under `lib/core/`, `lib/data/`, `lib/presentation/`, `pubspec.yaml`, and active platform rules in `rules/platforms/`.
3. Produce the 5-part implementation plan defined in `personas/planner.md`:
   - Problem Statement & Scope
   - Impact & Dependency Analysis (exact file paths + `build_runner` gate if `UserModel`, `TaskModel`, or `enums.dart` are touched)
   - Interface Contracts & Data Models (`ChangeNotifier` state, Hive `typeId >= 4`, notification/channel contracts, typed failures)
   - Phased TDD Implementation (Phase 1 Models/Pure Logic → Phase 2 Data/Services → Phase 3 Providers → Phase 4 UI)
   - Edge Cases & Verification Plan (CLI commands to run)
4. Pause and wait for user confirmation before modifying any project files.
