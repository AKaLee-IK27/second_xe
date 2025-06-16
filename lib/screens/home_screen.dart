import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:second_xe/core/styles/colors.dart';
import 'package:second_xe/core/styles/text_styles.dart';
import 'package:second_xe/providers/vehicle_provider.dart';
import 'package:second_xe/providers/favourite_provider.dart';
import 'package:second_xe/screens/post_detail_screen.dart';
import 'package:second_xe/screens/utils/routes.dart';
import 'package:second_xe/screens/utils/sizes.dart';
import 'package:second_xe/widgets/car_card.dart';
import 'package:second_xe/widgets/filter_dialog.dart';
import 'package:second_xe/screens/message_list_screen.dart';
import 'package:second_xe/screens/my_posts_screen.dart';
import 'package:second_xe/core/services/log_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VehicleProvider>().loadVehicles();
      context.read<FavouriteProvider>().initializeFavourites();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(),
      drawer: _buildDrawer(context),
      body: RefreshIndicator(
        onRefresh: () => context.read<VehicleProvider>().refresh(),
        child: _buildBody(),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: AppColors.primary),
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.library_books),
            title: Text('My Posts'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyPostsScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.message),
            title: Text('Messages'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MessageListScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.upload_file),
            title: Text('Export & Upload Logs'),
            onTap: () async {
              Navigator.pop(context);
              showDialog(
                context: context,
                barrierDismissible: false,
                builder:
                    (context) => Center(child: CircularProgressIndicator()),
              );
              try {
                final url = await LogService().exportAndUploadLogFile(
                  'uploads',
                );
                Navigator.pop(context); // Remove loading
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Log uploaded! URL: $url')),
                );
              } catch (e) {
                Navigator.pop(context); // Remove loading
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to upload log: $e')),
                );
              }
            },
          ),
          // Add more items as needed
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Builder(
        builder:
            (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
      ),
      title: Text(
        'XeShop',
        style: AppTextStyles.headline2.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody() {
    return Consumer<VehicleProvider>(
      builder: (context, vehicleProvider, child) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(),
                16.h,
                _buildFeaturedCarsSection(vehicleProvider),
                24.h,
                _buildAllVehiclesSection(vehicleProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for cars, brands, models...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 15),
              ),
              onSubmitted: (query) {
                if (query.trim().isNotEmpty) {
                  context.read<VehicleProvider>().searchVehicles(query.trim());
                } else {
                  context.read<VehicleProvider>().loadVehicles();
                }
              },
            ),
          ),
          Container(
            height: 30,
            width: 1,
            color: Colors.grey[300],
            margin: EdgeInsets.symmetric(horizontal: 8),
          ),
          IconButton(
            icon: Icon(Icons.tune, color: Colors.black),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (BuildContext context) {
                  return const FilterDialog();
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCarsSection(VehicleProvider vehicleProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Featured Cars',
              style: AppTextStyles.headline2.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                vehicleProvider.loadFeaturedVehicles(limit: 20);
              },
              child: Text('See all', style: TextStyle(color: Colors.grey[600])),
            ),
          ],
        ),
        8.h,
        SizedBox(
          height: 200,
          child:
              vehicleProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : vehicleProvider.hasError
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.grey[400],
                          size: 48,
                        ),
                        8.h,
                        Text(
                          vehicleProvider.errorMessage ?? 'Error loading cars',
                          style: TextStyle(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                        8.h,
                        ElevatedButton(
                          onPressed: () => vehicleProvider.refresh(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                  : vehicleProvider.vehicles.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.directions_car,
                          color: Colors.grey[400],
                          size: 48,
                        ),
                        8.h,
                        Text(
                          'No cars available',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                  : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount:
                        vehicleProvider.vehicles.length > 5
                            ? 5
                            : vehicleProvider.vehicles.length,
                    itemBuilder: (context, index) {
                      final vehicle = vehicleProvider.vehicles[index];
                      return Container(
                        width: 300,
                        margin: const EdgeInsets.only(right: 16),
                        child: _buildFeaturedCarCard(vehicle),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildFeaturedCarCard(vehicle) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(carId: vehicle.id),
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(
                  vehicle.primaryImageUrl ??
                      "https://images.unsplash.com/photo-1620891549027-942fdc95d3f5?q=80&w=1887&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.title,
                      style: AppTextStyles.bodyText1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    4.h,
                    Text(
                      vehicle.formattedPrice,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 20,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: Text(
                'Featured',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllVehiclesSection(VehicleProvider vehicleProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'All Vehicles',
              style: AppTextStyles.headline2.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Text(
                  '${vehicleProvider.vehiclesCount} cars',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                PopupMenuButton<VehicleSortOption>(
                  icon: Icon(Icons.sort, color: Colors.grey[600]),
                  onSelected: (option) {
                    vehicleProvider.sortVehicles(option);
                  },
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: VehicleSortOption.newest,
                          child: Text('Newest First'),
                        ),
                        const PopupMenuItem(
                          value: VehicleSortOption.priceAsc,
                          child: Text('Price: Low to High'),
                        ),
                        const PopupMenuItem(
                          value: VehicleSortOption.priceDesc,
                          child: Text('Price: High to Low'),
                        ),
                        const PopupMenuItem(
                          value: VehicleSortOption.yearDesc,
                          child: Text('Year: Newest'),
                        ),
                        const PopupMenuItem(
                          value: VehicleSortOption.mileageAsc,
                          child: Text('Mileage: Low to High'),
                        ),
                      ],
                ),
              ],
            ),
          ],
        ),
        16.h,
        if (vehicleProvider.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (vehicleProvider.hasError)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(Icons.error_outline, color: Colors.grey[400], size: 64),
                  16.h,
                  Text(
                    vehicleProvider.errorMessage ?? 'Error loading vehicles',
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  16.h,
                  ElevatedButton(
                    onPressed: () => vehicleProvider.refresh(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (vehicleProvider.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(Icons.directions_car, color: Colors.grey[400], size: 64),
                  16.h,
                  Text(
                    'No vehicles found',
                    style: AppTextStyles.bodyText1.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  8.h,
                  Text(
                    'Try adjusting your search or filters',
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: vehicleProvider.vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = vehicleProvider.vehicles[index];
              return Consumer<FavouriteProvider>(
                builder: (context, favouriteProvider, child) {
                  return CarCard(
                    vehicle: vehicle,
                    isFavorite: favouriteProvider.isFavorited(vehicle.id),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => PostDetailScreen(carId: vehicle.id),
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
          ),
      ],
    );
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

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == 1) {
              // Favorites tab
              Navigator.pushNamed(context, AppRoutes.favourites);
            } else if (index == 2) {
              Navigator.pushNamed(context, AppRoutes.createPost);
            } else if (index == 3) {
              // Profile tab
              Navigator.pushNamed(context, AppRoutes.editProfile);
            } else {
              setState(() {
                _currentIndex = index;
              });
            }
          },
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
            BottomNavigationBarItem(
              icon: Consumer<FavouriteProvider>(
                builder: (context, favouriteProvider, child) {
                  return Stack(
                    children: [
                      Icon(Icons.favorite_border),
                      if (favouriteProvider.favouritesCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 12,
                              minHeight: 12,
                            ),
                            child: Text(
                              '${favouriteProvider.favouritesCount}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: '',
            ),
          ],
        ),
      ),
    );
  }
}
