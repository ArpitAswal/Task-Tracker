// 🔄 UPDATED: Added Hive support, toMap, fromMap, and comprehensive comments
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'user_model.g.dart'; // ✨ NEW: Generated file for Hive adapter

/// User data model representing a user in the application
///
/// This model is used for:
/// - Firebase Firestore storage
/// - Local Hive storage (offline support)
/// - In-app user state management
///
/// Hive TypeId: 0
@HiveType(typeId: 0)
class UserModel extends HiveObject {
  /// Unique user identifier (Firebase UID)
  @HiveField(0)
  final String uid;

  /// User's email address
  @HiveField(1)
  final String email;

  /// User's display name (optional)
  @HiveField(2)
  final String? displayName;

  /// URL to user's profile photo (optional) — stores Base64 string or URL
  @HiveField(3)
  final String? photoUrl;

  /// Timestamp when user account was created
  @HiveField(4)
  final DateTime createdAt;

  /// Timestamp of last login (optional)
  @HiveField(5)
  final DateTime? lastLoginAt;

  /// Whether user's email is verified
  @HiveField(6)
  final bool isEmailVerified;

  /// User preferences (theme, language, notifications, etc.)
  @HiveField(7)
  final Map<String, dynamic>? preferences;

  /// User's first name
  @HiveField(8)
  final String? firstName;

  /// User's last name
  @HiveField(9)
  final String? lastName;

  /// User's gender (male, female, other, prefer_not_to_say)
  @HiveField(10)
  final String? gender;

  /// User's age
  @HiveField(11)
  final int? age;

  /// User's location
  @HiveField(12)
  final String? location;

  /// Current streak: consecutive days with at least 1 task completed
  @HiveField(13)
  final int currentStreak;

  /// Longest streak ever achieved
  @HiveField(14)
  final int longestStreak;

  /// Last date a task was completed (for streak calculation)
  @HiveField(15)
  final DateTime? lastActiveDate;

  /// Timestamp when user account was updated
  @HiveField(16)
  final DateTime? updatedAt;

  /// Constructor with required and optional fields
  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.createdAt,
    this.lastLoginAt,
    this.isEmailVerified = false,
    this.preferences,
    this.firstName,
    this.lastName,
    this.gender,
    this.age,
    this.location,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActiveDate,
    this.updatedAt,
  });

  // ============================================================================
  // SERIALIZATION METHODS
  // ============================================================================

  /// Convert model to JSON for Firebase Firestore
  ///
  /// Returns a Map with Firestore-compatible data types (Timestamp)
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': lastLoginAt != null
          ? Timestamp.fromDate(lastLoginAt!)
          : null,
      'isEmailVerified': isEmailVerified,
      'preferences': preferences,
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'age': age,
      'location': location,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActiveDate': lastActiveDate != null
          ? Timestamp.fromDate(lastActiveDate!)
          : null,
      'updatedAt': Timestamp.fromDate(createdAt),
    };
  }

  /// ✨ NEW: Convert model to Map for general use
  ///
  /// Returns a Map with DateTime objects (not Timestamp)
  /// Useful for local storage, API calls, etc.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'isEmailVerified': isEmailVerified,
      'preferences': preferences,
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'age': age,
      'location': location,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActiveDate': lastActiveDate?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create model from JSON (Firebase Firestore)
  ///
  /// Converts Firestore Timestamp to DateTime
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      lastLoginAt: json['lastLoginAt'] != null
          ? (json['lastLoginAt'] as Timestamp).toDate()
          : null,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      preferences: json['preferences'] as Map<String, dynamic>?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      gender: json['gender'] as String?,
      age: json['age'] as int?,
      location: json['location'] as String?,
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      lastActiveDate: json['lastActiveDate'] != null
          ? (json['lastActiveDate'] as Timestamp).toDate()
          : null,
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// ✨ NEW: Create model from Map
  ///
  /// Parses ISO8601 date strings to DateTime
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      email: map['email'] as String,
      displayName: map['displayName'] as String?,
      photoUrl: map['photoUrl'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastLoginAt: map['lastLoginAt'] != null
          ? DateTime.parse(map['lastLoginAt'] as String)
          : null,
      isEmailVerified: map['isEmailVerified'] as bool? ?? false,
      preferences: map['preferences'] as Map<String, dynamic>?,
      firstName: map['firstName'] as String?,
      lastName: map['lastName'] as String?,
      gender: map['gender'] as String?,
      age: map['age'] as int?,
      location: map['location'] as String?,
      currentStreak: map['currentStreak'] as int? ?? 0,
      longestStreak: map['longestStreak'] as int? ?? 0,
      lastActiveDate: map['lastActiveDate'] != null
          ? DateTime.parse(map['lastActiveDate'] as String)
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  /// Create model from Firestore DocumentSnapshot
  ///
  /// Convenience method for direct Firestore document conversion
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromJson({...data, 'uid': doc.id});
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// ✨ NEW: Create a copy of model with updated fields
  ///
  /// Immutable update pattern - returns new instance
  /// Only specified fields are updated, others remain same
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isEmailVerified,
    Map<String, dynamic>? preferences,
    String? firstName,
    String? lastName,
    String? gender,
    int? age,
    String? location,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActiveDate,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      preferences: preferences ?? this.preferences,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      location: location ?? this.location,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert model to string for debugging
  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, firstName: $firstName, lastName: $lastName)';
  }

  /// Check equality based on uid
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel && other.uid == uid;
  }

  /// Generate hash code based on uid
  @override
  int get hashCode => uid.hashCode;

  // ============================================================================
  // CONVENIENCE GETTERS
  // ============================================================================

  /// Get full display name from firstName + lastName, falling back to displayName
  String? get fullName {
    if (firstName != null && firstName!.isNotEmpty) {
      final last = (lastName != null && lastName!.isNotEmpty)
          ? ' $lastName'
          : '';
      return '$firstName$last';
    }
    return displayName;
  }

  /// Get user's initials for avatar
  /// Returns first letter of email if no display name
  String get initials {
    if (firstName != null && firstName!.isNotEmpty) {
      if (lastName != null && lastName!.isNotEmpty) {
        return '${firstName![0]}${lastName![0]}'.toUpperCase();
      }
      return firstName![0].toUpperCase();
    }
    if (displayName != null && displayName!.isNotEmpty) {
      final parts = displayName!.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return displayName![0].toUpperCase();
    }
    return email[0].toUpperCase();
  }

  /// Check if user has a profile photo
  bool get hasProfilePhoto => photoUrl != null && photoUrl!.isNotEmpty;

  /// Check if the user's profile is complete (has firstName and email)
  bool get isProfileComplete =>
      firstName != null && firstName!.isNotEmpty && email.isNotEmpty;
}
