import 'package:flutter/material.dart';
import 'package:second_xe/core/styles/colors.dart';
import 'package:second_xe/core/styles/text_styles.dart';

class PostDetailScreen extends StatefulWidget {
  final String? carId;

  const PostDetailScreen({super.key, this.carId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  int _currentImageIndex = 0;
  final List<String> _carImages = [
    'https://images.unsplash.com/photo-1620891549027-942fdc95d3f5?q=80&w=1887&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    "https://plus.unsplash.com/premium_photo-1715702638527-1a7f52e8cc6f?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    'https://images.unsplash.com/photo-1617704548623-340376564e68?q=80&w=1770&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
  ];

  final Map<String, dynamic> _carDetails = {
    'name': 'Tesla Model 3',
    'price': 'Rs. 18,00,000.00',
    'rating': 4.5,
    'description':
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas diam nam eu nulla a. Vestibulum aliquet facilisi interdum nibh blandit',
    'features': ['Autopilot', '360° Camera'],
  };

  bool _isDescriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black),
            onPressed: () {
              // Handle share functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageCarousel(),
            _buildThumbnails(),
            _buildCarInfo(),
            _buildCarDescription(),
            _buildFeatures(),
            _buildContactInfo(),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: _buildContactButton(),
    );
  }

  Widget _buildImageCarousel() {
    return Stack(
      children: [
        Container(
          height: 240,
          width: double.infinity,
          color: Colors.white,
          child: PageView.builder(
            itemCount: _carImages.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Image.network(_carImages[index], fit: BoxFit.cover);
            },
          ),
        ),
        Positioned(
          right: 16,
          top: 16,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.rotate_right,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThumbnails() {
    return Container(
      height: 70,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: List.generate(_carImages.length, (index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _currentImageIndex = index;
              });
            },
            child: Container(
              width: 80,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                border: Border.all(
                  color:
                      _currentImageIndex == index
                          ? AppColors.primary
                          : Colors.transparent,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: Image.network(_carImages[index], fit: BoxFit.cover),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCarInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _carDetails['name'],
                style: AppTextStyles.headline2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Text(
                    '${_carDetails['rating']}/5',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.star, color: AppColors.primary, size: 20),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _carDetails['price'],
            style: AppTextStyles.headline2.copyWith(color: Colors.grey[800]),
          ),
        ],
      ),
    );
  }

  Widget _buildCarDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isDescriptionExpanded
                ? _carDetails['description']
                : _carDetails['description'],
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              height: 1.5,
            ),
            maxLines: _isDescriptionExpanded ? null : 3,
            overflow: _isDescriptionExpanded ? null : TextOverflow.ellipsis,
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _isDescriptionExpanded = !_isDescriptionExpanded;
              });
            },
            child: Text(
              _isDescriptionExpanded ? 'Read less...' : 'Read more...',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildFeatureChip(_carDetails['features'][0], true),
              const SizedBox(width: 8),
              _buildFeatureChip(_carDetails['features'][1], true),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  // Show all features
                },
                child: Text(
                  'See All',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String feature, bool isEnabled) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
        color:
            isEnabled ? AppColors.primary.withOpacity(0.1) : Colors.grey[200],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isEnabled)
            Icon(Icons.check_box, color: AppColors.primary, size: 16)
          else
            Icon(Icons.check_box_outline_blank, color: Colors.grey, size: 16),
          const SizedBox(width: 4),
          Text(
            feature,
            style: TextStyle(
              color: isEnabled ? AppColors.primary : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildInfoRow(Icons.business, 'Contact Dealer'),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.location_on_outlined, 'Delhi, India'),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.info_outline, 'Car details (Model, year...)'),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.account_balance_wallet_outlined, 'EMI/Loan'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[700], size: 20),
        const SizedBox(width: 12),
        Text(text, style: TextStyle(fontSize: 14, color: Colors.grey[800])),
      ],
    );
  }

  Widget _buildContactButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () {
            // Handle contact seller
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Contact Seller',
            style: AppTextStyles.bodyText1.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
