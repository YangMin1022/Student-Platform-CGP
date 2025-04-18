
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditClubPage extends StatefulWidget {
  final String clubId;
  final Map<String, dynamic> existingData;

  const EditClubPage({
    Key? key,
    required this.clubId,
    required this.existingData,
  }) : super(key: key);

  @override
  _EditClubPageState createState() => _EditClubPageState();
}

class _EditClubPageState extends State<EditClubPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _actCtrl;
  late TextEditingController _picNameCtrl;
  late TextEditingController _picContactCtrl;
  late TextEditingController _picPosCtrl;
  late TextEditingController _imageUrlCtrl;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final d = widget.existingData;
    _nameCtrl       = TextEditingController(text: d['clubName'] ?? '');
    _descCtrl       = TextEditingController(text: d['clubDescription'] ?? '');
    _actCtrl        = TextEditingController(text: d['clubActivities'] ?? '');
    _picNameCtrl    = TextEditingController(text: d['picName'] ?? '');
    _picContactCtrl = TextEditingController(text: d['picContactNumber'] ?? '');
    _picPosCtrl     = TextEditingController(text: d['picPosition'] ?? '');
    _imageUrlCtrl   = TextEditingController(text: d['clubImageUrl'] ?? '');
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    try {
      await FirebaseFirestore.instance
          .collection('clubs')
          .doc(widget.clubId)
          .update({
        'clubName':           _nameCtrl.text.trim(),
        'clubDescription':    _descCtrl.text.trim(),
        'clubActivities':     _actCtrl.text.trim(),
        'picName':            _picNameCtrl.text.trim(),
        'picContactNumber':   _picContactCtrl.text.trim(),
        'picPosition':        _picPosCtrl.text.trim(),
        'clubImageUrl':     _imageUrlCtrl.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Club updated successfully!')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update club: $e')),
      );
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _actCtrl.dispose();
    _picNameCtrl.dispose();
    _picContactCtrl.dispose();
    _picPosCtrl.dispose();
    _imageUrlCtrl.dispose();
    super.dispose();
  }

  Widget _buildField(String label, TextEditingController ctrl,
      {TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboard,
        validator: (v) =>
            v == null || v.trim().isEmpty ? 'Please enter $label' : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Club'),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildField('Club Name', _nameCtrl),
              _buildField('Club Description', _descCtrl),
              _buildField('Club Activities', _actCtrl),
              _buildField('PIC Name', _picNameCtrl),
              _buildField('PIC Contact Number', _picContactCtrl,
                  keyboard: TextInputType.phone),
              _buildField('PIC Position', _picPosCtrl),
              _buildField('Club Image URL', _imageUrlCtrl,
                  keyboard: TextInputType.url),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _submitting
                    ? const CircularProgressIndicator()
                    : const Text('SAVE CHANGES'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
