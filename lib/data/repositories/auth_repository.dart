import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/storage_service.dart';
import '../../core/utils/exception_handling/effect_bus.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final StorageService _storageService;
  final EffectBus _effect;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    StorageService? storageService,
    EffectBus? effect,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _storageService = storageService ?? StorageService(),
       _effect = effect ?? EffectBus.instance;

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Sign in user with email and password
  ///
  /// [email] - User's email address
  /// [password] - User's password
  /// [rememberMe] - Whether to save credentials
  /// [context] - Optional context for localized errors
  ///
  /// Returns: UserModel if successful
  /// Throws: Exception with localized message
  Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      // Sign in with Firebase Auth
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (userCredential.user == null) {
        throw 'login_failed_no_user';
      }

      await _storageService.openUserBoxes(userCredential.user?.uid ?? "");

      // Update last login time in Firestore
      unawaited(
        _effect.safeEffect(
          () => updateDocField(
            FirebaseCollections.users,
            userCredential.user!.uid,
            'lastLoginAt',
            null,
          ),
        ),
      );

      // Handle remember me
      if (rememberMe) {
        await _storageService.saveBool(StorageKeys.rememberMe, true);
        await _storageService.saveSecure(StorageKeys.savedEmail, email);
        await _storageService.saveSecure(StorageKeys.savedPassword, password);
      } else {
        await _storageService.saveBool(StorageKeys.rememberMe, false);
        await _storageService.deleteSecure(StorageKeys.savedEmail);
        await _storageService.deleteSecure(StorageKeys.savedPassword);
      }

      // Save login state
      await _storageService.saveBool(StorageKeys.isLoggedIn, true);
      await _storageService.saveString(
        StorageKeys.userId,
        userCredential.user!.uid,
      );

      // Get user data from Firestore
      return await getUserData(userCredential.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw e.code;
    } catch (e) {
      rethrow;
    }
  }

  // Register with email and password
  Future<UserModel?> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Create user with Firebase Auth
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw 'registration_failed_no_user';
      }

      await _storageService.openUserBoxes(userCredential.user?.uid ?? "");

      // Create user model
      final userModel = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isEmailVerified: false,
      );

      // Save user data to Firestore
      await _firestore
          .collection(FirebaseCollections.users)
          .doc(userCredential.user!.uid)
          .set(userModel.toJson());

      // Save login state
      await _storageService.saveBool(StorageKeys.isLoggedIn, true);
      await _storageService.saveString(
        StorageKeys.userId,
        userCredential.user!.uid,
      );

      // Send email verification
      await userCredential.user!.sendEmailVerification();

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw e.code;
    } catch (e) {
      throw 'unexpected_error';
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw e.code;
    } catch (e) {
      throw 'unexpected_error';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await _storageService.saveBool(StorageKeys.isLoggedIn, false);
      await _storageService.remove(StorageKeys.userId);

      // Keep remember me credentials if enabled
      final rememberMe =
          _storageService.readBool(StorageKeys.rememberMe) ?? false;
      if (!rememberMe) {
        await _storageService.deleteSecure(StorageKeys.savedEmail);
        await _storageService.deleteSecure(StorageKeys.savedPassword);
      }
    } catch (e) {
      throw 'unexpected_error';
    }
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore
          .collection(FirebaseCollections.users)
          .doc(uid)
          .get();

      if (!doc.exists) {
        throw 'user-profile-error';
      }

      return UserModel.fromFirestore(doc);
    } catch (e) {
      rethrow;
    }
  }

  /// Update user profile data with arbitrary fields
  ///
  /// Used for profile setup - writes all provided fields to the user doc
  Future<void> updateUserProfileData({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore
          .collection(FirebaseCollections.users)
          .doc(uid)
          .update(data);
    } catch (e) {
      debugPrint('updateDocField failed: $e');
      throw 'unexpected_error';
    }
  }

  // Update last login time
  Future<void> updateDocField(
    String col,
    String? uid,
    String field,
    dynamic value,
  ) async {
    try {
      await _firestore.collection(col).doc(uid).update({
        field:
            value ??
            FieldValue.serverTimestamp(), // it tells Firebase's servers to use their own internal clock to record the exact time the update happened.
      });
    }  on FirebaseAuthException catch (e) {
      throw e.code;
    } catch (e) {
      // Silent fail - not critical
      throw 'not-found';
    }
  }

  // Get saved credentials (for remember me)
  Future<Map<String, String?>> getSavedCredentials() async {
    try {
      final rememberMe =
          _storageService.readBool(StorageKeys.rememberMe) ?? false;
      debugPrint("does credentials save  -->  $rememberMe");

      if (!rememberMe) {
        return {'email': null, 'password': null};
      }

      final email = await _storageService.readSecure(StorageKeys.savedEmail);
      final password = await _storageService.readSecure(
        StorageKeys.savedPassword,
      );

      return {'email': email, 'password': password};
    } catch (e) {
      throw 'remember_me_failed';
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    return _storageService.readBool(StorageKeys.isLoggedIn) ?? false;
  }
}
