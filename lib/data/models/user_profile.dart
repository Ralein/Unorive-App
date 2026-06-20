/// Represents the user's synchronization and account profile status.
class UserProfile {
  const UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.isAnonymous,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      isAnonymous: json['isAnonymous'] as bool,
    );
  }

  final String uid;
  final String email;
  final String displayName;
  final bool isAnonymous;

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'isAnonymous': isAnonymous,
    };
  }
}
