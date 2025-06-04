import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/supabase_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated =>
      _status == AuthStatus.authenticated && _user != null;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    // Listen to auth state changes
    SupabaseService.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        _user = session.user;
        _status = AuthStatus.authenticated;
      } else {
        _user = null;
        _status = AuthStatus.unauthenticated;
      }
      notifyListeners();
    });

    // Check current session
    final session = SupabaseService.client.auth.currentSession;
    if (session != null) {
      _user = session.user;
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // Sign In
  Future<bool> signIn({required String email, required String password}) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await SupabaseService.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _user = response.user;
        _status = AuthStatus.authenticated;
        _setLoading(false);
        return true;
      } else {
        _setError('Sign in failed. Please try again.');
        return false;
      }
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
      return false;
    }
  }

  // Sign Up
  Future<bool> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await SupabaseService.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Update user metadata with full name if provided
        if (fullName != null && fullName.isNotEmpty) {
          await updateProfile(fullName: fullName);
        }

        _user = response.user;
        _status = AuthStatus.authenticated;
        _setLoading(false);
        return true;
      } else {
        _setError('Sign up failed. Please try again.');
        return false;
      }
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
      return false;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await SupabaseService.signOut();
      _user = null;
      _status = AuthStatus.unauthenticated;
      _setLoading(false);
    } catch (e) {
      _setError('Failed to sign out. Please try again.');
    }
  }

  // Forgot Password
  Future<bool> forgotPassword({required String email}) async {
    try {
      _setLoading(true);
      _clearError();

      await SupabaseService.client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.second_xe://reset-password/',
      );

      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Failed to send reset email. Please try again.');
      return false;
    }
  }

  // Reset Password
  Future<bool> resetPassword({required String newPassword}) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await SupabaseService.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (response.user != null) {
        _setLoading(false);
        return true;
      } else {
        _setError('Failed to reset password. Please try again.');
        return false;
      }
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
      return false;
    }
  }

  // Update Profile
  Future<bool> updateProfile({String? fullName, String? avatarUrl}) async {
    try {
      _setLoading(true);
      _clearError();

      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      final response = await SupabaseService.client.auth.updateUser(
        UserAttributes(data: updates),
      );

      if (response.user != null) {
        _user = response.user;
        _setLoading(false);
        return true;
      } else {
        _setError('Failed to update profile. Please try again.');
        return false;
      }
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
      return false;
    }
  }

  // Get user display name
  String get displayName {
    if (_user?.userMetadata?['full_name'] != null) {
      return _user!.userMetadata!['full_name'];
    }
    if (_user?.email != null) {
      return _user!.email!.split('@').first;
    }
    return 'User';
  }

  // Get user avatar URL
  String? get avatarUrl {
    return _user?.userMetadata?['avatar_url'];
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _status = AuthStatus.error;
    _isLoading = false;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status =
          _user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
