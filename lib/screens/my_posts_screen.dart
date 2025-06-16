import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:second_xe/models/vehicle_post_model.dart';
import 'package:second_xe/core/repositories/vehicle_post_repository.dart';
import 'package:second_xe/screens/post_detail_screen.dart';
import 'package:second_xe/screens/payment_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MyPostsScreen extends StatefulWidget {
  const MyPostsScreen({Key? key}) : super(key: key);

  @override
  State<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
  late Future<List<VehiclePostModel>> _futurePosts;

  @override
  void initState() {
    super.initState();
    _futurePosts = _fetchMyPosts();
  }

  Future<List<VehiclePostModel>> _fetchMyPosts() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return [];
    final repo = VehiclePostRepository();
    return await repo.getPostsByUserAndStatus(userId, ['pending', 'available']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Posts')),
      body: FutureBuilder<List<VehiclePostModel>>(
        future: _futurePosts,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final posts = snapshot.data!;
          if (posts.isEmpty) {
            return const Center(child: Text('No posts found.'));
          }
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return ListTile(
                leading: (post.imageUrls != null && post.imageUrls!.isNotEmpty)
                    ? CachedNetworkImage(
                        imageUrl: post.imageUrls!.first,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 56),
                      )
                    : const Icon(Icons.directions_car),
                title: Text(post.title),
                subtitle: Text(post.status.name),
                onTap: () {
                  if (post.status.name == 'pending') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentScreen(post: post),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostDetailScreen(carId: post.id),
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
} 