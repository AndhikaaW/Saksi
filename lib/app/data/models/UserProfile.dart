class UserProfile {
  final String photoUrl;
  final String name;
  final String email;
  final String gender;
  final String ttl;
  final String address;
  final String phone;
  final String uid;
  final int status;

  UserProfile({
    required this.photoUrl,
    required this.name,
    required this.email,
    required this.gender,
    required this.ttl,
    required this.address,
    required this.phone,
    required this.uid,
    required this.status,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      gender: json['gender'] ?? '',
      ttl: json['ttl'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      uid: json['uid'] ?? '',
      status: json['status'] ?? 0,
    );
  }

  UserProfile copyWith({
    String? photoUrl,
    String? name,
    String? email,
    String? gender,
    String? ttl,
    String? address,
    String? phone,
    String? uid,
    int? status,
  }) {
    return UserProfile(
      photoUrl: photoUrl ?? this.photoUrl,
      name: name ?? this.name,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      ttl: ttl ?? this.ttl,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      uid: uid ?? this.uid,
      status: status ?? this.status,
    );
  }
}