import '../../models/models.dart';
import 'base_repository.dart';

class VehiclePostRepository extends BaseRepository {
  @override
  String get tableName => 'VehiclePost';

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
  Future<VehiclePostModel> createPost(VehiclePostModel post) async {
    final data = await create(post.toInsertJson());
    return VehiclePostModel.fromJson(data);
  }

  // Update vehicle post
  Future<VehiclePostModel> updatePost(String id, VehiclePostModel post) async {
    final data = await update(id, post.toUpdateJson());
    return VehiclePostModel.fromJson(data);
  }

  // Delete vehicle post
  Future<void> deletePost(String id) async {
    await delete(id);
  }

  // Get posts by user ID
  Future<List<VehiclePostModel>> getPostsByUserId(String userId) async {
    try {
      final response = await client
          .from(tableName)
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
      final response = await client
          .from(tableName)
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
      final response = await client
          .from(tableName)
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
      final response = await client
          .from(tableName)
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
      var query = client.from(tableName).select().eq('status', 'available');

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
      var query = client.from(tableName).select().eq('status', 'available');

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
      final response = await client
          .from(tableName)
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
      final response = await client
          .from(tableName)
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
          await client
              .from(tableName)
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
      final response = await client
          .from(tableName)
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
      final response = await client
          .from(tableName)
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
      final response = await client
          .from(tableName)
          .select()
          .eq('status', 'available')
          .not('imageURL', 'is', null)
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
      final response = await client.from(tableName).select('id');
      return response.length;
    } catch (e) {
      throw Exception('Failed to get posts count: $e');
    }
  }

  // Get posts count by status
  Future<int> getPostsCountByStatus(VehicleStatus status) async {
    try {
      final response = await client
          .from(tableName)
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
      final response = await client
          .from(tableName)
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
      var query = client.from(tableName).select();

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
}
