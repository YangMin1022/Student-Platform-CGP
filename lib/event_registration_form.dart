import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EventRegistrationForm extends StatefulWidget {
  final String eventTitle;
  final VoidCallback onRegistered; // Callback to update registration status

  const EventRegistrationForm(
      {super.key, required this.eventTitle, required this.onRegistered});

  @override
  _EventRegistrationFormState createState() => _EventRegistrationFormState();
}

class _EventRegistrationFormState extends State<EventRegistrationForm> {
  final _formKey = GlobalKey<FormState>();

  String studentName = '';
  String studentID = '';
  String studentEmail = '';
  String category = '';
  String emergencyContactName = '';
  String emergencyContactNumber = '';
  String emergencyContactRelationship = '';

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Show a Toast message upon successful registration
      Fluttertoast.showToast(
        msg: "Successfully registered for ${widget.eventTitle}!",
        backgroundColor: Colors.green,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );

      widget.onRegistered(); // Update registration status in EventsPage

      Navigator.pop(context); // Close form after submission
    }
  }

  Widget _buildTextField(String label, String hint, Function(String?) onSave,
      {String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          TextFormField(
            decoration: InputDecoration(hintText: hint),
            validator: validator ??
                (value) => value!.isEmpty ? "Please enter $label" : null,
            onSaved: onSave,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.eventTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField("Student Name", "Enter your full name",
                  (value) => studentName = value!),
              _buildTextField("Student ID", "Enter your student ID",
                  (value) => studentID = value!),
              _buildTextField("Student Email", "Enter your email",
                  (value) => studentEmail = value!,
                  validator: (value) =>
                      !value!.contains('@') ? "Enter a valid email" : null),
              _buildTextField("Category", "Enter your category (e.g., UG, PG)",
                  (value) => category = value!),
              _buildTextField(
                  "Emergency Contact Name",
                  "Enter emergency contact name",
                  (value) => emergencyContactName = value!),
              _buildTextField(
                  "Emergency Contact Number",
                  "Enter emergency contact number",
                  (value) => emergencyContactNumber = value!,
                  validator: (value) =>
                      value!.length < 10 ? "Enter a valid phone number" : null),
              _buildTextField(
                  "Emergency Contact Relationship",
                  "Enter relationship (e.g., Parent, Sibling)",
                  (value) => emergencyContactRelationship = value!),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text("Submit Registration"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
