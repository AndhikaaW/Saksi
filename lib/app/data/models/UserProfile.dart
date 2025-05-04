class UserProfile {
  final String photoUrl;
  final String name;
  final String email;
  final String gender;
  final String ttl;
  final String address;
  final String phone;
  final String statusPengguna;
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
    required this.statusPengguna,
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
      statusPengguna: json['statusPengguna']?? '',
      photoUrl: json['photoUrl'] ?? '',
      uid: json['uid'] ?? '',
      status: json['status'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'gender': gender,
        'ttl': ttl,
        'address': address,
        'phone': phone,
        'statusPengguna': statusPengguna,
        'photoUrl': photoUrl,
        'uid': uid,
        'status': status,
      };

  UserProfile copyWith({
    String? photoUrl,
    String? name,
    String? email,
    String? gender,
    String? ttl,
    String? address,
    String? phone,
    String? statusPengguna,
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
      statusPengguna: statusPengguna?? this.statusPengguna,
      uid: uid ?? this.uid,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'UserProfile(name: $name, email: $email, gender: $gender, ttl: $ttl, address: $address, phone: $phone, statusPengguna: $statusPengguna, photoUrl: $photoUrl, uid: $uid, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.photoUrl == photoUrl &&
        other.name == name &&
        other.email == email &&
        other.gender == gender &&
        other.ttl == ttl &&
        other.address == address &&
        other.phone == phone &&
        other.statusPengguna == statusPengguna &&
        other.uid == uid &&
        other.status == status;
  }

  @override
  int get hashCode {
    return photoUrl.hashCode ^
        name.hashCode ^
        email.hashCode ^
        gender.hashCode ^
        ttl.hashCode ^
        address.hashCode ^
        phone.hashCode ^
        statusPengguna.hashCode ^
        uid.hashCode ^
        status.hashCode;
  }
}
