import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenai/url.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:location/location.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, String> userInfo = {};
  bool _isLoading = true;
  Location location = Location();

  // Controllers for edit form
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    try {
      final url = Uri.parse('${Url.Urls}/get_active_user_details');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          var userData = data['data'];

          setState(() {
            userInfo = {
              'Name': userData['name'] ?? 'N/A',
              'Email': userData['email'] ?? 'N/A',
              'Mobile': userData['mobile'] ?? 'N/A',
              'Language': userData['language'] ?? 'N/A',
              'Location': userData['location'] ?? 'N/A',
              'Crops': userData['crops'] ?? 'N/A',
              'Land Size': userData['land_size'] ?? 'N/A',
            };
            _isLoading = false;
          });

          // Initialize controllers with fetched values
          userInfo.forEach((key, value) {
            _controllers[key] = TextEditingController(text: value);
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        Get.snackbar('Error', 'Failed to load user details: ${response.statusCode}',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Get.snackbar('Error', 'Network error: ${e.toString()}',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // Update profile with PUT request
  Future<void> _updateProfile() async {
    try {
      final url = Uri.parse('${Url.Urls}/update_user_profile');

      // Get current location
      String currentLocation = await _getCurrentLocation();

      final Map<String, dynamic> payload = {
        'name': _controllers['Name']?.text ?? '',
        'email': _controllers['Email']?.text ?? '',
        'mobile': _controllers['Mobile']?.text ?? '',
        'language': _controllers['Language']?.text ?? '',
        'location': currentLocation, // Update with current coordinates
        'crops': _controllers['Crops']?.text ?? '',
        'land_size': _controllers['Land Size']?.text ?? '',
      };

      print('Update payload: ${jsonEncode(payload)}');

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      print('Update response status: ${response.statusCode}');
      print('Update response body: ${response.body}');

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          // Update local userInfo with new values including current location
          setState(() {
            userInfo.forEach((key, value) {
              if (key == 'Location') {
                userInfo[key] = currentLocation;
              } else {
                userInfo[key] = _controllers[key]?.text ?? value;
              }
            });
          });

          Navigator.pop(context);
          Get.snackbar(
            'Profile Updated',
            'Your profile has been successfully updated with current location!',
            backgroundColor: const Color(0xFF4CAF50).withOpacity(0.9),
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 3),
            icon: const Icon(Icons.check_circle, color: Colors.white),
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
          );
        }
      } else {
        Get.snackbar(
          'Update Failed',
          'Failed to update profile: ${response.statusCode}',
          backgroundColor: Colors.red.withOpacity(0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('Update error: $e');
      Get.snackbar(
        'Update Error',
        'Error updating profile: ${e.toString()}',
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Get current location coordinates using location package
  Future<String> _getCurrentLocation() async {
    try {
      // Check if location service is enabled
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          Get.snackbar(
            'Location Services',
            'Please enable location services',
            backgroundColor: Colors.orange.withOpacity(0.9),
            colorText: Colors.white,
          );
          return userInfo['Location'] ?? 'N/A';
        }
      }

      // Check location permissions
      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          Get.snackbar(
            'Location Permission',
            'Location permission denied',
            backgroundColor: Colors.red.withOpacity(0.9),
            colorText: Colors.white,
          );
          return userInfo['Location'] ?? 'N/A';
        }
      }

      if (permissionGranted == PermissionStatus.deniedForever) {
        Get.snackbar(
          'Location Permission',
          'Location permissions are permanently denied',
          backgroundColor: Colors.red.withOpacity(0.9),
          colorText: Colors.white,
        );
        return userInfo['Location'] ?? 'N/A';
      }

      // Get current location
      LocationData locationData = await location.getLocation();

      return '${locationData.latitude},${locationData.longitude}';
    } catch (e) {
      print('Location error: $e');
      Get.snackbar(
        'Location Error',
        'Could not get current location: ${e.toString()}',
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
      );
      return userInfo['Location'] ?? 'N/A';
    }
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBDBDBD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 26),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'PROFILE',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black, size: 24),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _fetchUserDetails();
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black, size: 24),
            onPressed: () => _showEditProfileDialog(),
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
          child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
        )
            : userInfo.isEmpty
            ? const Center(
          child: Text(
            'No user data available',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        )
            : SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildProfilePictureSection(),
              const SizedBox(height: 30),
              ...userInfo.entries.map((entry) =>
                  _buildProfileInfoCard(entry.key, entry.value)).toList(),
              const SizedBox(height: 40),
              Container(
                width: double.infinity,
                child: _buildActionButton(
                  'Edit Profile',
                  Icons.edit,
                  const Color(0xFF4CAF50),
                      () => _showEditProfileDialog(),
                ),
              ),
              const SizedBox(height: 20),
              _buildFarmingStatsCard(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF4CAF50), width: 4),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const CircleAvatar(
                radius: 58,
                backgroundColor: Color(0xFF81C784),
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => _showImagePickerOptions(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          userInfo['Name'] ?? 'User Name',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            'Active Farmer',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4CAF50),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfoCard(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF4CAF50).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getIconForLabel(label),
              size: 20,
              color: const Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmingStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF4CAF50).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Farming Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Total Crops', _getCropCount(), Icons.agriculture),
              ),
              Expanded(
                child: _buildStatItem('Land Size', userInfo['Land Size'] ?? '0 Acres', Icons.landscape),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getCropCount() {
    String crops = userInfo['Crops'] ?? '';
    if (crops.isEmpty || crops == 'N/A') return '0';
    return crops.split(',').length.toString();
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: const Color(0xFF4CAF50)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForLabel(String label) {
    switch (label.toLowerCase()) {
      case 'name': return Icons.person;
      case 'email': return Icons.email;
      case 'mobile': return Icons.phone;
      case 'language': return Icons.language;
      case 'location': return Icons.location_on;
      case 'crops': return Icons.agriculture;
      case 'land size': return Icons.landscape;
      default: return Icons.info;
    }
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFBDBDBD),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            fontSize: 20,
          ),
        ),
        content: Container(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: userInfo.keys.where((key) => key != 'Location').map((key) =>
                  _buildEditField(key)).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFF4CAF50),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => _updateProfile(), // Call the PUT request
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Save Changes',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditField(String key) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            key,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF4CAF50).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: TextField(
              controller: _controllers[key],
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                hintText: 'Enter $key',
                hintStyle: const TextStyle(color: Colors.black54),
              ),
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
              ),
              keyboardType: key == 'Email' ? TextInputType.emailAddress :
              key == 'Mobile' ? TextInputType.phone :
              TextInputType.text,
            ),
          ),
        ],
      ),
    );
  }

  void _showImagePickerOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFFBDBDBD),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Change Profile Picture',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF4CAF50)),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                Get.snackbar(
                  'Camera',
                  'Camera functionality will be implemented',
                  backgroundColor: const Color(0xFF4CAF50).withOpacity(0.2),
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF4CAF50)),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                Get.snackbar(
                  'Gallery',
                  'Gallery functionality will be implemented',
                  backgroundColor: const Color(0xFF4CAF50).withOpacity(0.2),
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Remove Photo'),
              onTap: () {
                Navigator.pop(context);
                Get.snackbar(
                  'Removed',
                  'Profile picture removed',
                  backgroundColor: Colors.red.withOpacity(0.2),
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
