# Database Models for 2ndXE Car Marketplace

This directory contains all the data models and repositories for the 2ndXE car marketplace application, based on your Supabase database schema.

## 📊 Database Schema Overview

Your Supabase database contains the following tables:

### Core Tables

- **User** - User profiles and authentication data
- **VehiclePost** - Car listings posted by users
- **PostPayment** - Payment records for post promotions
- **Favourite** - User favorite car listings
- **Comment** - User reviews and comments
- **Report** - Content moderation reports
- **LogEntry** - System activity logging

## 🔧 Models

### UserModel

Represents user accounts and profiles.

```dart
import 'package:second_xe/models/models.dart';

// Create a user
final user = UserModel(
  id: 'uuid',
  email: 'user@example.com',
  fullName: 'John Doe',
  role: UserRole.user,
  isVerified: false,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

// Convert to/from JSON
final json = user.toJson();
final userFromJson = UserModel.fromJson(json);
```

### VehiclePostModel

Represents car listings.

```dart
// Create a vehicle post
final post = VehiclePostModel(
  id: 'uuid',
  userId: 'user-uuid',
  title: 'Toyota Camry 2020',
  brand: 'Toyota',
  model: 'Camry',
  year: 2020,
  price: 25000.0,
  mileage: 15000,
  location: 'Ho Chi Minh City',
  status: VehicleStatus.available,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

// Access computed properties
print(post.formattedPrice); // $25,000
print(post.formattedMileage); // 15,000 km
print(post.fullVehicleName); // Toyota Camry 2020
print(post.isAvailable); // true
```

### Other Models

- **CommentModel** - User reviews with ratings (1-5 stars)
- **FavouriteModel** - User's saved vehicle posts
- **PostPaymentModel** - Payment for post visibility/promotion
- **ReportModel** - Content moderation reports
- **LogEntryModel** - System activity logs

## 🏪 Repositories

### UserRepository

```dart
import 'package:second_xe/core/repositories/repositories.dart';

final userRepo = UserRepository();

// Get user by email
final user = await userRepo.getUserByEmail('user@example.com');

// Create new user
final newUser = await userRepo.createUser(userModel);

// Search users
final users = await userRepo.searchUsers('John');

// Get users by role
final admins = await userRepo.getUsersByRole(UserRole.admin);
```

### VehiclePostRepository

```dart
final postRepo = VehiclePostRepository();

// Get available posts
final availablePosts = await postRepo.getAvailablePosts();

// Search posts
final searchResults = await postRepo.searchPosts('Toyota');

// Filter by price range
final affordableCars = await postRepo.getPostsByPriceRange(
  minPrice: 10000,
  maxPrice: 30000,
);

// Advanced filtering
final filteredPosts = await postRepo.filterPosts(
  brand: 'Toyota',
  minYear: 2018,
  maxPrice: 25000,
  location: 'Ho Chi Minh',
  limit: 20,
);

// Get user's posts
final userPosts = await postRepo.getPostsByUserId('user-uuid');
```

## 🔄 Enums

### UserRole

- `admin` - System administrator
- `user` - Regular user
- `moderator` - Content moderator

### VehicleStatus

- `available` - Post is active and available
- `sold` - Vehicle has been sold
- `pending` - Post pending approval
- `expired` - Post has expired

### PaymentStatus

- `pending` - Payment is processing
- `paid` - Payment completed successfully
- `failed` - Payment failed

### ReportStatus

- `pending` - Report needs review
- `reviewed` - Report has been reviewed
- `resolved` - Report issue resolved

## 📱 Usage in Flutter Screens

### In your CreatePostScreen:

```dart
void _handlePostCar() async {
  final post = VehiclePostModel(
    id: '', // Will be generated by database
    userId: currentUser.id,
    title: _titleController.text,
    brand: _selectedBrand,
    model: _selectedModel,
    year: int.parse(_yearController.text),
    price: double.parse(_priceController.text),
    location: _locationController.text,
    mileage: int.parse(_mileageController.text),
    description: _descriptionController.text,
    status: VehicleStatus.pending,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final postRepo = VehiclePostRepository();
  await postRepo.createPost(post);
}
```

### In your HomeScreen for listing cars:

```dart
class _HomeScreenState extends State<HomeScreen> {
  final VehiclePostRepository _postRepo = VehiclePostRepository();
  List<VehiclePostModel> _posts = [];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  void _loadPosts() async {
    final posts = await _postRepo.getAvailablePosts();
    setState(() {
      _posts = posts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        final post = _posts[index];
        return CarCard(
          title: post.fullVehicleName,
          price: post.formattedPrice,
          imageUrl: post.primaryImageUrl,
          location: post.location,
        );
      },
    );
  }
}
```

## 🚀 Next Steps

1. **Create remaining repositories** for Comment, Favourite, Report, etc.
2. **Add providers** using these models for state management
3. **Implement real-time subscriptions** using the BaseRepository subscription methods
4. **Add validation** and error handling in your UI
5. **Create custom widgets** for displaying model data consistently

## 💡 Tips

- Always use the model's `toInsertJson()` for creating new records
- Use `toUpdateJson()` for updating existing records
- Leverage computed properties like `formattedPrice` and `isAvailable`
- Use the repository search and filter methods for better performance
- Handle null values appropriately in your UI

Your database is well-structured for a car marketplace with proper relationships and constraints. These models provide a solid foundation for building your Flutter application!
