// lib/edit_discover_page.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditDiscoverPage extends StatefulWidget {
  final String clubId;
  final String discId;
  final Map<String, dynamic> existingData;

  const EditDiscoverPage({
    Key? key,
    required this.clubId,
    required this.discId,
    required this.existingData,
  }) : super(key: key);

  @override
  State<EditDiscoverPage> createState() => _EditDiscoverPageState();
}

class _EditDiscoverPageState extends State<EditDiscoverPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _contentController;
  late TextEditingController _imageUrlController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(
      text: widget.existingData['discoverContent'] as String? ?? '',
    );
    _imageUrlController = TextEditingController(
      text: widget.existingData['discoverImageUrl'] as String? ?? '',
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection('clubs')
          .doc(widget.clubId)
          .collection('discover')
          .doc(widget.discId)
          .update({
        'discoverContent': _contentController.text.trim(),
        'discoverImageUrl': _imageUrlController.text.trim(),
      });

      // pop back and trigger a refresh upstream
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating post: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String? _validateNotEmpty(String? v, String field) {
    if (v == null || v.trim().isEmpty) return '$field cannot be empty';
    return null;
  }

  String? _validateUrl(String? v) {
    final pattern = r'^https?://[^\s]+$';
    if (v == null || !RegExp(pattern).hasMatch(v.trim())) {
      return 'Enter a valid URL';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Discover Post')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Content field
              TextFormField(
                controller: _contentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => _validateNotEmpty(v, 'Content'),
              ),
              const SizedBox(height: 16),

              // Image URL field
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  border: OutlineInputBorder(),
                ),
                validator: _validateUrl,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveChanges,
                  child: _isSaving
                      ? const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2)
                      : const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
