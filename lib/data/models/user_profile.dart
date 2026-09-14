class UserProfile {
  const UserProfile({
    required this.id,
    this.name = '',
    this.email = '',
    this.phone = '',
    this.company = '',
    this.address = '',
    this.country = '',
    this.language = 'English',
    this.customerId = '',
    this.notificationsEnabled = true,
    this.profilePhoto,
    this.profilePhotoPath,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String company;
  final String address;
  final String country;
  final String language;
  final String customerId;
  final bool notificationsEnabled;
  final dynamic profilePhoto;
  final String? profilePhotoPath;

  factory UserProfile.fromMap(String id, Map<String, dynamic>? data) {
    final source = data ?? const <String, dynamic>{};
    return UserProfile(
      id: id,
      name: (source['name'] ?? '').toString(),
      email: (source['email'] ?? '').toString(),
      phone: (source['phone'] ?? '').toString(),
      company: (source['company'] ?? '').toString(),
      address: (source['address'] ?? '').toString(),
      country: (source['country'] ?? source['countryName'] ?? '').toString(),
      language: (source['language'] ?? 'English').toString(),
      customerId: (source['customerId'] ?? '').toString(),
      notificationsEnabled: source['notificationsEnabled'] as bool? ?? true,
      profilePhoto: source['profilePhoto'],
      profilePhotoPath: source['profilePhotoPath']?.toString(),
    );
  }
}
