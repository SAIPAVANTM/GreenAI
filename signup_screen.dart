import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenai/url.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:location/location.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _landSizeController = TextEditingController();

  List<String> _selectedCrops = [];
  String? _selectedLanguage;
  double? latitude;
  double? longitude;

  final List<String> languages = [
    'Assamese', 'Bengali', 'Bodo', 'Dogri', 'Gujarati', 'English', 'Hindi',
    'Kannada', 'Kashmiri', 'Konkani', 'Maithili', 'Malayalam', 'Manipuri',
    'Marathi', 'Nepali', 'Odia', 'Punjabi', 'Sanskrit', 'Santali', 'Sindhi',
    'Tamil', 'Telugu', 'Urdu',
  ];

  final List<String> crops = [
    'Wheat', 'Rice', 'Maize', 'Millets', 'Barley', 'Sugarcane', 'Cotton',
    'Tea', 'Coffee', 'Groundnut', 'Mustard', 'Sunflower', 'Sesame',
    'Tobacco', 'Potato', 'Onion', 'Tomato', 'Chili', 'Banana', 'Mango',
    'Coconut', 'Apple', 'Pear', 'Plum', 'Orange', 'Guava',
  ];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _retrieveLocation();
  }

  Future<void> _retrieveLocation() async {
    Location location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        Get.snackbar('Location Disabled', 'Please enable location services');
        return;
      }
    }

    var permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        Get.snackbar('Permission Denied', 'Location permission is required');
        return;
      }
    }

    LocationData locationData = await location.getLocation();

    setState(() {
      latitude = locationData.latitude;
      longitude = locationData.longitude;
    });
  }

  Future<bool> sendOtp(String email) async {
    final url = Uri.parse('${Url.Urls}/send_otp');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data['status'] == 'success';
    }
    return false;
  }

  Future<bool> verifyOtp(String email, String otp) async {
    final url = Uri.parse('${Url.Urls}/verify_otp');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp}),
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data['status'] == 'success';
    }
    return false;
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedLanguage == null) {
      Get.snackbar('Error', 'Please select a Language');
      return;
    }
    if (_selectedCrops.isEmpty) {
      Get.snackbar('Error', 'Please select at least one Crop');
      return;
    }
    if (latitude == null || longitude == null) {
      Get.snackbar('Error', 'Unable to detect location');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('${Url.Urls}/userdetails');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "name": _nameController.text.trim(),
        "email": _emailController.text.trim(),
        "mobile": _mobileController.text.trim(),
        "language": _selectedLanguage,
        "crops": _selectedCrops.join(", "),
        "location": "${latitude.toString()},${longitude.toString()}",
        "land_size": _landSizeController.text.trim(),
      }),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 201) {
      bool otpResult = await sendOtp(_emailController.text.trim());
      if (otpResult) {
        _showOtpDialog();
      } else {
        Get.snackbar('OTP Error', 'Failed to send OTP', backgroundColor: Colors.red);
      }
    } else {
      var errorData = jsonDecode(response.body);
      Get.snackbar('Signup Failed', errorData['message'] ?? 'Please verify details & try again',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void _showOtpDialog() {
    final TextEditingController otpController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFFBEC1BC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/sprout.png', width: 80, height: 80),
                const SizedBox(height: 16),
                const Text(
                  'GREENGRAM',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                      color: Colors.black87),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter OTP',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50)),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  decoration: const InputDecoration(
                      hintText: 'Enter OTP',
                      hintStyle: TextStyle(
                        color: Colors.black54,
                        letterSpacing: 2,
                      ),
                      border: InputBorder.none,
                      counterText: ''),
                  style: const TextStyle(
                      fontSize: 24,
                      letterSpacing: 4,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () async {
                        if (otpController.text.trim().length != 6) {
                          Get.snackbar('Invalid OTP', 'OTP must be 6 digits',
                              backgroundColor: Colors.red,
                              colorText: Colors.white);
                          return;
                        }
                        bool verified = await verifyOtp(
                            _emailController.text.trim(), otpController.text.trim());
                        if (verified) {
                          Navigator.pop(context);
                          Get.snackbar('Registration Successful', 'Welcome to GREENGRAM!',
                              backgroundColor: Colors.green, colorText: Colors.white);
                          Get.offNamed('/home');
                        } else {
                          Get.snackbar('OTP Error', 'Invalid OTP',
                              backgroundColor: Colors.red,
                              colorText: Colors.white);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24))),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Colors.white),
                      )),
                )
              ]
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(
          color: const Color(0xFF81B784),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ]),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: (val) => val == null || val.isEmpty ? 'Enter $label' : null,
        decoration: InputDecoration(
          hintText: label,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildLanguageDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedLanguage,
      validator: (val) => val == null ? 'Select Language' : null,
      decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFF81B784),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide.none),
          hintText: 'Select Language',
          prefixIcon: const Icon(Icons.language, color: Color(0xFF4CAF50)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
      items: languages
          .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
          .toList(),
      onChanged: (val) {
        setState(() {
          _selectedLanguage = val;
        });
      },
    );
  }

  Widget _buildCrops() {
    return MultiSelectDialogField<String>(
      items: crops.map((crop) => MultiSelectItem(crop, crop)).toList(),
      title: const Text("Select Crops"),
      buttonText: const Text(
        "Select Crops",
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      buttonIcon: const Icon(
        Icons.agriculture,
        color: Colors.white,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF81B784),
        borderRadius: BorderRadius.circular(28),
      ),
      validator: (values) {
        if (values == null || values.isEmpty) return "Please select at least one crop";
        return null;
      },
      onConfirm: (selected) {
        setState(() {
          _selectedCrops = selected;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBEC1BC),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Image.asset('assets/sprout.png', width: 100, height: 100),
              const SizedBox(height: 16),
              const Text(
                'GREENGRAM',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                    color: Colors.black87),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign Up',
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50)),
              ),
              const SizedBox(height: 32),
              _buildTextField('Name', _nameController),
              const SizedBox(height: 16),
              _buildTextField('Email', _emailController,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _buildTextField('Mobile', _mobileController,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              _buildLanguageDropdown(),
              const SizedBox(height: 16),
              _buildCrops(),
              const SizedBox(height: 16),
              if (latitude != null && longitude != null)
                Text(
                  'Lat: ${latitude!.toStringAsFixed(6)}, Lon: ${longitude!.toStringAsFixed(6)}',
                  style: const TextStyle(color: Colors.black54),
                ),
              const SizedBox(height: 16),
              _buildTextField('Land Size', _landSizeController),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF388E3C),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'SIGN UP',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account? ",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.toNamed('/login'),
                    child: const Text(
                      'Log In',
                      style: TextStyle(
                        color: Color(0xFF4CAF50),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xFF4CAF50),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
