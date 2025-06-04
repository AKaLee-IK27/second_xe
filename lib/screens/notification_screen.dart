import 'package:flutter/material.dart';
import 'package:second_xe/core/styles/colors.dart';
import 'package:second_xe/core/styles/text_styles.dart';
import 'package:second_xe/screens/utils/sizes.dart';

enum NotificationType {
  general,
  newCar,
  priceChange,
  favoriteUpdate,
  system,
  promotion,
}

class NotificationModel {
  final String id;
  final String title;
  final String description;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final String? imageUrl;
  final String? actionData;

  NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.imageUrl,
    this.actionData,
  });
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<NotificationModel> _notifications = [];
  List<NotificationModel> _filteredNotifications = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMockNotifications();
    _filteredNotifications = _notifications;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadMockNotifications() {
    _notifications = [
      NotificationModel(
        id: '1',
        title: 'New Toyota Camry Available!',
        description:
            'A 2022 Toyota Camry has been posted in your area. Price: \$29,800',
        type: NotificationType.newCar,
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        imageUrl:
            'https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?q=80&w=1770&auto=format&fit=crop',
      ),
      NotificationModel(
        id: '2',
        title: 'Price Drop Alert!',
        description: 'BMW X3 2021 price dropped from \$47,000 to \$45,000',
        type: NotificationType.priceChange,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: true,
        imageUrl:
            'https://images.unsplash.com/photo-1555215695-3004980ad54e?q=80&w=1770&auto=format&fit=crop',
      ),
      NotificationModel(
        id: '3',
        title: 'Welcome to XeShop!',
        description:
            'Thanks for joining us. Start exploring thousands of cars available in your area.',
        type: NotificationType.system,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
      NotificationModel(
        id: '4',
        title: 'Favorite Car Sold',
        description:
            'Honda Civic 2022 from your favorites has been sold. Check out similar cars.',
        type: NotificationType.favoriteUpdate,
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        imageUrl:
            'https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?q=80&w=1770&auto=format&fit=crop',
      ),
      NotificationModel(
        id: '5',
        title: 'Weekend Sale - 20% Off Premium Listings',
        description:
            'Post your car with premium features at 20% discount this weekend only!',
        type: NotificationType.promotion,
        timestamp: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      NotificationModel(
        id: '6',
        title: 'New Mercedes in Your Budget',
        description:
            'Mercedes C-Class 2020 posted for \$38,500 - matches your saved search.',
        type: NotificationType.newCar,
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        isRead: true,
        imageUrl:
            'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?q=80&w=1770&auto=format&fit=crop',
      ),
    ];
  }

  void _filterNotifications(int tabIndex) {
    setState(() {
      switch (tabIndex) {
        case 0: // All
          _filteredNotifications = _notifications;
          break;
        case 1: // Unread
          _filteredNotifications =
              _notifications.where((n) => !n.isRead).toList();
          break;
        case 2: // Important
          _filteredNotifications =
              _notifications
                  .where(
                    (n) =>
                        n.type == NotificationType.priceChange ||
                        n.type == NotificationType.favoriteUpdate,
                  )
                  .toList();
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Column(
        children: [_buildTabBar(), Expanded(child: _buildNotificationsList())],
      ),
    );
  }

  AppBar _buildAppBar() {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notifications',
            style: AppTextStyles.headline2.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (unreadCount > 0)
            Text(
              '$unreadCount unread',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
        ],
      ),
      actions: [
        if (unreadCount > 0)
          TextButton(
            onPressed: _markAllAsRead,
            child: Text(
              'Mark all read',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.black),
          onPressed: () {
            // Navigate to notification settings
          },
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: Colors.grey,
        indicatorColor: AppColors.primary,
        onTap: _filterNotifications,
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('All'),
                if (_notifications.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_notifications.length}',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Unread'),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_notifications.where((n) => !n.isRead).length}',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
          const Tab(text: 'Important'),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    if (_filteredNotifications.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Simulate refresh
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          _loadMockNotifications();
          _filterNotifications(_tabController.index);
        });
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _filteredNotifications.length,
        itemBuilder: (context, index) {
          final notification = _filteredNotifications[index];
          return _buildNotificationCard(notification);
        },
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              notification.isRead
                  ? Colors.grey[200]!
                  : AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: _buildNotificationIcon(notification),
        title: Text(
          notification.title,
          style: AppTextStyles.bodyText1.copyWith(
            fontWeight:
                notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            8.h,
            Text(
              notification.description,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            8.h,
            Text(
              _formatTimestamp(notification.timestamp),
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
        trailing: Column(
          children: [
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            const Spacer(),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.grey[400]),
              itemBuilder:
                  (context) => [
                    PopupMenuItem(
                      value: 'mark_read',
                      child: Text(
                        notification.isRead ? 'Mark as unread' : 'Mark as read',
                      ),
                    ),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
              onSelected: (value) {
                if (value == 'mark_read') {
                  _toggleReadStatus(notification);
                } else if (value == 'delete') {
                  _deleteNotification(notification);
                }
              },
            ),
          ],
        ),
        onTap: () => _handleNotificationTap(notification),
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationModel notification) {
    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case NotificationType.newCar:
        iconData = Icons.directions_car;
        iconColor = Colors.blue;
        break;
      case NotificationType.priceChange:
        iconData = Icons.trending_down;
        iconColor = Colors.green;
        break;
      case NotificationType.favoriteUpdate:
        iconData = Icons.favorite;
        iconColor = Colors.red;
        break;
      case NotificationType.promotion:
        iconData = Icons.local_offer;
        iconColor = Colors.orange;
        break;
      case NotificationType.system:
        iconData = Icons.info;
        iconColor = Colors.purple;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Colors.grey;
    }

    if (notification.imageUrl != null) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(notification.imageUrl!),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.3),
          ),
          child: Icon(iconData, color: Colors.white, size: 20),
        ),
      );
    }

    return CircleAvatar(
      radius: 24,
      backgroundColor: iconColor.withOpacity(0.1),
      child: Icon(iconData, color: iconColor, size: 24),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64, color: Colors.grey[400]),
          16.h,
          Text(
            'No notifications',
            style: AppTextStyles.headline2.copyWith(color: Colors.grey[600]),
          ),
          8.h,
          Text(
            'When you have notifications, they\'ll show up here',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Mark as read when tapped
    if (!notification.isRead) {
      _toggleReadStatus(notification);
    }

    // Handle different notification types
    switch (notification.type) {
      case NotificationType.newCar:
      case NotificationType.priceChange:
      case NotificationType.favoriteUpdate:
        // Navigate to car details
        if (notification.actionData != null) {
          // Navigator.pushNamed(context, '/car-details', arguments: notification.actionData);
        }
        break;
      case NotificationType.promotion:
        // Navigate to promotions or create post
        // Navigator.pushNamed(context, '/create-post');
        break;
      default:
        break;
    }
  }

  void _toggleReadStatus(NotificationModel notification) {
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        _notifications[index] = NotificationModel(
          id: notification.id,
          title: notification.title,
          description: notification.description,
          type: notification.type,
          timestamp: notification.timestamp,
          isRead: !notification.isRead,
          imageUrl: notification.imageUrl,
          actionData: notification.actionData,
        );
      }
      _filterNotifications(_tabController.index);
    });
  }

  void _deleteNotification(NotificationModel notification) {
    setState(() {
      _notifications.removeWhere((n) => n.id == notification.id);
      _filterNotifications(_tabController.index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notification deleted'),
        backgroundColor: AppColors.primary,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _notifications.add(notification);
              _filterNotifications(_tabController.index);
            });
          },
        ),
      ),
    );
  }

  void _markAllAsRead() {
    setState(() {
      _notifications =
          _notifications.map((notification) {
            return NotificationModel(
              id: notification.id,
              title: notification.title,
              description: notification.description,
              type: notification.type,
              timestamp: notification.timestamp,
              isRead: true,
              imageUrl: notification.imageUrl,
              actionData: notification.actionData,
            );
          }).toList();
      _filterNotifications(_tabController.index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('All notifications marked as read'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
