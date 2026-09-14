class LiveLocation {
  const LiveLocation({
    this.address,
    this.lastUpdated,
    this.latitude,
    this.longitude,
  });

  final String? address;
  final String? lastUpdated;
  final double? latitude;
  final double? longitude;

  factory LiveLocation.fromMap(Map<String, dynamic> data) {
    return LiveLocation(
      address: data['address']?.toString().trim(),
      lastUpdated: data['lastUpdated']?.toString().trim(),
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
    );
  }
}

class LiveLocationResult {
  const LiveLocationResult.success(this.location) : errorMessage = null;

  const LiveLocationResult.failure(this.errorMessage) : location = null;

  final LiveLocation? location;
  final String? errorMessage;

  bool get isSuccess => location != null;
}
