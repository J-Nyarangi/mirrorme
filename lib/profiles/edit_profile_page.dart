import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController _displayNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _cityController = TextEditingController();
  TextEditingController _countryController = TextEditingController();
  TextEditingController _genderController = TextEditingController();
  TextEditingController _birthdayController = TextEditingController();
  File? _avatarImage;

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch user data when the widget is initialized
  }

  void _fetchUserData() async {
    // Fetch the logged-in user details from Firebase Authentication
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _displayNameController.text = user.displayName ?? '';
        _emailController.text = user.email ?? '';
      });
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _genderController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  Future<void> _selectAvatarImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _avatarImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2023),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.teal, // Set the primary color to teal
            colorScheme: ColorScheme.light(primary: Colors.teal), // Set the color scheme to use teal as the primary color
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _birthdayController.text = pickedDate.toString(); // Update the text field with the selected date
      });
    }
  }

  void _selectCountry() {
    showCountryPicker(
      context: context,
      showPhoneCode: true, // Show the phone code in the country picker
      onSelect: (Country country) {
        setState(() {
          _countryController.text = country.displayNameNoCountryCode; // Update the text field with the selected country
          _phoneController.text = '+' + country.phoneCode; // Update the phone number field with the selected country's phone code
        });
      },
    );
  }

  Future<void> _selectGender() async {
    final String? selectedGender = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select Gender'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Female');
              },
              child: const Text('Female'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Male');
              },
              child: const Text('Male'),
            ),
          ],
        );
      },
    );

    if (selectedGender != null) {
      setState(() {
        _genderController.text = selectedGender; // Update the text field with the selected gender
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            GestureDetector(
              onTap: _selectAvatarImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _avatarImage != null ? FileImage(_avatarImage!) : null,
                child: _avatarImage == null ? Icon(Icons.person) : null,
              ),
            ),
            SizedBox(height: 16),
            _buildRoundedTextField(_displayNameController, 'Display Name'),
            SizedBox(height: 16),
            _buildRoundedTextField(_emailController, 'Email', enabled: false), // Email text field disabled
            SizedBox(height: 16),
            _buildRoundedTextField(_phoneController, 'Phone', onChanged: (value) {
              setState(() {
                _phoneController.text = '+' + (_countryController.text.isNotEmpty ? _countryController.text.substring(1) : '') + value; // Update the phone number field with the selected country's phone code and the entered phone number
              });
            }),
            SizedBox(height: 16),
            _buildRoundedTextField(_cityController, 'City'),
            SizedBox(height: 16),
            _buildRoundedTextField(_countryController, 'Country', onTap: _selectCountry),
            SizedBox(height: 16),
            GestureDetector(
              onTap: _selectGender,
              child: AbsorbPointer(
                child: _buildRoundedTextField(_genderController, 'Gender'),
              ),
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: _selectDate,
              child: AbsorbPointer(
                child: _buildRoundedTextField(_birthdayController, 'Birthday'),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Save button logic here
                final displayName = _displayNameController.text;
                final email = _emailController.text;
                final country = _countryController.text;
                final city = _cityController.text;
                final phone = _phoneController.text;
                final gender = _genderController.text;
                final birthday = _birthdayController.text;

                // Implement the save functionality according to your requirements

                // After saving, you can navigate back to the user profile page or any other desired page
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundedTextField(TextEditingController controller, String labelText, {Function()? onTap, Function(String)? onChanged, bool enabled = true}) {
    return TextField(
      controller: controller,
      enabled: enabled,
      onTap: onTap,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }
}
