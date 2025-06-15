import 'package:flutter/material.dart';
import 'package:second_xe/core/styles/colors.dart';
import 'package:second_xe/core/styles/text_styles.dart';
import 'package:second_xe/screens/utils/sizes.dart';
import 'package:second_xe/widgets/image_picker_widget.dart';
import 'package:second_xe/core/repositories/vehicle_post_repository.dart';
import 'package:second_xe/screens/post_preview_screen.dart';
import 'package:second_xe/models/vehicle_type.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _mileageController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _engineCapacityController = TextEditingController();

  String? _selectedBrand;
  String? _selectedModel;
  String? _selectedTransmission;
  String? _selectedFuelType;
  VehicleType _selectedVehicleType = VehicleType.car;
  List<String> _selectedImages = [];
  static const int _maxImages = 5;

  final List<String> _carBrands = [
    'Audi',
    'BMW',
    'Mercedes',
    'Tesla',
    'Toyota',
    'Suzuki',
  ];

  final List<String> _motorbikeBrands = [
    'Honda',
    'Yamaha',
    'Suzuki',
    'Kawasaki',
    'Ducati',
    'BMW',
  ];

  final List<String> _carModels = [
    'Model 3',
    'X5',
    'C-Class',
    'Swift',
    'e-tron',
  ];

  final List<String> _motorbikeModels = [
    'CBR',
    'R1',
    'GSX-R',
    'Ninja',
    'Panigale',
    'S1000RR',
  ];

  final List<String> _transmissions = [
    'Manual',
    'Automatic',
    'CVT',
    'Semi-Automatic',
  ];

  final List<String> _fuelTypes = [
    'Petrol',
    'Diesel',
    'Electric',
    'Hybrid',
  ];

  final Map<String, bool> _selectedFeatures = {
    'Alarm': false,
    'Bluetooth': false,
    'Cruise Control': false,
    'Front Parking Sensor': false,
    'Rear Parking Sensor': false,
    'Climate Control': false,
    'Navigation System': false,
    'Leather Seats': false,
  };

  final VehiclePostRepository _postRepository = VehiclePostRepository();
  bool _isLoading = false;

  List<String> get _brands => _selectedVehicleType == VehicleType.car
      ? _carBrands
      : _motorbikeBrands;

  List<String> get _models => _selectedVehicleType == VehicleType.car
      ? _carModels
      : _motorbikeModels;

  @override
  void dispose() {
    _titleController.dispose();
    _yearController.dispose();
    _mileageController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _engineCapacityController.dispose();
    super.dispose();
  }

  void _handleImageUploaded(String imageUrl) {
    if (_selectedImages.length >= _maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum $_maxImages images allowed'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() {
      _selectedImages.add(imageUrl);
    });
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  String? _validateYear(String? value) {
    if (value == null || value.isEmpty) {
      return 'Year is required';
    }
    final year = int.tryParse(value);
    if (year == null) {
      return 'Please enter a valid year';
    }
    final currentYear = DateTime.now().year;
    if (year < 1900 || year > currentYear) {
      return 'Year must be between 1900 and $currentYear';
    }
    return null;
  }

  String? _validateMileage(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mileage is required';
    }
    final mileage = int.tryParse(value);
    if (mileage == null) {
      return 'Please enter a valid mileage';
    }
    if (mileage < 0) {
      return 'Mileage cannot be negative';
    }
    return null;
  }

  String? _validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Price is required';
    }
    final price = double.tryParse(value);
    if (price == null) {
      return 'Please enter a valid price';
    }
    if (price <= 0) {
      return 'Price must be greater than 0';
    }
    return null;
  }

  String? _validateEngineCapacity(String? value) {
    if (_selectedVehicleType == VehicleType.motorbike) {
      if (value == null || value.isEmpty) {
        return 'Engine capacity is required for motorbikes';
      }
      final capacity = int.tryParse(value);
      if (capacity == null) {
        return 'Please enter a valid engine capacity';
      }
      if (capacity <= 0) {
        return 'Engine capacity must be greater than 0';
      }
    }
    return null;
  }

  Future<void> _showPreview() async {
    // Validate all fields
    final yearError = _validateYear(_yearController.text);
    final mileageError = _validateMileage(_mileageController.text);
    final priceError = _validatePrice(_priceController.text);
    final engineCapacityError = _validateEngineCapacity(_engineCapacityController.text);

    if (_titleController.text.isEmpty ||
        yearError != null ||
        mileageError != null ||
        _selectedBrand == null ||
        _selectedModel == null ||
        _locationController.text.isEmpty ||
        priceError != null ||
        _descriptionController.text.isEmpty ||
        _selectedImages.isEmpty ||
        _selectedTransmission == null ||
        _selectedFuelType == null ||
        engineCapacityError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            yearError ??
                mileageError ??
                priceError ??
                engineCapacityError ??
                'Please fill all required fields and add at least one image',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show preview screen
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostPreviewScreen(
          title: _titleController.text,
          year: int.parse(_yearController.text),
          mileage: int.parse(_mileageController.text),
          brand: _selectedBrand!,
          model: _selectedModel!,
          location: _locationController.text,
          price: double.parse(_priceController.text),
          description: _descriptionController.text,
          imageUrls: _selectedImages,
          features: _selectedFeatures,
          vehicleType: _selectedVehicleType,
          engineCapacity: _selectedVehicleType == VehicleType.motorbike
              ? int.parse(_engineCapacityController.text)
              : null,
          transmission: _selectedTransmission!,
          fuelType: _selectedFuelType!,
          onConfirm: _handlePostCar,
        ),
      ),
    );
  }

  Future<void> _handlePostCar() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Create the post
      await _postRepository.createPost(
        title: _titleController.text,
        year: int.parse(_yearController.text),
        mileage: int.parse(_mileageController.text),
        brand: _selectedBrand!,
        model: _selectedModel!,
        location: _locationController.text,
        price: double.parse(_priceController.text),
        description: _descriptionController.text,
        imageUrls: _selectedImages,
        features: _selectedFeatures,
      );

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your vehicle has been posted successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to the previous screen
        Navigator.pop(context);
        Navigator.pop(context); // Pop the preview screen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post vehicle: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _isLoading ? null : () => Navigator.pop(context),
        ),
        title: Text(
          'Post Vehicle',
          style: AppTextStyles.headline2.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vehicle Type Selection
                  _buildSectionTitle('Vehicle Type'),
                  Row(
                    children: [
                      Expanded(
                        child: _buildVehicleTypeButton(
                          VehicleType.car,
                          'Car',
                          Icons.directions_car,
                        ),
                      ),
                      16.w,
                      Expanded(
                        child: _buildVehicleTypeButton(
                          VehicleType.motorbike,
                          'Motorbike',
                          Icons.motorcycle,
                        ),
                      ),
                    ],
                  ),
                  24.h,

                  // Title field
                  _buildSectionTitle('Title'),
                  _buildTextField(
                    controller: _titleController,
                    hintText: 'Enter title',
                  ),
                  24.h,

                  // Year and Mileage row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Year'),
                            _buildTextField(
                              controller: _yearController,
                              hintText: 'Enter Year',
                              keyboardType: TextInputType.number,
                              validator: _validateYear,
                            ),
                          ],
                        ),
                      ),
                      16.w,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Mileage'),
                            _buildTextField(
                              controller: _mileageController,
                              hintText: 'Enter Mileage',
                              keyboardType: TextInputType.number,
                              validator: _validateMileage,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  24.h,

                  // Brand and Model row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Brand'),
                            _buildDropdown(
                              value: _selectedBrand,
                              items: _brands,
                              hintText: 'Select Brand',
                              onChanged: (value) {
                                setState(() {
                                  _selectedBrand = value;
                                  _selectedModel = null; // Reset model when brand changes
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      16.w,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Model'),
                            _buildDropdown(
                              value: _selectedModel,
                              items: _models,
                              hintText: 'Select Model',
                              onChanged: (value) {
                                setState(() {
                                  _selectedModel = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  24.h,

                  // Transmission and Fuel Type row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Transmission'),
                            _buildDropdown(
                              value: _selectedTransmission,
                              items: _transmissions,
                              hintText: 'Select Transmission',
                              onChanged: (value) {
                                setState(() {
                                  _selectedTransmission = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      16.w,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Fuel Type'),
                            _buildDropdown(
                              value: _selectedFuelType,
                              items: _fuelTypes,
                              hintText: 'Select Fuel Type',
                              onChanged: (value) {
                                setState(() {
                                  _selectedFuelType = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  24.h,

                  // Engine Capacity (for motorbikes)
                  if (_selectedVehicleType == VehicleType.motorbike) ...[
                    _buildSectionTitle('Engine Capacity (cc)'),
                    _buildTextField(
                      controller: _engineCapacityController,
                      hintText: 'Enter Engine Capacity',
                      keyboardType: TextInputType.number,
                      validator: _validateEngineCapacity,
                    ),
                    24.h,
                  ],

                  // Features section
                  _buildSectionTitle('Features'),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search',
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  16.h,

                  // Feature checkboxes
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: _selectedFeatures.entries.map((entry) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: entry.value,
                              onChanged: (bool? value) {
                                setState(() {
                                  _selectedFeatures[entry.key] = value!;
                                });
                              },
                              activeColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          8.w,
                          Text(entry.key),
                        ],
                      );
                    }).toList(),
                  ),
                  24.h,

                  // Location and Price row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Location'),
                            _buildTextField(
                              controller: _locationController,
                              hintText: 'Search Location',
                              prefixIcon: Icons.location_on_outlined,
                            ),
                          ],
                        ),
                      ),
                      16.w,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Price'),
                            _buildTextField(
                              controller: _priceController,
                              hintText: 'Enter Price',
                              keyboardType: TextInputType.number,
                              validator: _validatePrice,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  24.h,

                  // Description
                  _buildSectionTitle('Description'),
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _descriptionController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration(
                        hintText: 'Write description about your vehicle',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  24.h,

                  // Images section
                  _buildSectionTitle('Images'),
                  Text(
                    'Maximum $_maxImages images allowed',
                    style: AppTextStyles.bodyText2.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  16.h,
                  Container(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        // Add image button
                        if (_selectedImages.length < _maxImages)
                          Container(
                            width: 120,
                            margin: EdgeInsets.only(right: 16),
                            child: ImagePickerWidget(
                              bucketName: 'vehicle-images',
                              onImageUploaded: _handleImageUploaded,
                              size: 120,
                              isCircular: false,
                            ),
                          ),
                        // Selected images
                        ..._selectedImages.asMap().entries.map((entry) {
                          return Container(
                            width: 120,
                            margin: EdgeInsets.only(right: 16),
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: NetworkImage(entry.value),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () => _removeImage(entry.key),
                                    child: Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.5),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  24.h,

                  // Preview button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _showPreview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Preview Post',
                        style: AppTextStyles.bodyText1.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  24.h,
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVehicleTypeButton(
    VehicleType type,
    String label,
    IconData icon,
  ) {
    final isSelected = _selectedVehicleType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedVehicleType = type;
          _selectedBrand = null;
          _selectedModel = null;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            8.h,
            Text(
              label,
              style: AppTextStyles.bodyText1.copyWith(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: AppTextStyles.bodyText1.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    IconData? prefixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.grey) : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hintText,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hintText, style: TextStyle(color: Colors.grey[500])),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down),
          items: items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
