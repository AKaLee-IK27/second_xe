import 'package:flutter/material.dart';
import 'package:second_xe/core/styles/colors.dart';
import 'package:second_xe/core/styles/text_styles.dart';
import 'package:second_xe/screens/utils/sizes.dart';
import 'package:second_xe/models/vehicle_type.dart';

class PostPreviewScreen extends StatelessWidget {
  final String title;
  final int year;
  final int mileage;
  final String brand;
  final String model;
  final String location;
  final double price;
  final String description;
  final List<String> imageUrls;
  final Map<String, bool> features;
  final VehicleType vehicleType;
  final int? engineCapacity;
  final String transmission;
  final String fuelType;
  final VoidCallback onConfirm;

  const PostPreviewScreen({
    Key? key,
    required this.title,
    required this.year,
    required this.mileage,
    required this.brand,
    required this.model,
    required this.location,
    required this.price,
    required this.description,
    required this.imageUrls,
    required this.features,
    required this.vehicleType,
    required this.engineCapacity,
    required this.transmission,
    required this.fuelType,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Preview Post',
          style: AppTextStyles.headline2.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image carousel
            SizedBox(
              height: 250,
              child: PageView.builder(
                itemCount: imageUrls.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(imageUrls[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
            24.h,

            // Details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTextStyles.headline2,
                        ),
                      ),
                      Text(
                        '\$${price.toStringAsFixed(2)}',
                        style: AppTextStyles.headline2.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  16.h,

                  // Brand, Model, Year, Vehicle Type
                  Row(
                    children: [
                      Text(
                        '$brand $model',
                        style: AppTextStyles.bodyText1.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      8.w,
                      Text(
                        '•',
                        style: AppTextStyles.bodyText1,
                      ),
                      8.w,
                      Text(
                        year.toString(),
                        style: AppTextStyles.bodyText1,
                      ),
                      8.w,
                      Text(
                        '•',
                        style: AppTextStyles.bodyText1,
                      ),
                      8.w,
                      Text(
                        vehicleType == VehicleType.car ? 'Car' : 'Motorbike',
                        style: AppTextStyles.bodyText1.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  16.h,

                  // Transmission, Fuel Type, Engine Capacity (if motorbike)
                  Row(
                    children: [
                      Icon(Icons.settings, size: 16),
                      4.w,
                      Text(
                        transmission,
                        style: AppTextStyles.bodyText2,
                      ),
                      16.w,
                      Icon(Icons.local_gas_station, size: 16),
                      4.w,
                      Text(
                        fuelType,
                        style: AppTextStyles.bodyText2,
                      ),
                      if (vehicleType == VehicleType.motorbike && engineCapacity != null) ...[
                        16.w,
                        Icon(Icons.speed, size: 16),
                        4.w,
                        Text(
                          '${engineCapacity}cc',
                          style: AppTextStyles.bodyText2,
                        ),
                      ],
                    ],
                  ),
                  16.h,

                  // Location and Mileage
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 16),
                      4.w,
                      Text(
                        location,
                        style: AppTextStyles.bodyText2,
                      ),
                      16.w,
                      Icon(Icons.speed, size: 16),
                      4.w,
                      Text(
                        '$mileage km',
                        style: AppTextStyles.bodyText2,
                      ),
                    ],
                  ),
                  24.h,

                  // Features
                  Text(
                    'Features',
                    style: AppTextStyles.bodyText1.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  8.h,
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: features.entries
                        .where((entry) => entry.value)
                        .map((entry) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          entry.key,
                          style: AppTextStyles.bodyText2.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  24.h,

                  // Description
                  Text(
                    'Description',
                    style: AppTextStyles.bodyText1.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  8.h,
                  Text(
                    description,
                    style: AppTextStyles.bodyText2,
                  ),
                  32.h,

                  // Confirm button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Confirm & Post',
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
          ],
        ),
      ),
    );
  }
} 