import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:second_xe/core/styles/colors.dart';
import 'package:second_xe/core/styles/text_styles.dart';
import 'package:second_xe/providers/vehicle_provider.dart';

class FilterDialog extends StatefulWidget {
  const FilterDialog({super.key});

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Filter state
  RangeValues _priceRange = const RangeValues(0, 100000);
  RangeValues _yearRange = const RangeValues(2015, 2024);
  String? _selectedBrand;
  String? _selectedLocation;
  int _selectedTabIndex = 0;

  // Available options
  final List<String> _brands = [
    'All Brands',
    'Audi',
    'BMW',
    'Ford',
    'Honda',
    'Hyundai',
    'Kia',
    'Mazda',
    'Mercedes',
    'Nissan',
    'Tesla',
    'Toyota',
    'Volkswagen',
  ];

  final List<String> _locations = [
    'All Locations',
    'District 1, Ho Chi Minh City',
    'District 2, Ho Chi Minh City',
    'District 3, Ho Chi Minh City',
    'District 7, Ho Chi Minh City',
    'District 10, Ho Chi Minh City',
    'District 12, Ho Chi Minh City',
    'Binh Thanh District, Ho Chi Minh City',
    'Go Vap District, Ho Chi Minh City',
    'Tan Binh District, Ho Chi Minh City',
    'Thu Duc City, Ho Chi Minh City',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedBrand = _brands.first;
    _selectedLocation = _locations.first;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Cars',
                  style: AppTextStyles.headline2.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: _clearFilters,
                      child: Text(
                        'Clear All',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Tabs
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.label,
            onTap: (index) {
              setState(() {
                _selectedTabIndex = index;
              });
            },
            tabs: const [
              Tab(text: "All Cars"),
              Tab(text: "New (2022+)"),
              Tab(text: "Used"),
            ],
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBrandDropdown(),
                    const SizedBox(height: 20),
                    _buildLocationDropdown(),
                    const SizedBox(height: 24),
                    _buildPriceRangeSlider(),
                    const SizedBox(height: 24),
                    _buildYearRangeSlider(),
                    const SizedBox(height: 32),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Brand',
          style: AppTextStyles.bodyText1.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedBrand,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down),
              items:
                  _brands.map((String brand) {
                    return DropdownMenuItem<String>(
                      value: brand,
                      child: Text(brand),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedBrand = newValue;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: AppTextStyles.bodyText1.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedLocation,
              isExpanded: true,
              icon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down),
                ],
              ),
              items:
                  _locations.map((String location) {
                    return DropdownMenuItem<String>(
                      value: location,
                      child: Text(location, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedLocation = newValue;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRangeSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Range',
          style: AppTextStyles.bodyText1.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '\$${_priceRange.start.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '\$${_priceRange.end.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: Colors.grey.shade300,
            trackHeight: 4.0,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withOpacity(0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
          ),
          child: RangeSlider(
            values: _priceRange,
            min: 0,
            max: 100000,
            divisions: 100,
            onChanged: (RangeValues values) {
              setState(() {
                _priceRange = values;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildYearRangeSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Year Range',
          style: AppTextStyles.bodyText1.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _yearRange.start.toInt().toString(),
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _yearRange.end.toInt().toString(),
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: Colors.grey.shade300,
            trackHeight: 4.0,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withOpacity(0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
          ),
          child: RangeSlider(
            values: _yearRange,
            min: 2015,
            max: 2024,
            divisions: 9,
            onChanged: (RangeValues values) {
              setState(() {
                _yearRange = values;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _applyFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              'Apply Filters',
              style: AppTextStyles.bodyText1.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _applyFilters() {
    final vehicleProvider = context.read<VehicleProvider>();

    // Determine filter parameters based on tab selection
    int? minYear;
    int? maxYear;

    switch (_selectedTabIndex) {
      case 1: // New cars (2022+)
        minYear = 2022;
        maxYear = _yearRange.end.toInt();
        break;
      case 2: // Used cars
        minYear = _yearRange.start.toInt();
        maxYear = 2021;
        break;
      default: // All cars
        minYear = _yearRange.start.toInt();
        maxYear = _yearRange.end.toInt();
        break;
    }

    // Apply filters
    vehicleProvider.filterVehicles(
      brand: _selectedBrand == 'All Brands' ? null : _selectedBrand,
      location: _selectedLocation == 'All Locations' ? null : _selectedLocation,
      minPrice: _priceRange.start,
      maxPrice: _priceRange.end,
      minYear: minYear,
      maxYear: maxYear,
    );

    // Show result and close dialog
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Filters applied successfully'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _priceRange = const RangeValues(0, 100000);
      _yearRange = const RangeValues(2015, 2024);
      _selectedBrand = _brands.first;
      _selectedLocation = _locations.first;
      _selectedTabIndex = 0;
      _tabController.animateTo(0);
    });
  }
}
