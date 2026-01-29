import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/providers.dart';
import 'main_scaffold.dart';
import 'package:poem_diary/l10n/app_localizations.dart';
import 'package:poem_diary/services/notification_service.dart';
import '../helpers/notification_permission_helper.dart';

class SetupProfileScreen extends StatefulWidget {
  final bool isEditMode;

  const SetupProfileScreen({super.key, this.isEditMode = false});

  @override
  State<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends State<SetupProfileScreen> {
  late TextEditingController _nameController;
  String? _selectedImagePath;
  bool _isReminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 21, minute: 0);

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<MoodProvider>(context, listen: false);

    _nameController = TextEditingController(
      text: widget.isEditMode ? provider.userName : '',
    );
    if (widget.isEditMode) {
      _selectedImagePath = provider.profileImagePath;
    }
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isReminderEnabled = prefs.getBool('daily_reminder_enabled') ?? false;
      final hour = prefs.getInt('daily_reminder_hour') ?? 21;
      final minute = prefs.getInt('daily_reminder_minute') ?? 0;
      _reminderTime = TimeOfDay(hour: hour, minute: minute);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImagePath = image.path;
      });
    }
  }

  Future<void> _completeSetup() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.nameRequiredMsg)),
      );
      return;
    }

    final provider = Provider.of<MoodProvider>(context, listen: false);
    await provider.updateUserProfile(
      name,
      provider.userTitle,
      _selectedImagePath,
    );

    if (!widget.isEditMode) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_setup_done', true);
    }

    if (mounted) {
      if (widget.isEditMode) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.profileUpdatedMsg),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScaffold()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: widget.isEditMode
          ? AppBar(
              title: Text(
                AppLocalizations.of(context)!.editProfileTitle,
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(
                  Icons.close,
                  color: isDark ? Colors.white : Colors.black,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              if (!widget.isEditMode) ...[
                const SizedBox(height: 60),
                Text(
                  AppLocalizations.of(context)!.welcomeTitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.welcomeSubtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 48),
              ] else ...[
                const SizedBox(height: 20),
              ],

              // Photo Picker
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: isDark
                          ? Colors.white10
                          : Colors.grey[200],
                      backgroundImage: _selectedImagePath != null
                          ? FileImage(File(_selectedImagePath!))
                          : null,
                      onBackgroundImageError: _selectedImagePath != null
                          ? (exception, stackTrace) {
                              debugPrint(
                                'Error loading profile image: $exception',
                              );
                            }
                          : null,
                      child: _selectedImagePath == null
                          ? const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Name Input
              TextField(
                controller: _nameController,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.nameHint,
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white24 : Colors.black12,
                  ),
                ),
              ),
              Container(
                height: 2,
                width: 120,
                color: isDark ? Colors.white24 : Colors.black12,
              ),

              const SizedBox(height: 32),

              // Daily Reminder Section
              _buildDailyReminderSection(context, isDark),

              const SizedBox(height: 32),

              const SizedBox(height: 60),

              // Start/Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _completeSetup,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 5,
                    shadowColor: Colors.blueAccent.withOpacity(0.4),
                  ),
                  child: Text(
                    widget.isEditMode
                        ? AppLocalizations.of(context)!.saveBtn
                        : AppLocalizations.of(context)!.startBtn,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyReminderSection(BuildContext context, bool isDark) {
    return Column(
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            AppLocalizations.of(context)!.dailyReminder,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          subtitle: Text(
            AppLocalizations.of(context)!.dailyReminderDesc,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
          ),
          value: _isReminderEnabled,
          onChanged: (val) async {
            setState(() => _isReminderEnabled = val);
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('daily_reminder_enabled', val);

            if (val) {
              await NotificationService().requestPermissions();

              // Show permission dialogs for Android
              if (mounted && Platform.isAndroid) {
                await NotificationPermissionHelper.showExactAlarmPermissionDialog(
                  context,
                );
              }

              if (mounted) {
                await NotificationService().scheduleDailyReminder(
                  _reminderTime,
                  AppLocalizations.of(context)!.notificationDailyTitle,
                  AppLocalizations.of(context)!.notificationDailyBody,
                );
              }
            } else {
              await NotificationService().cancelDailyReminder();
            }
          },
          activeColor: Colors.blueAccent,
        ),
        if (_isReminderEnabled)
          GestureDetector(
            onTap: () async {
              final pickedTime = await showTimePicker(
                context: context,
                initialTime: _reminderTime,
              );
              if (pickedTime != null) {
                setState(() => _reminderTime = pickedTime);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setInt('daily_reminder_hour', pickedTime.hour);
                await prefs.setInt('daily_reminder_minute', pickedTime.minute);

                if (mounted) {
                  await NotificationService().scheduleDailyReminder(
                    _reminderTime,
                    AppLocalizations.of(context)!.notificationDailyTitle,
                    AppLocalizations.of(context)!.notificationDailyBody,
                  );
                }
              }
            },
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.white24 : Colors.grey[300]!,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${_reminderTime.format(context)}",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const Icon(
                    Icons.access_time_rounded,
                    color: Colors.blueAccent,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
