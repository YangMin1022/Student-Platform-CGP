import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InsertClubPage extends StatefulWidget {
  const InsertClubPage({Key? key}) : super(key: key);

  @override
  State<InsertClubPage> createState() => _InsertClubPageState();
}

class _InsertClubPageState extends State<InsertClubPage> {
  // Controllers for text fields
  final TextEditingController _clubImageUrlController = TextEditingController();
  final TextEditingController _clubNameController = TextEditingController();
  final TextEditingController _clubDescriptionController = TextEditingController();
  final TextEditingController _clubActivitiesController = TextEditingController();
  final TextEditingController _picNameController = TextEditingController();
  final TextEditingController _picContactNumberController = TextEditingController();
  final TextEditingController _picPositionController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  Future<void> _submitClub() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await FirebaseFirestore.instance.collection('clubs').add({
        'clubImageUrl': _clubImageUrlController.text.trim(),
        'clubName': _clubNameController.text.trim(),
        'clubDescription': _clubDescriptionController.text.trim(),
        'clubActivities': _clubActivitiesController.text.trim(),
        'picName': _picNameController.text.trim(),
        'picContactNumber': _picContactNumberController.text.trim(),
        'picPosition': _picPositionController.text.trim(),
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Club added successfully!')),
      );

      // Clear all fields after successful submission
      _clubNameController.clear();
      _clubDescriptionController.clear();
      _clubActivitiesController.clear();
      _clubImageUrlController.clear();
      _picNameController.clear();
      _picContactNumberController.clear();
      _picPositionController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add club: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Insert Club'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            _buildTextField('Club Image URL', _clubImageUrlController),
            _buildTextField('Club Name', _clubNameController),
            _buildTextField('Club Description', _clubDescriptionController),
            _buildTextField('Club Activities', _clubActivitiesController),
            _buildTextField('PIC Name', _picNameController),
            _buildTextField('PIC Contact Number', _picContactNumberController, isNumeric: true),
            _buildTextField('PIC Position', _picPositionController),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitClub,
              child: _isSubmitting
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
