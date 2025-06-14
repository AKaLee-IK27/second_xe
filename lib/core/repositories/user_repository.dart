import '../../models/models.dart';
import 'base_repository.dart';
import '../../models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserRepository extends BaseRepository {
  @override
  String get tableName => 'User';

  // Get all users
  Future<List<UserModel>> getAllUsers() async {
    final data = await getAll();
    return data.map((json) => UserModel.fromJson(json)).toList();
  }

  // Get user by ID
  Future<UserModel?> getUserById(String id) async {
    final response =
        await client.from('User').select().eq('id', id).maybeSingle();
    if (response == null) return null;
    return UserModel.fromJson(response);
  }

  // Get user by auth ID
  Future<UserModel?> getUserByAuthId(String authId) async {
    try {
      final response =
          await client
              .from(tableName)
              .select()
              .eq('auth_id', authId)
              .maybeSingle();

      return response != null ? UserModel.fromJson(response) : null;
    } catch (e) {
      throw Exception('Failed to fetch user by auth ID: $e');
    }
  }

  // Get user by email
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final response =
          await client
              .from(tableName)
              .select()
              .eq('email', email)
              .maybeSingle();

      return response != null ? UserModel.fromJson(response) : null;
    } catch (e) {
      throw Exception('Failed to fetch user by email: $e');
    }
  }

  // Create user
  Future<UserModel> createUser(UserModel user) async {
    final data = await create(user.toInsertJson());
    return UserModel.fromJson(data);
  }

  // Update user
  Future<UserModel> updateUser(String id, UserModel user) async {
    final data = await update(id, user.toUpdateJson());
    return UserModel.fromJson(data);
  }

  // Delete user
  Future<void> deleteUser(String id) async {
    await delete(id);
  }

  // Get users by role
  Future<List<UserModel>> getUsersByRole(UserRole role) async {
    try {
      final response = await client
          .from(tableName)
          .select()
          .eq('role', role.value);

      return response
          .map<UserModel>((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch users by role: $e');
    }
  }

  // Get verified users
  Future<List<UserModel>> getVerifiedUsers() async {
    try {
      final response = await client
          .from(tableName)
          .select()
          .eq('is_verified', true);

      return response
          .map<UserModel>((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch verified users: $e');
    }
  }

  // Search users by name or email
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      final response = await client
          .from(tableName)
          .select()
          .or('full_name.ilike.%$query%,email.ilike.%$query%');

      return response
          .map<UserModel>((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  // Update user verification status
  Future<UserModel> updateVerificationStatus(String id, bool isVerified) async {
    try {
      final response =
          await client
              .from(tableName)
              .update({
                'is_verified': isVerified,
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('id', id)
              .select()
              .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update verification status: $e');
    }
  }

  // Update user role
  Future<UserModel> updateUserRole(String id, UserRole role) async {
    try {
      final response =
          await client
              .from(tableName)
              .update({
                'role': role.value,
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('id', id)
              .select()
              .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update user role: $e');
    }
  }

  // Get users count by querying all users (simple approach)
  Future<int> getUsersCount() async {
    try {
      final response = await client.from(tableName).select('id');
      return response.length;
    } catch (e) {
      throw Exception('Failed to get users count: $e');
    }
  }

  // Get recent users
  Future<List<UserModel>> getRecentUsers({int limit = 10}) async {
    try {
      final response = await client
          .from(tableName)
          .select()
          .order('created_at', ascending: false)
          .limit(limit);

      return response
          .map<UserModel>((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch recent users: $e');
    }
  }

  /// Ensures the current authenticated user exists in the User table.
  /// If not, creates the user with the same id as in auth.users.
  Future<UserModel> ensureCurrentUserInUserTable() async {
    final authUser = Supabase.instance.client.auth.currentUser;
    if (authUser == null) throw Exception('No authenticated user');
    final userId = authUser.id;
    final email = authUser.email;
    final fullName = authUser.userMetadata?['full_name'] ?? '';
    // Check if user exists
    final existing = await getUserById(userId);
    if (existing != null) return existing;
    // Insert user
    final now = DateTime.now();
    final user = UserModel(
      id: userId,
      authId: userId,
      email: email ?? '',
      fullName: fullName,
      createdAt: now,
      updatedAt: now,
      isVerified: false,
      role: UserRole.user,
    );
    return await createUser(user);
  }
}
