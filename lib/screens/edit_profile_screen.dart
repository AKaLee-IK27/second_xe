import 'package:flutter/material.dart';
import 'package:second_xe/core/styles/colors.dart';
import 'package:second_xe/core/styles/text_styles.dart';
import 'package:second_xe/utils/sizes.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _usernameController = TextEditingController(
    text: "Magdalena Succrose",
  );
  final TextEditingController _emailController = TextEditingController(
    text: "magdalena83@mail.com",
  );

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: AppTextStyles.bodyText1.copyWith(fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              // Show more options
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              24.h,
              // Profile picture
              Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1887&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.camera_alt,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                        onPressed: () {
                          // Add image picking functionality
                        },
                      ),
                    ),
                  ),
                ],
              ),
              32.h,

              // Username Section
              _buildSectionTitle('Username'),
              _buildInfoField(
                controller: _usernameController,
                icon: Icons.person_outline,
              ),
              24.h,

              // Email/Phone Section
              _buildSectionTitle('Email or Phone Number'),
              _buildInfoField(
                controller: _emailController,
                icon: Icons.email_outlined,
              ),
              24.h,

              // Account Liked With
              _buildSectionTitle('Account Linked With'),
              _buildAccountLinkItem(
                icon: Icon(Icons.email, color: Colors.grey[600], size: 24),
                title: 'Google',
                isLinked: true,
                onTap: () {
                  // Handle Google account linking
                },
              ),

              _buildAccountLinkItem(
                icon: Icon(Icons.facebook, color: Colors.blue, size: 24),
                title: 'Facebook',
                isLinked: false,
                onTap: () {
                  // Handle Facebook account linking
                },
              ),

              _buildAccountLinkItem(
                icon: Icon(Icons.apple, color: Colors.black, size: 24),
                title: 'Apple',
                isLinked: false,
                onTap: () {
                  // Handle Apple account linking
                },
              ),

              40.h,
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _handleSaveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF5B5FD2,
                    ), // Purple color from the design
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    'Save Changes',
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
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: AppTextStyles.bodyText1.copyWith(
          fontWeight: FontWeight.w500,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildInfoField({
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey[600]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildAccountLinkItem({
    required Widget icon,
    required String title,
    required bool isLinked,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: icon,
        title: Text(title, style: AppTextStyles.bodyText1),
        trailing:
            isLinked
                ? null
                : IconButton(
                  icon: const Icon(Icons.link, color: Colors.grey),
                  onPressed: onTap,
                ),
        onTap: onTap,
      ),
    );
  }

  void _handleSaveChanges() {
    // Validate fields
    if (_usernameController.text.isEmpty || _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Save profile changes
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully'),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate back
    Navigator.pop(context);
  }
}
