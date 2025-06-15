import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/services/storage_service.dart';

class ImagePickerWidget extends StatefulWidget {
  final String bucketName;
  final Function(String) onImageUploaded;
  final String? initialImageUrl;
  final double size;
  final bool isCircular;

  const ImagePickerWidget({
    Key? key,
    required this.bucketName,
    required this.onImageUploaded,
    this.initialImageUrl,
    this.size = 120,
    this.isCircular = true,
  }) : super(key: key);

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  File? _imageFile;
  String? _imageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _imageUrl = widget.initialImageUrl;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _isLoading = true;
        });

        // Upload the image
        final imageUrl = await StorageService.uploadImage(
          _imageFile!,
          widget.bucketName,
        );

        setState(() {
          _imageUrl = imageUrl;
          _isLoading = false;
        });

        widget.onImageUploaded(imageUrl);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick/upload image: $e')),
      );
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: widget.isCircular ? BoxShape.circle : BoxShape.rectangle,
          color: Colors.grey[200],
          image: _imageUrl != null
              ? DecorationImage(
                  image: NetworkImage(_imageUrl!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _imageUrl == null
                ? Icon(
                    Icons.add_a_photo,
                    size: widget.size * 0.3,
                    color: Colors.grey[600],
                  )
                : null,
      ),
    );
  }
} 