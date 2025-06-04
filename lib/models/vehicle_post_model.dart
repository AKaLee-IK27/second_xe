enum VehicleStatus {
  available('available'),
  sold('sold'),
  pending('pending'),
  expired('expired');

  const VehicleStatus(this.value);
  final String value;

  static VehicleStatus fromString(String value) {
    return VehicleStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => VehicleStatus.pending,
    );
  }
}

class VehiclePostModel {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final List<String>? imageUrls;
  final String? brand;
  final String? model;
  final int? year;
  final double? price;
  final String? location;
  final int? mileage;
  final VehicleStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? expireAt;

  VehiclePostModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.imageUrls,
    this.brand,
    this.model,
    this.year,
    this.price,
    this.location,
    this.mileage,
    this.status = VehicleStatus.pending,
    required this.createdAt,
    required this.updatedAt,
    this.expireAt,
  });

  // Create VehiclePostModel from JSON
  factory VehiclePostModel.fromJson(Map<String, dynamic> json) {
    List<String>? imageUrls;
    if (json['imageURL'] != null) {
      if (json['imageURL'] is List) {
        imageUrls = List<String>.from(json['imageURL']);
      } else if (json['imageURL'] is String) {
        // Handle single string case
        imageUrls = [json['imageURL'] as String];
      }
    }

    return VehiclePostModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      imageUrls: imageUrls,
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      year: json['year'] as int?,
      price: json['price']?.toDouble(),
      location: json['location'] as String?,
      mileage: json['mileage'] as int?,
      status: VehicleStatus.fromString(json['status'] as String? ?? 'pending'),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      expireAt:
          json['expire_at'] != null
              ? DateTime.parse(json['expire_at'] as String)
              : null,
    );
  }

  // Convert VehiclePostModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'imageURL': imageUrls,
      'brand': brand,
      'model': model,
      'year': year,
      'price': price,
      'location': location,
      'mileage': mileage,
      'status': status.value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'expire_at': expireAt?.toIso8601String(),
    };
  }

  // Convert to JSON for database insertion (without id, created_at, updated_at)
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'title': title,
      'description': description,
      'imageURL': imageUrls,
      'brand': brand,
      'model': model,
      'year': year,
      'price': price,
      'location': location,
      'mileage': mileage,
      'status': status.value,
      'expire_at': expireAt?.toIso8601String(),
    };
  }

  // Convert to JSON for database update
  Map<String, dynamic> toUpdateJson() {
    return {
      'title': title,
      'description': description,
      'imageURL': imageUrls,
      'brand': brand,
      'model': model,
      'year': year,
      'price': price,
      'location': location,
      'mileage': mileage,
      'status': status.value,
      'updated_at': DateTime.now().toIso8601String(),
      'expire_at': expireAt?.toIso8601String(),
    };
  }

  // Copy with method for creating modified instances
  VehiclePostModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    List<String>? imageUrls,
    String? brand,
    String? model,
    int? year,
    double? price,
    String? location,
    int? mileage,
    VehicleStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? expireAt,
  }) {
    return VehiclePostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      price: price ?? this.price,
      location: location ?? this.location,
      mileage: mileage ?? this.mileage,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expireAt: expireAt ?? this.expireAt,
    );
  }

  // Formatted price string
  String get formattedPrice {
    if (price == null) return 'Price not specified';
    return '\$${price!.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  // Formatted mileage string
  String get formattedMileage {
    if (mileage == null) return 'Mileage not specified';
    return '${mileage!.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} km';
  }

  // Full vehicle name
  String get fullVehicleName {
    final parts = <String>[];
    if (brand != null && brand!.isNotEmpty) parts.add(brand!);
    if (model != null && model!.isNotEmpty) parts.add(model!);
    if (year != null) parts.add(year.toString());

    return parts.isNotEmpty ? parts.join(' ') : title;
  }

  // Check if post is expired
  bool get isExpired {
    if (expireAt == null) return false;
    return DateTime.now().isAfter(expireAt!);
  }

  // Check if post is available for purchase
  bool get isAvailable => status == VehicleStatus.available && !isExpired;

  // Days until expiration
  int? get daysUntilExpiration {
    if (expireAt == null) return null;
    final difference = expireAt!.difference(DateTime.now());
    return difference.inDays;
  }

  // Primary image URL
  String? get primaryImageUrl {
    if (imageUrls == null || imageUrls!.isEmpty) return null;
    return imageUrls!.first;
  }

  // Image count
  int get imageCount => imageUrls?.length ?? 0;

  @override
  String toString() {
    return 'VehiclePostModel(id: $id, title: $title, brand: $brand, model: $model, year: $year, price: $price, status: ${status.value})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VehiclePostModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
