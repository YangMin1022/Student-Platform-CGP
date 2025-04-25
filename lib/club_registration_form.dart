import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ClubRegistrationPage extends StatefulWidget {
  final String clubId;
  final String clubName;

  const ClubRegistrationPage({
    Key? key,
    required this.clubId,
    required this.clubName,
  }) : super(key: key);

  @override
  _ClubRegistrationPageState createState() => _ClubRegistrationPageState();
}

class _ClubRegistrationPageState extends State<ClubRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _idCtrl    = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool _submitting = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    try {
      await FirebaseFirestore.instance
          .collection('clubs')
          .doc(widget.clubId)
          .collection('registrations')
          .add({
        'studentName':  _nameCtrl.text.trim(),
        'studentId':    _idCtrl.text.trim(),
        'studentEmail': _emailCtrl.text.trim(),
        'registeredAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful!')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to register: $e')),
      );
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _idCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.clubName),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildField('Student Name', _nameCtrl),
              const SizedBox(height: 12),
              _buildField('Student ID', _idCtrl),
              const SizedBox(height: 12),
              _buildField('Student Email', _emailCtrl,
                  keyboard: TextInputType.emailAddress, isEmail: true,),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _submitting
                      ? const CircularProgressIndicator()
                      : const Text('SUBMIT'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl,
      {TextInputType keyboard = TextInputType.text, bool isEmail = false,}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'eg: ${label.split(' ').last}...',
        border: const UnderlineInputBorder(),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) {
          return 'Please enter $label';
        }
        if (isEmail) {
          final email = v.trim().toLowerCase();
          if (!email.endsWith('@peninsulamalaysia.edu.my')) {
            return 'Please use your Peninsula email address';
          }
        }
        return null;
      },
    );
  }
}
