# Common Testing Strategy & Standards

## 1. Testing Philosophy & Coverage Target
- Test **observable behavior and domain contracts**, not private implementation details.
- **Coverage Target**: 80% line/branch coverage for data models (`TaskModel`, `UserModel`, `TaskFilterState`), pure helpers (`applyTaskFilter`), providers (`TaskProvider`, `AuthProvider`), and repositories. Run with:
  ```bash
  flutter test --coverage
  genhtml coverage/lcov.info -o coverage/html
  ```
- High coverage target (95–100%) for task filtering rules, date/overdue edge cases, streak logic, and authentication/credential handling.
- Pragmatic exemptions for thin UI wrappers, generated code (`*.g.dart`), and DI wiring.

## 2. Test Pyramid
1. **Unit Tests (~70%)**: Test `TaskFilterState`, `applyTaskFilter()`, `TaskModel` / `UserModel` serialization (`fromMap`, `toJson`, `copyWith`), `TaskProvider` state transitions, and notification scheduling preconditions. Never open real app Hive directories — use `Hive.init()` with a temporary directory in `setUpAll()`.
2. **Widget / Component Tests (~20%)**: Test UI rendering across loading (shimmer), empty (`TaskFilterEmptyState`), error, and populated states plus user taps. Wrap widgets under test with `ChangeNotifierProvider` / `MultiProvider` supplying mock or fake providers and `AppLocalizations` delegates when needed.
3. **Integration Tests (~10%)**: Test critical end-to-end flows: authentication routing, task create → filter → complete → streak update, and preference persistence.

## 3. Mocking Hive, Firebase & Platform Channels
- **Hive**: In tests, initialize in a temp dir (`setUpAll(() async { final dir = await Directory.systemTemp.createTemp(); Hive.init(dir.path); });`) and clean up with `Hive.close()`.
- **Firebase**: Use fakes/mocks (`firebase_auth_mocks`, `fake_cloud_firestore`, or injected fake repositories via `TaskProvider(taskRepository: ...)`). Never call live Firebase in unit or widget tests (`test/widget_test.dart` must stay Firebase-independent unless mocked).
- **Platform Channels & Notifications**: Mock `MethodChannel('task_tracker/device_settings')` via `TestDefaultBinaryMessengerBinding` when testing `DeviceSettingsService` or `SettingScreen` OS settings flows.

## 4. Determinism
- Zero arbitrary `sleep` or wall-clock dependencies in tests — pass explicit `referenceNow` (e.g., in `applyTaskFilter`) and fixed `DateTime` fixtures.
- Use `pump` / `pumpAndSettle` cleanly in widget tests.
- Follow **Arrange → Act → Assert** (Given / When / Then).
