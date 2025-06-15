import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:second_xe/core/repositories/base_repository.dart';
import 'package:second_xe/core/services/supabase_service.dart';
import 'package:second_xe/models/favourite_model.dart';
import 'package:second_xe/models/vehicle_post_model.dart';

class FavouriteRepository extends BaseRepository {
  @override
  String get tableName => 'Favourite';

  final String _postsTableName = 'VehiclePost';

  // Add vehicle to favorites
  Future<FavouriteModel> addToFavourites(String postId) async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Check if already favorited
      final existing =
          await client
              .from(tableName)
              .select()
              .eq('user_id', user.id)
              .eq('post_id', postId)
              .maybeSingle();

      if (existing != null) {
        throw Exception('Post is already in favorites');
      }

      final favourite = FavouriteModel(
        id: '', // Will be set by the database
        userId: user.id,
        postId: postId,
        createdAt: DateTime.now(),
      );

      final response =
          await client
              .from(tableName)
              .insert(favourite.toInsertJson())
              .select()
              .single();

      return FavouriteModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add to favorites: $e');
    }
  }

  // Remove vehicle from favorites
  Future<void> removeFromFavourites(String postId) async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      await client
          .from(tableName)
          .delete()
          .eq('user_id', user.id)
          .eq('post_id', postId);
    } catch (e) {
      throw Exception('Failed to remove from favorites: $e');
    }
  }

  // Check if vehicle is favorited by current user
  Future<bool> isFavorited(String postId) async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) {
        return false;
      }

      final response =
          await client
              .from(tableName)
              .select('id')
              .eq('user_id', user.id)
              .eq('post_id', postId)
              .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  // Get all user's favorite vehicles
  Future<List<VehiclePostModel>> getUserFavourites() async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // First get the favorite post IDs
      final favouriteResponse = await client
          .from(tableName)
          .select('post_id')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      if (favouriteResponse.isEmpty) {
        return [];
      }

      // Extract post IDs
      final postIds =
          favouriteResponse.map((item) => item['post_id'] as String).toList();

      // Then get the actual vehicle posts
      final vehicleResponse = await client
          .from(_postsTableName)
          .select('*')
          .inFilter('id', postIds);

      return vehicleResponse
          .map((item) => VehiclePostModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user favorites: $e');
    }
  }

  // Get favorite with additional info
  Future<List<FavouriteModel>> getUserFavouritesWithInfo() async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response = await client
          .from(tableName)
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return response.map((item) => FavouriteModel.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to get user favorites info: $e');
    }
  }

  // Get favorites count for a user
  Future<int> getUserFavouritesCount() async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) {
        return 0;
      }

      final response = await client
          .from(tableName)
          .select('id')
          .eq('user_id', user.id);

      return response.length;
    } catch (e) {
      return 0;
    }
  }

  // Toggle favorite status
  Future<bool> toggleFavourite(String postId) async {
    try {
      final isFavorited = await this.isFavorited(postId);

      if (isFavorited) {
        await removeFromFavourites(postId);
        return false;
      } else {
        await addToFavourites(postId);
        return true;
      }
    } catch (e) {
      throw Exception('Failed to toggle favorite: $e');
    }
  }

  // Clear all user favorites
  Future<void> clearAllFavourites() async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      await client.from(tableName).delete().eq('user_id', user.id);
    } catch (e) {
      throw Exception('Failed to clear favorites: $e');
    }
  }
}
