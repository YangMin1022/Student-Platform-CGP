
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditEventPage extends StatefulWidget {
  final String clubId;
  final String eventId;
  final Map<String, dynamic> existingData;

  const EditEventPage({
    Key? key,
    required this.clubId,
    required this.eventId,
    required this.existingData,
  }) : super(key: key);

  @override
  _EditEventPageState createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  late TextEditingController _nameController;
  late TextEditingController _organizerController;
  late TextEditingController _venueController;
  late TextEditingController _dateController;
  late TextEditingController _timeController;
  late TextEditingController _categoryController;
  late TextEditingController _feeController;
  late TextEditingController _descriptionController;
  late TextEditingController _transportationController;
  late TextEditingController _numParticipantsController;
  late TextEditingController _coverPicController;
  late TextEditingController _googleFormController;

  @override
  void initState() {
    super.initState();
    final data = widget.existingData;
    _nameController            = TextEditingController(text: data['eventName'] ?? '');
    _organizerController       = TextEditingController(text: data['eventOrganizer'] ?? '');
    _venueController           = TextEditingController(text: data['eventVenue'] ?? '');
    _dateController            = TextEditingController(text: data['eventDate'] ?? '');
    _timeController            = TextEditingController(text: data['eventTime'] ?? '');
    _categoryController        = TextEditingController(text: data['eventCategory'] ?? '');
    _feeController             = TextEditingController(text: data['eventFee'] ?? '');
    _descriptionController     = TextEditingController(text: data['eventDescription'] ?? '');
    _transportationController  = TextEditingController(text: data['eventTransportation'] ?? '');
    _numParticipantsController = TextEditingController(text: data['numParticipants']?.toString() ?? '');
    _coverPicController        = TextEditingController(text: data['eventCoverPic'] ?? '');
    _googleFormController      = TextEditingController(text: data['googleFormLink'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _organizerController.dispose();
    _venueController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _categoryController.dispose();
    _feeController.dispose();
    _descriptionController.dispose();
    _transportationController.dispose();
    _numParticipantsController.dispose();
    _coverPicController.dispose();
    _googleFormController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance
          .collection('clubs')
          .doc(widget.clubId)
          .collection('events')
          .doc(widget.eventId)
          .update({
        'eventName': _nameController.text.trim(),
        'eventOrganizer': _organizerController.text.trim(),
        'eventVenue': _venueController.text.trim(),
        'eventDate': _dateController.text.trim(),
        'eventTime': _timeController.text.trim(),
        'eventCategory': _categoryController.text.trim(),
        'eventFee': _feeController.text.trim(),
        'eventDescription': _descriptionController.text.trim(),
        'eventTransportation': _transportationController.text.trim(),
        'numParticipants': _numParticipantsController.text.trim(),
        'eventCoverPic': _coverPicController.text.trim(),
        'googleFormLink': _googleFormController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event updated successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update event: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool numeric = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType:
            numeric ? TextInputType.number : TextInputType.text,
        validator: (val) =>
            val == null || val.isEmpty ? 'Please enter $label' : null,
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
        title: const Text('Edit Event'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTextField('Event Name', _nameController),
            _buildTextField('Organizer', _organizerController),
            _buildTextField('Venue', _venueController),
            _buildTextField('Date', _dateController),
            _buildTextField('Time', _timeController),
            _buildTextField('Category', _categoryController),
            _buildTextField('Fee', _feeController),
            _buildTextField('Description', _descriptionController),
            _buildTextField(
                'Transportation', _transportationController),
            _buildTextField('Number of Participants',
                _numParticipantsController,
                numeric: true),
            _buildTextField('Cover Image URL', _coverPicController),
            _buildTextField('Google Form Link', _googleFormController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _saveChanges,
              child: _isSubmitting
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
