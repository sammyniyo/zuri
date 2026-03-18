class ZuriUser {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String? avatarUrl;
  final bool isPro;
  final DateTime? proExpiresAt;
  final int reviewCount;
  final int savedCount;
  final String loginMethod; // 'google' | 'phone'

  const ZuriUser({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.avatarUrl,
    this.isPro = false,
    this.proExpiresAt,
    this.reviewCount = 0,
    this.savedCount = 0,
    required this.loginMethod,
  });

  bool get isProActive {
    if (!isPro) return false;
    if (proExpiresAt == null) return false;
    return proExpiresAt!.isAfter(DateTime.now());
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'Z';
  }

  ZuriUser copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? avatarUrl,
    bool? isPro,
    DateTime? proExpiresAt,
    int? reviewCount,
    int? savedCount,
    String? loginMethod,
  }) {
    return ZuriUser(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isPro: isPro ?? this.isPro,
      proExpiresAt: proExpiresAt ?? this.proExpiresAt,
      reviewCount: reviewCount ?? this.reviewCount,
      savedCount: savedCount ?? this.savedCount,
      loginMethod: loginMethod ?? this.loginMethod,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'avatarUrl': avatarUrl,
        'isPro': isPro,
        'proExpiresAt': proExpiresAt?.toIso8601String(),
        'reviewCount': reviewCount,
        'savedCount': savedCount,
        'loginMethod': loginMethod,
      };

  factory ZuriUser.fromMap(Map<String, dynamic> map) => ZuriUser(
        id: map['id'] as String,
        name: map['name'] as String,
        phone: map['phone'] as String?,
        email: map['email'] as String?,
        avatarUrl: map['avatarUrl'] as String?,
        isPro: map['isPro'] as bool? ?? false,
        proExpiresAt: map['proExpiresAt'] != null
            ? DateTime.parse(map['proExpiresAt'] as String)
            : null,
        reviewCount: map['reviewCount'] as int? ?? 0,
        savedCount: map['savedCount'] as int? ?? 0,
        loginMethod: map['loginMethod'] as String? ?? 'phone',
      );
}
