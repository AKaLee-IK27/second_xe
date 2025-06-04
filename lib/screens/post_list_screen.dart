import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:second_xe/core/styles/colors.dart';
import 'package:second_xe/core/styles/text_styles.dart';
import 'package:second_xe/providers/vehicle_provider.dart';
import 'package:second_xe/providers/favourite_provider.dart';
import 'package:second_xe/screens/post_detail_screen.dart';
import 'package:second_xe/screens/utils/sizes.dart';
import 'package:second_xe/widgets/car_card.dart';
import 'package:second_xe/widgets/filter_dialog.dart';

class PostListScreen extends StatefulWidget {
  final String? title;
  final String? filterType;
  final Map<String, dynamic>? initialFilters;

  const PostListScreen({
    super.key,
    this.title,
    this.filterType,
    this.initialFilters,
  });

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _currentSortOption = 'newest';
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
      // Initialize favorites for quick checking
      context.read<FavouriteProvider>().initializeFavourites();
    });
  }

  void _loadInitialData() {
    final vehicleProvider = context.read<VehicleProvider>();

    if (widget.filterType != null) {
      switch (widget.filterType) {
        case 'featured':
          vehicleProvider.loadFeaturedVehicles(limit: 50);
          break;
        case 'recent':
          vehicleProvider.loadRecentVehicles(limit: 50);
          break;
        case 'brand':
          if (widget.initialFilters?['brand'] != null) {
            vehicleProvider.loadVehiclesByBrand(
              widget.initialFilters!['brand'],
            );
          }
          break;
        case 'price_range':
          if (widget.initialFilters?['minPrice'] != null &&
              widget.initialFilters?['maxPrice'] != null) {
            vehicleProvider.loadVehiclesByPriceRange(
              widget.initialFilters!['minPrice'],
              widget.initialFilters!['maxPrice'],
            );
          }
          break;
        default:
          vehicleProvider.loadVehicles();
      }
    } else {
      vehicleProvider.loadVehicles();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: () => context.read<VehicleProvider>().refresh(),
        child: Column(
          children: [
            _buildSearchAndFilterBar(),
            _buildSortAndViewBar(),
            Expanded(child: _buildVehiclesList()),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Consumer<VehicleProvider>(
        builder: (context, vehicleProvider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title ?? 'All Cars',
                style: AppTextStyles.headline2.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (vehicleProvider.state == VehicleLoadingState.loaded)
                Text(
                  '${vehicleProvider.vehiclesCount} cars found',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
            ],
          );
        },
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isGridView ? Icons.view_list : Icons.grid_view,
            color: Colors.black,
          ),
          onPressed: () {
            setState(() {
              _isGridView = !_isGridView;
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.black),
          onPressed: _showMoreOptions,
        ),
      ],
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search cars, brands, models...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                  suffixIcon:
                      _searchController.text.isNotEmpty
                          ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey[500]),
                            onPressed: () {
                              _searchController.clear();
                              context.read<VehicleProvider>().loadVehicles();
                            },
                          )
                          : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onSubmitted: (query) {
                  if (query.trim().isNotEmpty) {
                    context.read<VehicleProvider>().searchVehicles(
                      query.trim(),
                    );
                  } else {
                    context.read<VehicleProvider>().loadVehicles();
                  }
                },
                onChanged: (value) {
                  setState(() {}); // Rebuild to show/hide clear button
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.tune, color: Colors.white),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const FilterDialog(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortAndViewBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            'Sort by:',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _currentSortOption,
                isDense: true,
                items: const [
                  DropdownMenuItem(
                    value: 'newest',
                    child: Text('Newest First'),
                  ),
                  DropdownMenuItem(
                    value: 'oldest',
                    child: Text('Oldest First'),
                  ),
                  DropdownMenuItem(
                    value: 'price_low',
                    child: Text('Price: Low to High'),
                  ),
                  DropdownMenuItem(
                    value: 'price_high',
                    child: Text('Price: High to Low'),
                  ),
                  DropdownMenuItem(
                    value: 'year_new',
                    child: Text('Year: Newest'),
                  ),
                  DropdownMenuItem(
                    value: 'year_old',
                    child: Text('Year: Oldest'),
                  ),
                  DropdownMenuItem(
                    value: 'mileage_low',
                    child: Text('Mileage: Low to High'),
                  ),
                  DropdownMenuItem(
                    value: 'mileage_high',
                    child: Text('Mileage: High to Low'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _currentSortOption = value;
                    });
                    _applySorting(value);
                  }
                },
              ),
            ),
          ),
          Consumer<VehicleProvider>(
            builder: (context, vehicleProvider, child) {
              if (vehicleProvider.selectedBrand != null ||
                  vehicleProvider.minPrice != null ||
                  vehicleProvider.searchQuery.isNotEmpty) {
                return TextButton.icon(
                  onPressed: () {
                    vehicleProvider.clearFilters();
                    _searchController.clear();
                    setState(() {
                      _currentSortOption = 'newest';
                    });
                  },
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Clear', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVehiclesList() {
    return Consumer<VehicleProvider>(
      builder: (context, vehicleProvider, child) {
        if (vehicleProvider.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading cars...'),
              ],
            ),
          );
        }

        if (vehicleProvider.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  16.h,
                  Text(
                    'Oops! Something went wrong',
                    style: AppTextStyles.headline2.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  8.h,
                  Text(
                    vehicleProvider.errorMessage ?? 'Failed to load cars',
                    style: TextStyle(color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                  24.h,
                  ElevatedButton.icon(
                    onPressed: () => vehicleProvider.refresh(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (vehicleProvider.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                  16.h,
                  Text(
                    'No cars found',
                    style: AppTextStyles.headline2.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  8.h,
                  Text(
                    'Try adjusting your search terms or filters',
                    style: TextStyle(color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                  24.h,
                  ElevatedButton.icon(
                    onPressed: () {
                      vehicleProvider.clearFilters();
                      _searchController.clear();
                      setState(() {
                        _currentSortOption = 'newest';
                      });
                    },
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear Filters'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return _isGridView
            ? _buildGridView(vehicleProvider)
            : _buildListView(vehicleProvider);
      },
    );
  }

  Widget _buildListView(VehicleProvider vehicleProvider) {
    return Consumer<FavouriteProvider>(
      builder: (context, favouriteProvider, child) {
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: vehicleProvider.vehicles.length,
          itemBuilder: (context, index) {
            final vehicle = vehicleProvider.vehicles[index];
            return CarCard(
              vehicle: vehicle,
              isFavorite: favouriteProvider.isFavorited(vehicle.id),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostDetailScreen(carId: vehicle.id),
                  ),
                );
              },
              onFavorite: () {
                _handleFavorite(vehicle, favouriteProvider);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildGridView(VehicleProvider vehicleProvider) {
    return Consumer<FavouriteProvider>(
      builder: (context, favouriteProvider, child) {
        return GridView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: vehicleProvider.vehicles.length,
          itemBuilder: (context, index) {
            final vehicle = vehicleProvider.vehicles[index];
            return _buildGridCard(vehicle, favouriteProvider);
          },
        );
      },
    );
  }

  Widget _buildGridCard(vehicle, FavouriteProvider favouriteProvider) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(carId: vehicle.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      child:
                          vehicle.imageUrls != null &&
                                  vehicle.imageUrls!.isNotEmpty
                              ? Image.network(
                                vehicle.primaryImageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[200],
                                    child: Icon(
                                      Icons.directions_car,
                                      size: 40,
                                      color: Colors.grey[400],
                                    ),
                                  );
                                },
                              )
                              : Container(
                                color: Colors.grey[200],
                                child: Icon(
                                  Icons.directions_car,
                                  size: 40,
                                  color: Colors.grey[400],
                                ),
                              ),
                    ),
                  ),
                  // Favorite button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _handleFavorite(vehicle, favouriteProvider),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          favouriteProvider.isFavorited(vehicle.id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color:
                              favouriteProvider.isFavorited(vehicle.id)
                                  ? Colors.red
                                  : Colors.grey,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title
                    Text(
                      vehicle.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Details
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vehicle.fullVehicleName,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          vehicle.formattedPrice,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applySorting(String sortOption) {
    final vehicleProvider = context.read<VehicleProvider>();

    switch (sortOption) {
      case 'newest':
        vehicleProvider.sortVehicles(VehicleSortOption.newest);
        break;
      case 'oldest':
        vehicleProvider.sortVehicles(VehicleSortOption.oldest);
        break;
      case 'price_low':
        vehicleProvider.sortVehicles(VehicleSortOption.priceAsc);
        break;
      case 'price_high':
        vehicleProvider.sortVehicles(VehicleSortOption.priceDesc);
        break;
      case 'year_new':
        vehicleProvider.sortVehicles(VehicleSortOption.yearDesc);
        break;
      case 'year_old':
        vehicleProvider.sortVehicles(VehicleSortOption.yearAsc);
        break;
      case 'mileage_low':
        vehicleProvider.sortVehicles(VehicleSortOption.mileageAsc);
        break;
      case 'mileage_high':
        vehicleProvider.sortVehicles(VehicleSortOption.mileageDesc);
        break;
    }
  }

  void _handleFavorite(vehicle, FavouriteProvider favouriteProvider) {
    favouriteProvider.toggleFavourite(vehicle.id).then((isNowFavorited) {
      final message =
          isNowFavorited
              ? 'Added ${vehicle.title} to favorites'
              : 'Removed ${vehicle.title} from favorites';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              isNowFavorited ? AppColors.primary : Colors.grey[600],
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Options',
                style: AppTextStyles.headline2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Refresh'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<VehicleProvider>().refresh();
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share Search'),
                onTap: () {
                  Navigator.pop(context);
                  // Implement share functionality
                },
              ),
              ListTile(
                leading: const Icon(Icons.bookmark_add),
                title: const Text('Save Search'),
                onTap: () {
                  Navigator.pop(context);
                  // Implement save search functionality
                },
              ),
              ListTile(
                leading: const Icon(Icons.bug_report),
                title: const Text('Report Issue'),
                onTap: () {
                  Navigator.pop(context);
                  // Implement report functionality
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
