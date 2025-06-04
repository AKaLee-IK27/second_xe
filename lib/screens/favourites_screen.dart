import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:second_xe/core/styles/colors.dart';
import 'package:second_xe/core/styles/text_styles.dart';
import 'package:second_xe/providers/favourite_provider.dart';
import 'package:second_xe/screens/post_detail_screen.dart';
import 'package:second_xe/screens/utils/sizes.dart';
import 'package:second_xe/widgets/car_card.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _currentSortOption = 'newest';
  bool _isGridView = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavouriteProvider>().loadFavourites();
    });
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
        onRefresh: () => context.read<FavouriteProvider>().refresh(),
        child: Column(
          children: [
            _buildSearchBar(),
            _buildSortAndViewBar(),
            Expanded(child: _buildFavouritesList()),
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
      title: Consumer<FavouriteProvider>(
        builder: (context, favouriteProvider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'My Favorites',
                style: AppTextStyles.headline2.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (favouriteProvider.state == FavouriteLoadingState.loaded)
                Text(
                  '${favouriteProvider.favouritesCount} saved cars',
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
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.black),
          onSelected: _handleMenuSelection,
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      Icon(Icons.clear_all, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Clear All Favorites'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share),
                      SizedBox(width: 8),
                      Text('Share Favorites'),
                    ],
                  ),
                ),
              ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search your favorites...',
            hintStyle: TextStyle(color: Colors.grey[500]),
            prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
            suffixIcon:
                _searchController.text.isNotEmpty
                    ? IconButton(
                      icon: Icon(Icons.clear, color: Colors.grey[500]),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                    : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
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
                    child: Text('Recently Added'),
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
                    value: 'brand_az',
                    child: Text('Brand: A-Z'),
                  ),
                  DropdownMenuItem(
                    value: 'brand_za',
                    child: Text('Brand: Z-A'),
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
        ],
      ),
    );
  }

  Widget _buildFavouritesList() {
    return Consumer<FavouriteProvider>(
      builder: (context, favouriteProvider, child) {
        if (favouriteProvider.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading your favorites...'),
              ],
            ),
          );
        }

        if (favouriteProvider.hasError) {
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
                    favouriteProvider.errorMessage ??
                        'Failed to load favorites',
                    style: TextStyle(color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                  24.h,
                  ElevatedButton.icon(
                    onPressed: () => favouriteProvider.refresh(),
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

        if (favouriteProvider.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  24.h,
                  Text(
                    'No favorites yet',
                    style: AppTextStyles.headline2.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  8.h,
                  Text(
                    'Cars you favorite will appear here.\nStart browsing to save your favorites!',
                    style: TextStyle(color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                  24.h,
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.search),
                    label: const Text('Browse Cars'),
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

        // Apply search filter
        final filteredVehicles =
            _searchQuery.isEmpty
                ? favouriteProvider.favouriteVehicles
                : favouriteProvider.searchFavourites(_searchQuery);

        if (filteredVehicles.isEmpty && _searchQuery.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                  16.h,
                  Text(
                    'No matches found',
                    style: AppTextStyles.headline2.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  8.h,
                  Text(
                    'Try adjusting your search terms',
                    style: TextStyle(color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return _isGridView
            ? _buildGridView(filteredVehicles, favouriteProvider)
            : _buildListView(filteredVehicles, favouriteProvider);
      },
    );
  }

  Widget _buildListView(List vehicles, FavouriteProvider favouriteProvider) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: vehicles.length,
      itemBuilder: (context, index) {
        final vehicle = vehicles[index];
        return CarCard(
          vehicle: vehicle,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostDetailScreen(carId: vehicle.id),
              ),
            );
          },
          onFavorite: () => _handleFavorite(vehicle, favouriteProvider),
        );
      },
    );
  }

  Widget _buildGridView(List vehicles, FavouriteProvider favouriteProvider) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: vehicles.length,
      itemBuilder: (context, index) {
        final vehicle = vehicles[index];
        return _buildGridCard(vehicle, favouriteProvider);
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
                          Icons.favorite,
                          color: Colors.red,
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
    final favouriteProvider = context.read<FavouriteProvider>();

    switch (sortOption) {
      case 'newest':
        favouriteProvider.sortFavourites(FavouriteSortOption.newest);
        break;
      case 'oldest':
        favouriteProvider.sortFavourites(FavouriteSortOption.oldest);
        break;
      case 'price_low':
        favouriteProvider.sortFavourites(FavouriteSortOption.priceAsc);
        break;
      case 'price_high':
        favouriteProvider.sortFavourites(FavouriteSortOption.priceDesc);
        break;
      case 'brand_az':
        favouriteProvider.sortFavourites(FavouriteSortOption.brandAZ);
        break;
      case 'brand_za':
        favouriteProvider.sortFavourites(FavouriteSortOption.brandZA);
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

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'clear_all':
        _showClearAllDialog();
        break;
      case 'share':
        _shareFavorites();
        break;
    }
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear All Favorites'),
            content: const Text(
              'Are you sure you want to remove all vehicles from your favorites? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<FavouriteProvider>().clearAllFavourites().then((
                    _,
                  ) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('All favorites cleared'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  });
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Clear All',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _shareFavorites() {
    final favouriteProvider = context.read<FavouriteProvider>();
    final count = favouriteProvider.favouritesCount;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Check out my $count favorite cars on SecondXe!'),
        action: SnackBarAction(
          label: 'Share',
          onPressed: () {
            // Implement actual sharing functionality here
          },
        ),
      ),
    );
  }
}
