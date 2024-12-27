import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class StoreImagePicker extends StatefulWidget {
  final void Function(File pickedImage) onImagePicked;

  const StoreImagePicker({super.key, required this.onImagePicked});

  @override
  _StoreImagePickerState createState() => _StoreImagePickerState();
}

class _StoreImagePickerState extends State<StoreImagePicker> {
  File? _selectedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImageFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50, // Reduce quality to save storage
      maxWidth: 150, // Limit image size
    );

    if (pickedImageFile != null) {
      setState(() {
        _selectedImage = File(pickedImageFile.path);
      });
      widget.onImagePicked(File(pickedImageFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage:
              _selectedImage != null ? FileImage(_selectedImage!) : null,
          child:
              _selectedImage == null ? const Icon(Icons.store, size: 40) : null,
        ),
        TextButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.image),
          label: const Text('Select Store Image'),
        ),
      ],
    );
  }
}
