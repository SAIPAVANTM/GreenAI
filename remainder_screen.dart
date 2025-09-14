import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenai/rem_model.dart';
import 'package:greenai/rem_service.dart';
import 'package:greenai/notification_service.dart';
import 'package:intl/intl.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _cropController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _intervalController = TextEditingController();

  final ReminderService _reminderService = ReminderService();
  final NotificationService _notificationService = NotificationService();

  String? selectedReminderType;
  String? selectedCrop;
  String? selectedInterval;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  List<ReminderModel> activeReminders = [];
  bool isLoadingReminders = false;
  bool isSubmitting = false;

  final List<String> reminderTypes = [
    'Irrigation', 'Fertilization', 'Pesticide Spray', 'Harvesting',
    'Planting', 'Pruning', 'Soil Testing', 'General Care'
  ];

  final List<String> cropTypes = [
    'Wheat', 'Rice', 'Cotton', 'Sugarcane', 'Corn', 'Tomato',
    'Potato', 'Onion', 'Soybean', 'Groundnut', 'Barley', 'Millet'
  ];

  final List<String> intervals = [
    'Once', 'Daily', 'Weekly', 'Bi-weekly', 'Monthly', 'Quarterly'
  ];

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    setState(() {
      isLoadingReminders = true;
    });

    try {
      final response = await _reminderService.getReminders();
      if (response['success'] == true && response['reminders'] != null) {
        setState(() {
          activeReminders = (response['reminders'] as List)
              .map((json) => ReminderModel.fromJson(json))
              .where((reminder) => reminder.isActive)
              .toList();
        });
      } else {
        if (mounted) {
          Get.snackbar(
            'Info',
            'No reminders found or server error',
            backgroundColor: Colors.orange.withOpacity(0.8),
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to load reminders: $e',
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      }
    }

    if (mounted) {
      setState(() {
        isLoadingReminders = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _cropController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _intervalController.dispose();
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
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: 26,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'SET REMINDER',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildHeaderSection(),
                const SizedBox(height: 40),

                _buildProfessionalDropdown(
                  label: 'Reminder Type',
                  hint: 'Select reminder type',
                  value: selectedReminderType,
                  items: reminderTypes,
                  icon: Icons.notifications_active,
                  onChanged: (value) {
                    setState(() {
                      selectedReminderType = value;
                      _titleController.text = value ?? '';
                    });
                  },
                ),
                const SizedBox(height: 24),

                _buildProfessionalDropdown(
                  label: 'Crop Type',
                  hint: 'Select your crop',
                  value: selectedCrop,
                  items: cropTypes,
                  icon: Icons.agriculture,
                  onChanged: (value) {
                    setState(() {
                      selectedCrop = value;
                      _cropController.text = value ?? '';
                    });
                  },
                ),
                const SizedBox(height: 24),

                _buildDateField(),
                const SizedBox(height: 24),

                _buildTimeField(),
                const SizedBox(height: 24),

                _buildProfessionalDropdown(
                  label: 'Repeat Interval',
                  hint: 'How often to repeat',
                  value: selectedInterval,
                  items: intervals,
                  icon: Icons.repeat,
                  onChanged: (value) {
                    setState(() {
                      selectedInterval = value;
                      _intervalController.text = value ?? '';
                    });
                  },
                ),
                const SizedBox(height: 40),

                _buildSetReminderButton(),
                const SizedBox(height: 16),

                _buildTestNotificationButton(),
                const SizedBox(height: 30),

                _buildActiveRemindersCard(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(24),
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
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.schedule,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Smart Farming Reminders',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Never miss important farming activities with automated reminders',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalDropdown({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
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
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.black54),
              prefixIcon: Icon(icon, color: const Color(0xFF4CAF50)),
            ),
            items: items.map((item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            )).toList(),
            onChanged: onChanged,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select $label';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date',
          style: TextStyle(
            fontSize: 16,
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
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: _dateController,
            readOnly: true,
            onTap: () => _selectDate(),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              hintText: 'Select reminder date',
              hintStyle: TextStyle(color: Colors.black54),
              prefixIcon: Icon(Icons.calendar_today, color: Color(0xFF4CAF50)),
              suffixIcon: Icon(Icons.arrow_drop_down, color: Color(0xFF4CAF50)),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a date';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Time',
          style: TextStyle(
            fontSize: 16,
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
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: _timeController,
            readOnly: true,
            onTap: () => _selectTime(),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              hintText: 'Select reminder time',
              hintStyle: TextStyle(color: Colors.black54),
              prefixIcon: Icon(Icons.access_time, color: Color(0xFF4CAF50)),
              suffixIcon: Icon(Icons.arrow_drop_down, color: Color(0xFF4CAF50)),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a time';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSetReminderButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isSubmitting ? null : _setReminder,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          disabledBackgroundColor: Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 8,
          shadowColor: const Color(0xFF4CAF50).withOpacity(0.3),
        ),
        child: isSubmitting
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notification_add, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Set Reminder',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestNotificationButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: () async {
          await _notificationService.showImmediateNotification(
            title: 'Test Notification',
            body: 'Your farming reminder notifications are working!',
            payload: 'test_notification',
          );
          Get.snackbar(
            'Test Sent',
            'Check your notifications!',
            backgroundColor: Colors.blue.withOpacity(0.9),
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2),
          );
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF4CAF50), width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        icon: const Icon(Icons.notification_add, color: Color(0xFF4CAF50)),
        label: const Text(
          'Test Notification',
          style: TextStyle(
            color: Color(0xFF4CAF50),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildActiveRemindersCard() {
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
          Row(
            children: [
              const Icon(
                Icons.notifications_active,
                color: Color(0xFF4CAF50),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Active Reminders',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(
                  Icons.refresh,
                  color: Color(0xFF4CAF50),
                  size: 20,
                ),
                onPressed: isLoadingReminders ? null : _loadReminders,
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (isLoadingReminders)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                ),
              ),
            )
          else if (activeReminders.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.notifications_off,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'No active reminders yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Create your first reminder above',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black38,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: activeReminders.map((reminder) => _buildReminderItem(reminder)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildReminderItem(ReminderModel reminder) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF4CAF50).withOpacity(0.1),
          width: 1,
        ),
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
              reminder.iconData,
              color: const Color(0xFF4CAF50),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${reminder.reminderType} - ${reminder.cropType}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reminder.formattedDateTime,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              reminder.intervalType,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4CAF50),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            onPressed: () => _showDeleteConfirmation(reminder),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(ReminderModel reminder) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Reminder'),
        content: Text('Are you sure you want to delete the reminder for ${reminder.reminderType} - ${reminder.cropType}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _deleteReminder(reminder.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteReminder(int reminderId) async {
    try {
      final response = await _reminderService.deleteReminder(reminderId);
      if (response['success'] == true) {
        Get.snackbar(
          'Success',
          'Reminder deleted successfully',
          backgroundColor: Colors.green.withOpacity(0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          duration: const Duration(seconds: 2),
        );
        await _loadReminders();
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Failed to delete reminder',
          backgroundColor: Colors.red.withOpacity(0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          icon: const Icon(Icons.error, color: Colors.white),
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Network error occurred',
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4CAF50),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4CAF50),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  Future<void> _setReminder() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isSubmitting = true;
      });

      try {
        final timeString = selectedTime != null
            ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
            : '';

        final response = await _reminderService.createReminder(
          reminderType: selectedReminderType!,
          cropType: selectedCrop!,
          date: _dateController.text,
          time: timeString,
          intervalType: selectedInterval!,
        );

        if (response['success'] == true) {
          Get.snackbar(
            'Success!',
            'Reminder has been set successfully for ${selectedReminderType}',
            backgroundColor: const Color(0xFF4CAF50).withOpacity(0.9),
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 3),
            icon: const Icon(Icons.check_circle, color: Colors.white),
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
          );

          _clearForm();
          await _loadReminders();
        } else {
          Get.snackbar(
            'Error',
            response['message'] ?? 'Failed to create reminder',
            backgroundColor: Colors.red.withOpacity(0.9),
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            icon: const Icon(Icons.error, color: Colors.white),
            duration: const Duration(seconds: 4),
          );
        }
      } catch (e) {
        Get.snackbar(
          'Error',
          'Network error. Please check your connection and try again.',
          backgroundColor: Colors.red.withOpacity(0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          icon: const Icon(Icons.wifi_off, color: Colors.white),
          duration: const Duration(seconds: 4),
        );
      } finally {
        if (mounted) {
          setState(() {
            isSubmitting = false;
          });
        }
      }
    } else {
      Get.snackbar(
        'Incomplete Form',
        'Please fill all required fields to continue',
        backgroundColor: Colors.orange.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        icon: const Icon(Icons.warning, color: Colors.white),
        duration: const Duration(seconds: 3),
      );
    }
  }

  void _clearForm() {
    setState(() {
      selectedReminderType = null;
      selectedCrop = null;
      selectedInterval = null;
      selectedDate = null;
      selectedTime = null;
      _titleController.clear();
      _cropController.clear();
      _dateController.clear();
      _timeController.clear();
      _intervalController.clear();
    });
  }
}