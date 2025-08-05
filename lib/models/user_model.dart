enum UserType { influencer, seller }

enum UserStatus { active, inactive, suspended }

class User {
  final String id;
  final String email;
  final String name;
  final UserType type;
  final UserStatus status;
  final String? phone;
  final String? profileImage;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // 인플루언서 전용 필드
  final String? nickname;
  final String? region;
  final List<String>? snsAccounts;
  final int? followersCount;
  final List<String>? categories;
  final String? introduction;
  final String? pricePolicy;
  final int? priceAmount;
  final List<String>? availableTime;
  final List<String>? portfolio;
  
  // 판매사 전용 필드
  final String? company;
  final String? manager;
  final String? businessFile;
  final String? sector;
  final String? brand;
  final Map<String, bool>? alarmSettings;
  
  // 인증 관련
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final bool isProfileVerified;
  final bool isBusinessVerified;
  
  User({
    required this.id,
    required this.email,
    required this.name,
    required this.type,
    required this.status,
    this.phone,
    this.profileImage,
    required this.createdAt,
    required this.updatedAt,
    
    // 인플루언서 필드
    this.nickname,
    this.region,
    this.snsAccounts,
    this.followersCount,
    this.categories,
    this.introduction,
    this.pricePolicy,
    this.priceAmount,
    this.availableTime,
    this.portfolio,
    
    // 판매사 필드
    this.company,
    this.manager,
    this.businessFile,
    this.sector,
    this.brand,
    this.alarmSettings,
    
    // 인증
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.isProfileVerified = false,
    this.isBusinessVerified = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      type: UserType.values.firstWhere((e) => e.name == json['type']),
      status: UserStatus.values.firstWhere((e) => e.name == json['status']),
      phone: json['phone'],
      profileImage: json['profile_image'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      
      nickname: json['nickname'],
      region: json['region'],
      snsAccounts: json['sns_accounts']?.cast<String>(),
      followersCount: json['followers_count'],
      categories: json['categories']?.cast<String>(),
      introduction: json['introduction'],
      pricePolicy: json['price_policy'],
      priceAmount: json['price_amount'],
      availableTime: json['available_time']?.cast<String>(),
      portfolio: json['portfolio']?.cast<String>(),
      
      company: json['company'],
      manager: json['manager'],
      businessFile: json['business_file'],
      sector: json['sector'],
      brand: json['brand'],
      alarmSettings: json['alarm_settings']?.cast<String, bool>(),
      
      isEmailVerified: json['is_email_verified'] ?? false,
      isPhoneVerified: json['is_phone_verified'] ?? false,
      isProfileVerified: json['is_profile_verified'] ?? false,
      isBusinessVerified: json['is_business_verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'type': type.name,
      'status': status.name,
      'phone': phone,
      'profile_image': profileImage,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      
      'nickname': nickname,
      'region': region,
      'sns_accounts': snsAccounts,
      'followers_count': followersCount,
      'categories': categories,
      'introduction': introduction,
      'price_policy': pricePolicy,
      'price_amount': priceAmount,
      'available_time': availableTime,
      'portfolio': portfolio,
      
      'company': company,
      'manager': manager,
      'business_file': businessFile,
      'sector': sector,
      'brand': brand,
      'alarm_settings': alarmSettings,
      
      'is_email_verified': isEmailVerified,
      'is_phone_verified': isPhoneVerified,
      'is_profile_verified': isProfileVerified,
      'is_business_verified': isBusinessVerified,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    UserType? type,
    UserStatus? status,
    String? phone,
    String? profileImage,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? nickname,
    String? region,
    List<String>? snsAccounts,
    int? followersCount,
    List<String>? categories,
    String? introduction,
    String? pricePolicy,
    int? priceAmount,
    List<String>? availableTime,
    List<String>? portfolio,
    String? company,
    String? manager,
    String? businessFile,
    String? sector,
    String? brand,
    Map<String, bool>? alarmSettings,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    bool? isProfileVerified,
    bool? isBusinessVerified,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? this.status,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      nickname: nickname ?? this.nickname,
      region: region ?? this.region,
      snsAccounts: snsAccounts ?? this.snsAccounts,
      followersCount: followersCount ?? this.followersCount,
      categories: categories ?? this.categories,
      introduction: introduction ?? this.introduction,
      pricePolicy: pricePolicy ?? this.pricePolicy,
      priceAmount: priceAmount ?? this.priceAmount,
      availableTime: availableTime ?? this.availableTime,
      portfolio: portfolio ?? this.portfolio,
      company: company ?? this.company,
      manager: manager ?? this.manager,
      businessFile: businessFile ?? this.businessFile,
      sector: sector ?? this.sector,
      brand: brand ?? this.brand,
      alarmSettings: alarmSettings ?? this.alarmSettings,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isProfileVerified: isProfileVerified ?? this.isProfileVerified,
      isBusinessVerified: isBusinessVerified ?? this.isBusinessVerified,
    );
  }
}
