import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  late TextEditingController _nameCtrl;
  late TextEditingController _usernameCtrl;
  late TextEditingController _bioCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _phoneCtrl;

  bool _initialized = false;
  bool _isSaving = false;
  String? _pickedImagePath;
  String? _selectedAvatarUrl;

  final List<String> _presetAvatars = [
    'https://api.dicebear.com/7.x/bottts/png?seed=Felix',
    'https://api.dicebear.com/7.x/bottts/png?seed=Bella',
    'https://api.dicebear.com/7.x/bottts/png?seed=Charlie',
    'https://api.dicebear.com/7.x/bottts/png?seed=Luna',
    'https://api.dicebear.com/7.x/bottts/png?seed=Milo',
    'https://api.dicebear.com/7.x/bottts/png?seed=Rocky',
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _usernameCtrl = TextEditingController();
    _bioCtrl = TextEditingController();
    _cityCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
  }

  void _populateUserData(dynamic user) {
    if (_initialized || user == null) return;
    _nameCtrl.text = user.fullName;
    _usernameCtrl.text = user.username;
    _bioCtrl.text = user.bio;
    _cityCtrl.text = user.city;
    _phoneCtrl.text = user.phoneNumber;
    _selectedAvatarUrl = user.avatarUrl;
    _initialized = true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _bioCtrl.dispose();
    _cityCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context);
    try {
      final XFile? image = await _picker.pickImage(source: source, imageQuality: 80);
      if (image != null) {
        setState(() {
          _pickedImagePath = image.path;
          _selectedAvatarUrl = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  void _showAvatarOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Change Profile Photo',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: Colors.blue),
                title: const Text('Choose from Gallery'),
                onTap: () => _pickImage(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: Colors.green),
                title: const Text('Take a Photo'),
                onTap: () => _pickImage(ImageSource.camera),
              ),
              const Divider(height: 24),
              const Text('Or Choose an Avatar Style:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              SizedBox(
                height: 60,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _presetAvatars.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, idx) {
                    final avatar = _presetAvatars[idx];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedAvatarUrl = avatar;
                          _pickedImagePath = null;
                        });
                        Navigator.pop(ctx);
                      },
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: CachedNetworkImageProvider(avatar),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(
          fullName: _nameCtrl.text.trim(),
          username: _usernameCtrl.text.trim(),
          phoneNumber: _phoneCtrl.text.trim(),
          city: _cityCtrl.text.trim(),
          bio: _bioCtrl.text.trim(),
          avatarUrl: _selectedAvatarUrl,
        );

        await ref.read(currentUserProvider.notifier).updateProfile(
              updatedUser,
              imagePath: _pickedImagePath,
            );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  ImageProvider _getAvatarImage(String defaultUrl) {
    if (_pickedImagePath != null) {
      if (kIsWeb) {
        return NetworkImage(_pickedImagePath!);
      } else {
        return FileImage(File(_pickedImagePath!));
      }
    }
    final url = (_selectedAvatarUrl?.isNotEmpty ?? false) ? _selectedAvatarUrl! : defaultUrl;
    return CachedNetworkImageProvider(url);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).value;
    _populateUserData(user);

    final defaultAvatar = (user?.avatarUrl.isNotEmpty ?? false)
        ? user!.avatarUrl
        : 'https://api.dicebear.com/7.x/bottts/png?seed=${user?.id ?? "user"}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          if (_isSaving)
            const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())
          else
            TextButton(
              onPressed: _save,
              child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 54,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: _getAvatarImage(defaultAvatar),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        onPressed: _showAvatarOptions,
                        tooltip: 'Change Photo',
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Full Name is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _usernameCtrl,
              decoration: const InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.alternate_email),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Username is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone_outlined),
                hintText: '+1 234 567 8900',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cityCtrl,
              decoration: const InputDecoration(
                labelText: 'City / Location',
                prefixIcon: Icon(Icons.location_on_outlined),
                hintText: 'e.g. San Francisco, CA',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bioCtrl,
              decoration: const InputDecoration(
                labelText: 'Bio',
                prefixIcon: Icon(Icons.description_outlined),
                hintText: 'Tell others about yourself...',
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }
}
