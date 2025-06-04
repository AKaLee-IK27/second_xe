import 'package:flutter/material.dart';
import 'package:second_xe/core/repositories/repositories.dart';
import 'package:second_xe/models/models.dart';

enum FavouriteLoadingState { initial, loading, loaded, error }

class FavouriteProvider extends ChangeNotifier {
  final FavouriteRepository _favouriteRepository = FavouriteRepository();

  // State management
  FavouriteLoadingState _state = FavouriteLoadingState.initial;
  List<VehiclePostModel> _favouriteVehicles = [];
  Set<String> _favouritePostIds = {};
  String? _errorMessage;
  int _favouritesCount = 0;

  // Getters
  FavouriteLoadingState get state => _state;
  List<VehiclePostModel> get favouriteVehicles => _favouriteVehicles;
  Set<String> get favouritePostIds => _favouritePostIds;
  String? get errorMessage => _errorMessage;
  int get favouritesCount => _favouritesCount;
  bool get isLoading => _state == FavouriteLoadingState.loading;
  bool get hasError => _state == FavouriteLoadingState.error;
  bool get isEmpty =>
      _favouriteVehicles.isEmpty && _state == FavouriteLoadingState.loaded;

  // Check if a post is favorited
  bool isFavorited(String postId) => _favouritePostIds.contains(postId);

  // Load user's favorite vehicles
  Future<void> loadFavourites() async {
    try {
      _setState(FavouriteLoadingState.loading);
      _clearError();

      final vehicles = await _favouriteRepository.getUserFavourites();
      _favouriteVehicles = vehicles;
      _favouritePostIds = vehicles.map((v) => v.id).toSet();
      _favouritesCount = vehicles.length;

      _setState(FavouriteLoadingState.loaded);
    } catch (e) {
      _setError('Failed to load favorites: $e');
    }
  }

  // Add vehicle to favorites
  Future<bool> addToFavourites(String postId) async {
    try {
      await _favouriteRepository.addToFavourites(postId);
      _favouritePostIds.add(postId);
      _favouritesCount++;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to add to favorites: $e');
      return false;
    }
  }

  // Remove vehicle from favorites
  Future<bool> removeFromFavourites(String postId) async {
    try {
      await _favouriteRepository.removeFromFavourites(postId);
      _favouritePostIds.remove(postId);
      _favouriteVehicles.removeWhere((vehicle) => vehicle.id == postId);
      _favouritesCount--;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to remove from favorites: $e');
      return false;
    }
  }

  // Toggle favorite status
  Future<bool> toggleFavourite(String postId) async {
    try {
      final isNowFavorited = await _favouriteRepository.toggleFavourite(postId);

      if (isNowFavorited) {
        _favouritePostIds.add(postId);
        _favouritesCount++;
      } else {
        _favouritePostIds.remove(postId);
        _favouriteVehicles.removeWhere((vehicle) => vehicle.id == postId);
        _favouritesCount--;
      }

      notifyListeners();
      return isNowFavorited;
    } catch (e) {
      _setError('Failed to toggle favorite: $e');
      return _favouritePostIds.contains(postId);
    }
  }

  // Clear all favorites
  Future<void> clearAllFavourites() async {
    try {
      _setState(FavouriteLoadingState.loading);
      _clearError();

      await _favouriteRepository.clearAllFavourites();
      _favouriteVehicles.clear();
      _favouritePostIds.clear();
      _favouritesCount = 0;

      _setState(FavouriteLoadingState.loaded);
    } catch (e) {
      _setError('Failed to clear favorites: $e');
    }
  }

  // Refresh favorites
  Future<void> refresh() async {
    await loadFavourites();
  }

  // Load favorites count only
  Future<void> loadFavouritesCount() async {
    try {
      _favouritesCount = await _favouriteRepository.getUserFavouritesCount();
      notifyListeners();
    } catch (e) {
      // Silent fail for count
    }
  }

  // Initialize favorites (load IDs for quick checking)
  Future<void> initializeFavourites() async {
    try {
      final favourites = await _favouriteRepository.getUserFavouritesWithInfo();
      _favouritePostIds = favourites.map((f) => f.postId).toSet();
      _favouritesCount = favourites.length;
      notifyListeners();
    } catch (e) {
      // Silent fail for initialization
    }
  }

  // Search within favorites
  List<VehiclePostModel> searchFavourites(String query) {
    if (query.isEmpty) return _favouriteVehicles;

    return _favouriteVehicles.where((vehicle) {
      return vehicle.title.toLowerCase().contains(query.toLowerCase()) ||
          (vehicle.brand?.toLowerCase().contains(query.toLowerCase()) ??
              false) ||
          (vehicle.model?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();
  }

  // Sort favorites
  void sortFavourites(FavouriteSortOption sortOption) {
    switch (sortOption) {
      case FavouriteSortOption.newest:
        _favouriteVehicles.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case FavouriteSortOption.oldest:
        _favouriteVehicles.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case FavouriteSortOption.priceAsc:
        _favouriteVehicles.sort(
          (a, b) => (a.price ?? 0).compareTo(b.price ?? 0),
        );
        break;
      case FavouriteSortOption.priceDesc:
        _favouriteVehicles.sort(
          (a, b) => (b.price ?? 0).compareTo(a.price ?? 0),
        );
        break;
      case FavouriteSortOption.brandAZ:
        _favouriteVehicles.sort(
          (a, b) => (a.brand ?? '').compareTo(b.brand ?? ''),
        );
        break;
      case FavouriteSortOption.brandZA:
        _favouriteVehicles.sort(
          (a, b) => (b.brand ?? '').compareTo(a.brand ?? ''),
        );
        break;
    }
    notifyListeners();
  }

  // Private helper methods
  void _setState(FavouriteLoadingState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _state = FavouriteLoadingState.error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}

// Enum for sorting favorites
enum FavouriteSortOption {
  newest,
  oldest,
  priceAsc,
  priceDesc,
  brandAZ,
  brandZA,
}
