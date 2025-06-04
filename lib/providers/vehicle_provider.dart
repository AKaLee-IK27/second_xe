import 'package:flutter/material.dart';
import 'package:second_xe/core/repositories/repositories.dart';
import 'package:second_xe/models/models.dart';

enum VehicleLoadingState { initial, loading, loaded, error }

class VehicleProvider extends ChangeNotifier {
  final VehiclePostRepository _vehicleRepository = VehiclePostRepository();

  // State management
  VehicleLoadingState _state = VehicleLoadingState.initial;
  List<VehiclePostModel> _vehicles = [];
  String? _errorMessage;
  String _searchQuery = '';
  String? _selectedBrand;
  double? _minPrice;
  double? _maxPrice;

  // Getters
  VehicleLoadingState get state => _state;
  List<VehiclePostModel> get vehicles => _vehicles;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String? get selectedBrand => _selectedBrand;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;
  bool get isLoading => _state == VehicleLoadingState.loading;
  bool get hasError => _state == VehicleLoadingState.error;
  bool get isEmpty => _vehicles.isEmpty && _state == VehicleLoadingState.loaded;

  // Load all available vehicles
  Future<void> loadVehicles() async {
    try {
      _setState(VehicleLoadingState.loading);
      _clearError();

      final vehicles = await _vehicleRepository.getAvailablePosts();
      _vehicles = vehicles;
      _setState(VehicleLoadingState.loaded);
    } catch (e) {
      _setError('Failed to load vehicles: $e');
    }
  }

  // Search vehicles
  Future<void> searchVehicles(String query) async {
    try {
      _searchQuery = query;
      _setState(VehicleLoadingState.loading);
      _clearError();

      List<VehiclePostModel> vehicles;
      if (query.isEmpty) {
        vehicles = await _vehicleRepository.getAvailablePosts();
      } else {
        vehicles = await _vehicleRepository.searchPosts(query);
      }

      _vehicles = vehicles;
      _setState(VehicleLoadingState.loaded);
    } catch (e) {
      _setError('Failed to search vehicles: $e');
    }
  }

  // Filter vehicles with advanced criteria
  Future<void> filterVehicles({
    String? brand,
    String? model,
    int? minYear,
    int? maxYear,
    double? minPrice,
    double? maxPrice,
    String? location,
  }) async {
    try {
      _setState(VehicleLoadingState.loading);
      _clearError();

      // Update filter state
      _selectedBrand = brand;
      _minPrice = minPrice;
      _maxPrice = maxPrice;

      final vehicles = await _vehicleRepository.filterPosts(
        brand: brand,
        model: model,
        minYear: minYear,
        maxYear: maxYear,
        minPrice: minPrice,
        maxPrice: maxPrice,
        location: location,
      );

      _vehicles = vehicles;
      _setState(VehicleLoadingState.loaded);
    } catch (e) {
      _setError('Failed to filter vehicles: $e');
    }
  }

  // Get vehicles by brand
  Future<void> loadVehiclesByBrand(String brand) async {
    try {
      _selectedBrand = brand;
      _setState(VehicleLoadingState.loading);
      _clearError();

      final vehicles = await _vehicleRepository.getPostsByBrand(brand);
      _vehicles = vehicles;
      _setState(VehicleLoadingState.loaded);
    } catch (e) {
      _setError('Failed to load vehicles by brand: $e');
    }
  }

  // Get vehicles by price range
  Future<void> loadVehiclesByPriceRange(
    double minPrice,
    double maxPrice,
  ) async {
    try {
      _minPrice = minPrice;
      _maxPrice = maxPrice;
      _setState(VehicleLoadingState.loading);
      _clearError();

      final vehicles = await _vehicleRepository.getPostsByPriceRange(
        minPrice: minPrice,
        maxPrice: maxPrice,
      );
      _vehicles = vehicles;
      _setState(VehicleLoadingState.loaded);
    } catch (e) {
      _setError('Failed to load vehicles by price range: $e');
    }
  }

  // Get featured vehicles (with complete information and images)
  Future<void> loadFeaturedVehicles({int limit = 10}) async {
    try {
      _setState(VehicleLoadingState.loading);
      _clearError();

      final vehicles = await _vehicleRepository.getFeaturedPosts(limit: limit);
      _vehicles = vehicles;
      _setState(VehicleLoadingState.loaded);
    } catch (e) {
      _setError('Failed to load featured vehicles: $e');
    }
  }

  // Get recent vehicles
  Future<void> loadRecentVehicles({int limit = 10}) async {
    try {
      _setState(VehicleLoadingState.loading);
      _clearError();

      final vehicles = await _vehicleRepository.getRecentPosts(limit: limit);
      _vehicles = vehicles;
      _setState(VehicleLoadingState.loaded);
    } catch (e) {
      _setError('Failed to load recent vehicles: $e');
    }
  }

  // Get unique brands for filter options
  Future<List<String>> getAvailableBrands() async {
    try {
      return await _vehicleRepository.getUniqueBrands();
    } catch (e) {
      return [];
    }
  }

  // Clear all filters and reload
  Future<void> clearFilters() async {
    _searchQuery = '';
    _selectedBrand = null;
    _minPrice = null;
    _maxPrice = null;
    await loadVehicles();
  }

  // Refresh vehicles
  Future<void> refresh() async {
    await loadVehicles();
  }

  // Get vehicle by ID
  VehiclePostModel? getVehicleById(String id) {
    try {
      return _vehicles.firstWhere((vehicle) => vehicle.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get vehicles count
  int get vehiclesCount => _vehicles.length;

  // Sort vehicles
  void sortVehicles(VehicleSortOption sortOption) {
    switch (sortOption) {
      case VehicleSortOption.priceAsc:
        _vehicles.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
        break;
      case VehicleSortOption.priceDesc:
        _vehicles.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
        break;
      case VehicleSortOption.yearAsc:
        _vehicles.sort((a, b) => (a.year ?? 0).compareTo(b.year ?? 0));
        break;
      case VehicleSortOption.yearDesc:
        _vehicles.sort((a, b) => (b.year ?? 0).compareTo(a.year ?? 0));
        break;
      case VehicleSortOption.mileageAsc:
        _vehicles.sort((a, b) => (a.mileage ?? 0).compareTo(b.mileage ?? 0));
        break;
      case VehicleSortOption.mileageDesc:
        _vehicles.sort((a, b) => (b.mileage ?? 0).compareTo(a.mileage ?? 0));
        break;
      case VehicleSortOption.newest:
        _vehicles.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case VehicleSortOption.oldest:
        _vehicles.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
    }
    notifyListeners();
  }

  // Private helper methods
  void _setState(VehicleLoadingState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _state = VehicleLoadingState.error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}

// Enum for sorting options
enum VehicleSortOption {
  priceAsc,
  priceDesc,
  yearAsc,
  yearDesc,
  mileageAsc,
  mileageDesc,
  newest,
  oldest,
}
