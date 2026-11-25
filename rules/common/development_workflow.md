# Common Development & Git Workflow Rules

## 1. Execution Lifecycle
1. **Context Check**: Read `context.md` (project root) and recent git log to understand active architectural direction.
2. **Impact Analysis**: Search call sites across `lib/core/`, `lib/data/`, and `lib/presentation/` before altering shared models, Hive type adapters, or provider contracts.
3. **Codegen Gate**: After editing any `@HiveType`/`@HiveField` annotated model (`UserModel`, `TaskModel`, `TaskPriority`, `TaskCategory`), always run:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
4. **Incremental Changes**: Build features in verifiable layers (`Models & Constants → Repository + Tests → Provider + Tests → UI`).
5. **Verification Gate**: Run `dart format .` → `flutter analyze` → `flutter test` before completing any task.

## 2. Git Hygiene
- Make atomic, single-purpose commits.
- Follow Conventional Commits: `feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `chore:`.
- Never commit build artifacts (`build/`, `.dart_tool/`, `.gradle/`).
- **Never commit gitignored Firebase/secret files**: `lib/firebase_options.dart`, `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`, `firebase.json`, `secrets.json`, `key.properties`, `*.jks`, `*.keystore`.
- Never run destructive commands (`git reset --hard`, `git push --force`) without explicit user confirmation.
