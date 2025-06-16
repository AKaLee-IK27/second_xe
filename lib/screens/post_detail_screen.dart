import 'package:flutter/material.dart';
import 'package:second_xe/core/styles/colors.dart';
import 'package:second_xe/core/styles/text_styles.dart';
import 'package:second_xe/core/repositories/vehicle_post_repository.dart';
import 'package:second_xe/models/vehicle_post_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:second_xe/core/repositories/chat_repository.dart';
import 'package:second_xe/models/chat_model.dart';
import 'package:second_xe/screens/chat_screen.dart';
import 'package:second_xe/core/repositories/user_repository.dart';
import 'package:second_xe/models/user_model.dart';

class PostDetailScreen extends StatefulWidget {
  final String? carId;

  const PostDetailScreen({super.key, this.carId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  int _currentImageIndex = 0;
  VehiclePostModel? _post;
  bool _isLoading = true;
  String? _error;
  UserModel? _seller;
  bool _isSellerLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPost();
  }

  Future<void> _fetchSeller(String userId) async {
    setState(() {
      _isSellerLoading = true;
    });
    try {
      final repo = UserRepository();
      final seller = await repo.getUserById(userId);
      setState(() {
        _seller = seller;
        _isSellerLoading = false;
      });
    } catch (e) {
      setState(() {
        _isSellerLoading = false;
      });
    }
  }

  Future<void> _fetchPost() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      if (widget.carId == null) throw Exception('No post ID provided');
      final repo = VehiclePostRepository();
      final post = await repo.getPostById(widget.carId!);
      if (post == null) throw Exception('Post not found');
      setState(() {
        _post = post;
        _isLoading = false;
      });
      _fetchSeller(post.userId);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

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
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Text(_error!, style: TextStyle(color: Colors.red)),
              )
              : _post == null
              ? const Center(child: Text('Post not found'))
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageCarousel(),
                    _buildThumbnails(),
                    _buildCarInfo(),
                    _buildSellerInfo(),
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
    final images = _post?.imageUrls ?? [];
    return Stack(
      children: [
        Container(
          height: 240,
          width: double.infinity,
          color: Colors.white,
          child:
              images.isNotEmpty
                  ? PageView.builder(
                    itemCount: images.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Image.network(images[index], fit: BoxFit.cover);
                    },
                  )
                  : Center(
                    child: Icon(
                      Icons.directions_car,
                      size: 80,
                      color: Colors.grey[300],
                    ),
                  ),
        ),
        if (images.isNotEmpty)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        _currentImageIndex == index
                            ? AppColors.primary
                            : Colors.grey[300],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildThumbnails() {
    final images = _post?.imageUrls ?? [];
    if (images.isEmpty) return const SizedBox.shrink();
    return Container(
      height: 70,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: List.generate(images.length, (index) {
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
                child: Image.network(images[index], fit: BoxFit.cover),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCarInfo() {
    if (_post == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _post!.title,
                  style: AppTextStyles.headline2.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            _post!.formattedPrice,
            style: AppTextStyles.headline2.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_post!.brand ?? ''} ${_post!.model ?? ''} • ${_post!.year ?? ''}',
            style: AppTextStyles.bodyText1,
          ),
          const SizedBox(height: 4),
          Text(_post!.location ?? '', style: AppTextStyles.bodyText2),
        ],
      ),
    );
  }

  Widget _buildSellerInfo() {
    if (_isSellerLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_seller == null) return const SizedBox.shrink();
    return InkWell(
      onTap: () async {
        final currentUser = Supabase.instance.client.auth.currentUser;
        final currentUserId = currentUser?.id;
        if (_post == null || currentUserId == null) return;
        final chatRepo = ChatRepository();
        final chat = await chatRepo.getOrCreateChat(
          postId: _post!.id,
          buyerId: currentUserId,
          sellerId: _post!.userId,
        );
        if (chat != null && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ChatScreen(
                    chat: chat,
                    currentUserId: currentUserId,
                    sellerName: _seller!.displayName,
                    sellerAvatarUrl: _seller!.avatarUrl,
                  ),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage:
                  _seller!.avatarUrl != null && _seller!.avatarUrl!.isNotEmpty
                      ? NetworkImage(_seller!.avatarUrl!)
                      : null,
              child:
                  (_seller!.avatarUrl == null || _seller!.avatarUrl!.isEmpty)
                      ? Icon(Icons.person, size: 32)
                      : null,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_seller!.displayName, style: AppTextStyles.headline2),
                const SizedBox(height: 4),
                Text(_seller!.email, style: AppTextStyles.bodyText2),
              ],
            ),
            const Spacer(),
            Icon(Icons.chat, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildCarDescription() {
    if (_post == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _post!.description ?? '',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures() {
    if (_post == null || _post!.features.isEmpty)
      return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children:
            _post!.features
                .map((feature) => _buildFeatureChip(feature))
                .toList(),
      ),
    );
  }

  Widget _buildFeatureChip(String feature) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
        color: AppColors.primary.withOpacity(0.1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_box, color: AppColors.primary, size: 16),
          const SizedBox(width: 4),
          Text(
            feature,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    if (_post == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildInfoRow(Icons.business, 'Contact Dealer'),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.location_on_outlined, _post!.location ?? ''),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.info_outline,
            '${_post!.brand ?? ''} ${_post!.model ?? ''} ${_post!.year ?? ''}',
          ),
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
    final currentUser = Supabase.instance.client.auth.currentUser;
    final currentUserId = currentUser?.id;
    final isOwner = _post?.userId == currentUserId;
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child:
            isOwner
                ? ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'This is your post',
                    style: AppTextStyles.bodyText1.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
                : ElevatedButton(
                  onPressed: () async {
                    if (_post == null || currentUserId == null) return;
                    final chatRepo = ChatRepository();
                    final chat = await chatRepo.getOrCreateChat(
                      postId: _post!.id,
                      buyerId: currentUserId,
                      sellerId: _post!.userId,
                    );
                    if (chat != null && mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ChatScreen(
                                chat: chat,
                                currentUserId: currentUserId,
                                sellerName: _post!.brand ?? 'Seller',
                                sellerAvatarUrl:
                                    null, // Optionally fetch seller avatar
                              ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Chat with Seller',
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
