import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/exception_handling/effect_bus.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/user_model.dart';
import '../../core/services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository;
  final StorageService _storageService;

  AuthProvider({AuthRepository? authRepository, StorageService? storageService})
    : _authRepository = authRepository ?? AuthRepository(),
      _storageService = storageService ?? StorageService();

  // State variables
  UserModel? _userData;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isRememberMe = false;
  bool _isEmailVerify = false;
  bool _isLoggedIn = false;
  FirebaseAuth? _firebaseAuth;

  // Getters
  UserModel? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isRememberMe => _isRememberMe;
  bool get isEmailVerify => _isEmailVerify;
  bool get isAuthenticated => _isLoggedIn;
  FirebaseAuth? get firebaseAuth => _firebaseAuth;

  // Initialize provider
  Future<void> initialize() async {
    _setLoading(true);

    try {
      _firebaseAuth = FirebaseAuth.instance;
      // Check if user is logged in
      _isLoggedIn = await _authRepository.isLoggedIn();

      // Load saved credentials if remember me is enabled
      final credentials = await _authRepository.getSavedCredentials();
      _isRememberMe =
          credentials['email'] != null && credentials['password'] != null;

      getEmailVerify();

      if (_isLoggedIn) {
        final user = _authRepository.currentUser;
        if (user != null) {
          await _storageService.openUserBoxes(user.uid);
          _userData = await _authRepository.getUserData(user.uid);
        }
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // Get saved credentials (for auto-fill)
  Future<Map<String, String?>> getSavedCredentials() async {
    return await _authRepository.getSavedCredentials();
  }

  // Update the doc specific field

  Future<void> updateCollectionField(
    String col,
    String field,
    dynamic value,
  ) async {
    unawaited(
      EffectBus.instance.safeEffect(
        () => _authRepository.updateDocField(
          FirebaseCollections.users,
          _userData?.uid,
          field,
          value,
        ),
      ),
    );
  }

  // Login
  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    _setLoading(true);
    _clearError();
    notifyListeners();

    try {
      _userData = await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );
      _firebaseAuth?.currentUser?.reload();
      if ((_firebaseAuth?.currentUser?.uid ?? '').isNotEmpty) {
        _isRememberMe = rememberMe;
        getEmailVerify();
      } else {
        return false;
      }
      if (_userData == null) {
        throw 'user-profile-error';
      }
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // Register
  Future<bool> register({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _userData = await _authRepository.registerWithEmailAndPassword(
        email: email,
        password: password,
      );

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally{
      _setLoading(false);
      notifyListeners();
    }
  }

  // Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _authRepository.sendPasswordResetEmail(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<void> resendEmail() async {
    _setLoading(true);
    _clearError();

    try {
      await firebaseAuth?.currentUser?.sendEmailVerification();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);

    try {
      await _authRepository.signOut();
      _userData = null;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Save complete profile setup data to Firestore
  ///
  /// Updates the user document in TaskTrackerUsers with all provided fields.
  /// Used for both initial profile setup and profile editing.
  Future<bool> saveProfileSetup({
    required String firstName,
    String? lastName,
    required String email,
    String? photoUrl,
    String? gender,
    int? age,
    String? location,
  }) async {

    _setLoading(true);
    _clearError();

    try {
      final displayName = lastName != null && lastName.isNotEmpty
          ? '$firstName $lastName'
          : firstName;

      final updates = <String, dynamic>{
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'displayName': displayName,
        'gender': gender,
        'age': age,
        'location': location,
        'updateAt': DateTime.now()
      };

      // Only include photoUrl if provided
      if (photoUrl != null) {
        updates['photoUrl'] = photoUrl;
      }

      await _authRepository.updateUserProfileData(
        uid: _userData?.uid ?? _firebaseAuth?.currentUser?.uid ?? '',
        data: updates,
      );

      // Update local user data
      _userData = _userData?.copyWith(
        firstName: firstName,
        lastName: lastName,
        email: email,
        displayName: displayName,
        photoUrl: photoUrl ?? _userData!.photoUrl,
        gender: gender,
        age: age,
        location: location,
      );

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Update user streak when a task is completed.
  ///
  /// - If already active today → no-op
  /// - If last active yesterday → increment streak
  /// - If last active older → reset streak to 1
  /// Updates longestStreak if current exceeds it. Saves to Firestore.
  Future<void> updateStreak() async {
    if (_userData == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastActive = _userData!.lastActiveDate;

    int newStreak = _userData!.currentStreak;
    int newLongest = _userData!.longestStreak;

    if (lastActive != null) {
      final lastDate = DateTime(lastActive.year, lastActive.month, lastActive.day);
      final diff = today.difference(lastDate).inDays;

      if (diff == 0) {
        // Already counted today — no-op
        return;
      } else if (diff == 1) {
        // Consecutive day — increment
        newStreak += 1;
      } else {
        // Streak broken — reset
        newStreak = 1;
      }
    } else {
      // First ever task completion
      newStreak = 1;
    }

    if (newStreak > newLongest) {
      newLongest = newStreak;
    }

    try {
      await _authRepository.updateUserProfileData(
        uid: _userData!.uid,
        data: {
          'currentStreak': newStreak,
          'longestStreak': newLongest,
          'lastActiveDate': today.toIso8601String(),
        },
      );

      _userData = _userData!.copyWith(
        currentStreak: newStreak,
        longestStreak: newLongest,
        lastActiveDate: today,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to update streak: $e');
    }
  }

  // Toggle remember me
  void toggleRememberMe() {
    _isRememberMe = !_isRememberMe;
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void getEmailVerify() {
    _isEmailVerify =
        _storageService.readBool(StorageKeys.isVerifiedEmail) ??
        _firebaseAuth?.currentUser?.emailVerified ??
        false;
    notifyListeners();
  }

  Future<void> setEmailVerify(bool value) async {
    _isEmailVerify = value;
    await _storageService.saveBool(StorageKeys.isVerifiedEmail, value);
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  // Clear error manually
  void clearError() {
    _clearError();
    notifyListeners();
  }
}
