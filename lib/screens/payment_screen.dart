import 'package:flutter/material.dart';
import 'package:second_xe/models/vehicle_post_model.dart';
import 'package:second_xe/core/repositories/vehicle_post_repository.dart';

class PaymentScreen extends StatelessWidget {
  final VehiclePostModel post;
  const PaymentScreen({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Pay for your post',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            Text(post.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Text('Amount: ${post.price?.toStringAsFixed(2) ?? 'N/A'}'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                // Simulate payment success and update post status
                final repo = VehiclePostRepository();
                try {
                  await repo.updatePostStatus(post.id, VehicleStatus.available);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Payment successful! Post is now available.',
                      ),
                    ),
                  );
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update post: $e')),
                  );
                }
              },
              child: const Text('Pay Now'),
            ),
          ],
        ),
      ),
    );
  }
}
