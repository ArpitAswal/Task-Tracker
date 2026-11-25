---
name: tdd-workflow
description: Step-by-step checklist for executing the RED -> GREEN -> REFACTOR test-driven cycle in Flutter/Dart.
---

# TDD Execution Workflow

Follow this strict pipeline when writing new logic:

## Step 1: RED (Write the Test First)
1. Identify the observable behavior or contract to test (e.g., `TaskFilterState`, `applyTaskFilter`, `TaskProvider`, `TaskModel` serialization, widget state).
2. Write a single failing unit or widget test covering this behavior using deterministic fixtures and mocked Hive/Firebase/channels (no live Firebase calls).
3. Run `flutter test <test_file>` to confirm it fails. Do NOT write production code yet.

## Step 2: GREEN (Make it Pass)
1. Write the absolute minimum production code required to make the failing test pass.
2. Do not add speculative features or optimize yet.
3. Re-run `flutter test <test_file>` to confirm it turns green.

## Step 3: REFACTOR (Clean it Up)
1. Refactor the passing code to improve readability, enforce immutability (`final`, `copyWith`), and remove duplication.
2. Ensure you follow `rules/common/coding_style.md` and `rules/platforms/flutter-dart.md`.
3. Re-run `flutter test` across the suite to ensure all tests stay green after refactoring.
