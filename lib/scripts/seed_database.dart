import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/supabase_config.dart';

Future<void> main() async {
  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  final client = Supabase.instance.client;

  try {
    // Insert users
    final users = [
      {
        'id': '00000000-0000-0000-0000-000000000001',
        'auth_id': '00000000-0000-0000-0000-000000000001',
        'email': 'user1@example.com',
        'full_name': 'John Doe',
        'role': 'user',
        'is_verified': true,
      },
      {
        'id': '00000000-0000-0000-0000-000000000002',
        'auth_id': '00000000-0000-0000-0000-000000000002',
        'email': 'user2@example.com',
        'full_name': 'Jane Smith',
        'role': 'user',
        'is_verified': true,
      },
      {
        'id': '00000000-0000-0000-0000-000000000003',
        'auth_id': '00000000-0000-0000-0000-000000000003',
        'email': 'user3@example.com',
        'full_name': 'Mike Johnson',
        'role': 'user',
        'is_verified': true,
      },
      {
        'id': '00000000-0000-0000-0000-000000000004',
        'auth_id': '00000000-0000-0000-0000-000000000004',
        'email': 'user4@example.com',
        'full_name': 'Sarah Williams',
        'role': 'user',
        'is_verified': true,
      },
      {
        'id': '00000000-0000-0000-0000-000000000005',
        'auth_id': '00000000-0000-0000-0000-000000000005',
        'email': 'user5@example.com',
        'full_name': 'David Brown',
        'role': 'user',
        'is_verified': true,
      },
    ];

    for (final user in users) {
      await client.from('User').upsert(user);
    }

    // Insert vehicle posts
    final posts = [
      {
        'id': '1',
        'user_id': '00000000-0000-0000-0000-000000000001',
        'title': 'Tesla Model 3 Performance',
        'year': 2023,
        'mileage': 5000,
        'brand': 'Tesla',
        'model': 'Model 3',
        'location': 'Ho Chi Minh City',
        'price': 1500000000,
        'description':
            'Immaculate Tesla Model 3 Performance in perfect condition. Full self-driving capability, premium interior, and excellent range. Single owner, no accidents.',
        'image_urls': [
          'https://images.unsplash.com/photo-1617788138017-80ad40651399',
          'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8',
          'https://images.unsplash.com/photo-1617788138017-80ad40651399',
        ],
        'features': {
          'Alarm': true,
          'Bluetooth': true,
          'Cruise Control': true,
          'Front Parking Sensor': true,
          'Rear Parking Sensor': true,
          'Climate Control': true,
          'Navigation System': true,
          'Leather Seats': true,
        },
        'vehicle_type': 'car',
        'engine_capacity': null,
        'transmission': 'Automatic',
        'fuel_type': 'Electric',
        'status': 'available',
      },
      {
        'id': '2',
        'user_id': '00000000-0000-0000-0000-000000000002',
        'title': 'Honda CBR 1000RR-R Fireblade',
        'year': 2022,
        'mileage': 3000,
        'brand': 'Honda',
        'model': 'CBR',
        'location': 'Hanoi',
        'price': 850000000,
        'description':
            'Powerful Honda CBR 1000RR-R Fireblade in excellent condition. Full service history, never raced. Includes all original accessories and documentation.',
        'image_urls': [
          'https://images.unsplash.com/photo-1558981806-ec527fa84c39',
          'https://images.unsplash.com/photo-1558981806-ec527fa84c39',
          'https://images.unsplash.com/photo-1558981806-ec527fa84c39',
        ],
        'features': {
          'Alarm': true,
          'Bluetooth': true,
          'Cruise Control': true,
          'Front Parking Sensor': false,
          'Rear Parking Sensor': false,
          'Climate Control': false,
          'Navigation System': true,
          'Leather Seats': false,
        },
        'vehicle_type': 'motorbike',
        'engine_capacity': 1000,
        'transmission': 'Manual',
        'fuel_type': 'Petrol',
        'status': 'available',
      },
      {
        'id': '3',
        'user_id': '00000000-0000-0000-0000-000000000003',
        'title': 'BMW X5 xDrive40i',
        'year': 2022,
        'mileage': 15000,
        'brand': 'BMW',
        'model': 'X5',
        'location': 'Da Nang',
        'price': 3200000000,
        'description':
            'Luxurious BMW X5 xDrive40i with premium package. Panoramic sunroof, premium sound system, and all the latest technology features. Perfect family SUV.',
        'image_urls': [
          'https://images.unsplash.com/photo-1555215695-3004980ad54e',
          'https://images.unsplash.com/photo-1555215695-3004980ad54e',
          'https://images.unsplash.com/photo-1555215695-3004980ad54e',
        ],
        'features': {
          'Alarm': true,
          'Bluetooth': true,
          'Cruise Control': true,
          'Front Parking Sensor': true,
          'Rear Parking Sensor': true,
          'Climate Control': true,
          'Navigation System': true,
          'Leather Seats': true,
        },
        'vehicle_type': 'car',
        'engine_capacity': null,
        'transmission': 'Automatic',
        'fuel_type': 'Petrol',
        'status': 'available',
      },
      {
        'id': '4',
        'user_id': '00000000-0000-0000-0000-000000000004',
        'title': 'Ducati Panigale V4 S',
        'year': 2023,
        'mileage': 2000,
        'brand': 'Ducati',
        'model': 'Panigale',
        'location': 'Ho Chi Minh City',
        'price': 1200000000,
        'description':
            'Stunning Ducati Panigale V4 S in red. Track-ready superbike with all the latest electronics and premium components. Includes racing exhaust system.',
        'image_urls': [
          'https://images.unsplash.com/photo-1558981806-ec527fa84c39',
          'https://images.unsplash.com/photo-1558981806-ec527fa84c39',
          'https://images.unsplash.com/photo-1558981806-ec527fa84c39',
        ],
        'features': {
          'Alarm': true,
          'Bluetooth': true,
          'Cruise Control': true,
          'Front Parking Sensor': false,
          'Rear Parking Sensor': false,
          'Climate Control': false,
          'Navigation System': true,
          'Leather Seats': false,
        },
        'vehicle_type': 'motorbike',
        'engine_capacity': 1103,
        'transmission': 'Manual',
        'fuel_type': 'Petrol',
        'status': 'available',
      },
      {
        'id': '5',
        'user_id': '00000000-0000-0000-0000-000000000005',
        'title': 'Mercedes-Benz C-Class AMG',
        'year': 2023,
        'mileage': 8000,
        'brand': 'Mercedes',
        'model': 'C-Class',
        'location': 'Hanoi',
        'price': 2800000000,
        'description':
            'Elegant Mercedes-Benz C-Class AMG with AMG Line package. Premium interior with ambient lighting, advanced driver assistance systems, and powerful engine.',
        'image_urls': [
          'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8',
          'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8',
          'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8',
        ],
        'features': {
          'Alarm': true,
          'Bluetooth': true,
          'Cruise Control': true,
          'Front Parking Sensor': true,
          'Rear Parking Sensor': true,
          'Climate Control': true,
          'Navigation System': true,
          'Leather Seats': true,
        },
        'vehicle_type': 'car',
        'engine_capacity': null,
        'transmission': 'Automatic',
        'fuel_type': 'Petrol',
        'status': 'available',
      },
    ];

    for (final post in posts) {
      await client.from('VehiclePost').upsert(post);
    }

    print('Database seeded successfully!');
  } catch (e) {
    print('Error seeding database: $e');
  }
}
