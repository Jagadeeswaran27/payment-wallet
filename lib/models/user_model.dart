class UserModel {
  final String uid;
  final String phone;
  final bool isOnboardCompleted;
  final double walletBalance;
  final String? name;
  final String? email;
  final String? state;
  final String? address;
  final String? profilePicPath;
  final bool? kycStatus;
  final String? pinHash;

  UserModel({
    required this.uid,
    required this.phone,
    required this.isOnboardCompleted,
    required this.walletBalance,
    this.name,
    this.email,
    this.state,
    this.address,
    this.profilePicPath,
    this.kycStatus,
    this.pinHash,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      phone: map['phone'],
      walletBalance: map['walletBalance'],
      isOnboardCompleted: map['isOnboardCompleted'],
      name: map['name'],
      email: map['email'],
      state: map['state'],
      address: map['address'],
      profilePicPath: map['profilePicPath'],
      kycStatus: map['kycStatus'],
      pinHash: map['pinHash'],
    );
  }

  UserModel copyWith({
    String? uid,
    String? phone,
    bool? isOnboardCompleted,
    double? walletBalance,
    String? name,
    String? email,
    String? state,
    String? address,
    String? profilePicPath,
    bool? kycStatus,
    String? pinHash,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      phone: phone ?? this.phone,
      isOnboardCompleted: isOnboardCompleted ?? this.isOnboardCompleted,
      walletBalance: walletBalance ?? this.walletBalance,
      name: name ?? this.name,
      email: email ?? this.email,
      state: state ?? this.state,
      address: address ?? this.address,
      profilePicPath: profilePicPath ?? this.profilePicPath,
      kycStatus: kycStatus ?? this.kycStatus,
      pinHash: pinHash ?? this.pinHash,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'phone': phone,
      'isOnboardCompleted': isOnboardCompleted,
      'name': name,
      'email': email,
      'state': state,
      'address': address,
      'profilePicPath': profilePicPath,
      'walletBalance': walletBalance,
      'kycStatus': kycStatus,
      'pinHash': pinHash,
    };
  }
}
