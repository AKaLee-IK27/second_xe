import '../../models/models.dart';
import 'base_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class VehiclePostRepository extends BaseRepository {
  final SupabaseClient _client = SupabaseService.client;
  final String _tableName = 'VehiclePost';

  @override
  String get tableName => _tableName;

  // Get all vehicle posts
  Future<List<VehiclePostModel>> getAllPosts() async {
    final data = await getAll();
    return data.map((json) => VehiclePostModel.fromJson(json)).toList();
  }

  // Get vehicle post by ID
  Future<VehiclePostModel?> getPostById(String id) async {
    final data = await getById(id);
    return data != null ? VehiclePostModel.fromJson(data) : null;
  }

  // Create vehicle post
  Future<VehiclePostModel> createPost({
    required String title,
    required int year,
    required int mileage,
    required String brand,
    required String model,
    required String location,
    required double price,
    required String description,
    required List<String> imageUrls,
    required Map<String, bool> features,
  }) async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final selectedFeatures = features.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();
      // Create the post
      final response = await _client.from(_tableName).insert({
        'user_id': user.id,
        'title': title,
        'year': year,
        'mileage': mileage,
        'brand': brand,
        'model': model,
        'location': location,
        'price': price,
        'description': description,
        'image_urls': imageUrls,
        'features': selectedFeatures,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).select().single();

      return VehiclePostModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  // Delete vehicle post
  Future<void> deletePost(String id) async {
    await delete(id);
  }

  // Get posts by user ID
  Future<List<VehiclePostModel>> getPostsByUserId(String userId) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response
          .map<VehiclePostModel>((json) => VehiclePostModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch posts by user ID: $e');
    }
  }

  // Get posts by status
  Future<List<VehiclePostModel>> getPostsByStatus(VehicleStatus status) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('status', status.value)
          .order('created_at', ascending: false);

      return response
          .map<VehiclePostModel>((json) => VehiclePostModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch posts by status: $e');
    }
  }

  // Get available posts (active and not expired)
  Future<List<VehiclePostModel>> getAvailablePosts() async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await _client
          .from(_tableName)
          .select()
          .eq('status', 'available')
          .or('expire_at.is.null,expire_at.gt.$now')
          .order('created_at', ascending: false);

      return response
          .map<VehiclePostModel>((json) => VehiclePostModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch available posts: $e');
    }
  }

  // Search posts by brand, model, or title
  Future<List<VehiclePostModel>> searchPosts(String query) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .or('title.ilike.%$query%,brand.ilike.%$query%,model.ilike.%$query%')
          .eq('status', 'available')
          .order('created_at', ascending: false);

      return response
          .map<VehiclePostModel>((json) => VehiclePostModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to search posts: $e');
    }
  }

  // Filter posts by price range
  Future<List<VehiclePostModel>> getPostsByPriceRange({
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      var query = _client.from(_tableName).select().eq('status', 'available');

      if (minPrice != null) {
        query = query.gte('price', minPrice);
      }
      if (maxPrice != null) {
        query = query.lte('price', maxPrice);
      }

      final response = await query.order('price', ascending: true);

      return response
          .map<VehiclePostModel>((json) => VehiclePostModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch posts by price range: $e');
    }
  }

  // Filter posts by year range
  Future<List<VehiclePostModel>> getPostsByYearRange({
    int? minYear,
    int? maxYear,
  }) async {
    try {
      var query = _client.from(_tableName).select().eq('status', 'available');

      if (minYear != null) {
        query = query.gte('year', minYear);
      }
      if (maxYear != null) {
        query = query.lte('year', maxYear);
      }

      final response = await query.order('year', ascending: false);

      return response
          .map<VehiclePostModel>((json) => VehiclePostModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch posts by year range: $e');
    }
  }

  // Get posts by brand
  Future<List<VehiclePostModel>> getPostsByBrand(String brand) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('brand', brand)
          .eq('status', 'available')
          .order('created_at', ascending: false);

      return response
          .map<VehiclePostModel>((json) => VehiclePostModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch posts by brand: $e');
    }
  }

  // Get posts by location
  Future<List<VehiclePostModel>> getPostsByLocation(String location) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .ilike('location', '%$location%')
          .eq('status', 'available')
          .order('created_at', ascending: false);

      return response
          .map<VehiclePostModel>((json) => VehiclePostModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch posts by location: $e');
    }
  }

  // Update post status
  Future<VehiclePostModel> updatePostStatus(
    String id,
    VehicleStatus status,
  ) async {
    try {
      final response =
          await _client
              .from(_tableName)
              .update({
                'status': status.value,
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('id', id)
              .select()
              .single();

      return VehiclePostModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update post status: $e');
    }
  }

  // Get expired posts
  Future<List<VehiclePostModel>> getExpiredPosts() async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await _client
          .from(_tableName)
          .select()
          .lt('expire_at', now)
          .neq('status', 'expired')
          .order('expire_at', ascending: true);

      return response
          .map<VehiclePostModel>((json) => VehiclePostModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch expired posts: $e');
    }
  }

  // Get recent posts
  Future<List<VehiclePostModel>> getRecentPosts({int limit = 10}) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('status', 'available')
          .order('created_at', ascending: false)
          .limit(limit);

      return response
          .map<VehiclePostModel>((json) => VehiclePostModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch recent posts: $e');
    }
  }

  // Get featured posts (posts with images and complete information)
  Future<List<VehiclePostModel>> getFeaturedPosts({int limit = 10}) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('status', 'available')
          .not('image_urls', 'is', null)
          .not('price', 'is', null)
          .not('year', 'is', null)
          .order('created_at', ascending: false)
          .limit(limit);

      return response
          .map<VehiclePostModel>((json) => VehiclePostModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch featured posts: $e');
    }
  }

  // Get posts count
  Future<int> getPostsCount() async {
    try {
      final response = await _client.from(_tableName).select('id');
      return response.length;
    } catch (e) {
      throw Exception('Failed to get posts count: $e');
    }
  }

  // Get posts count by status
  Future<int> getPostsCountByStatus(VehicleStatus status) async {
    try {
      final response = await _client
          .from(_tableName)
          .select('id')
          .eq('status', status.value);
      return response.length;
    } catch (e) {
      throw Exception('Failed to get posts count by status: $e');
    }
  }

  // Get unique brands
  Future<List<String>> getUniqueBrands() async {
    try {
      final response = await _client
          .from(_tableName)
          .select('brand')
          .not('brand', 'is', null);

      final brands =
          response
              .map<String>((json) => json['brand'] as String)
              .toSet()
              .toList();

      brands.sort();
      return brands;
    } catch (e) {
      throw Exception('Failed to fetch unique brands: $e');
    }
  }

  // Advanced filter with multiple criteria
  Future<List<VehiclePostModel>> filterPosts({
    String? brand,
    String? model,
    int? minYear,
    int? maxYear,
    double? minPrice,
    double? maxPrice,
    String? location,
    VehicleStatus? status,
    int limit = 50,
  }) async {
    try {
      var query = _client.from(_tableName).select();

      if (brand != null) {
        query = query.eq('brand', brand);
      }
      if (model != null) {
        query = query.eq('model', model);
      }
      if (minYear != null) {
        query = query.gte('year', minYear);
      }
      if (maxYear != null) {
        query = query.lte('year', maxYear);
      }
      if (minPrice != null) {
        query = query.gte('price', minPrice);
      }
      if (maxPrice != null) {
        query = query.lte('price', maxPrice);
      }
      if (location != null) {
        query = query.ilike('location', '%$location%');
      }
      if (status != null) {
        query = query.eq('status', status.value);
      } else {
        query = query.eq('status', 'available'); // Default to available
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(limit);

      return response
          .map<VehiclePostModel>((json) => VehiclePostModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to filter posts: $e');
    }
  }

  Future<List<VehiclePostModel>> getUserPosts() async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response = await _client
          .from(_tableName)
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return response.map((json) => VehiclePostModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get user posts: $e');
    }
  }

  Future<void> updatePost(String id, Map<String, dynamic> data) async {
    try {
      await _client
          .from(_tableName)
          .update({
            ...data,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to update post: $e');
    }
  }

  Future<List<VehiclePostModel>> getPostsByUserAndStatus(String userId, List<String> statuses) async {
    final response = await _client
        .from(_tableName)
        .select()
        .eq('user_id', userId)
        .inFilter('status', statuses);
    return (response as List)
        .map((json) => VehiclePostModel.fromJson(json))
        .toList();
  }
}
