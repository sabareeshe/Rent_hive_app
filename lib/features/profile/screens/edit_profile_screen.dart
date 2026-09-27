import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _bioCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _phoneCtrl;
  
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _bioCtrl = TextEditingController();
    _cityCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    
    // Defer reading state until build to setup initial values
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userState = ref.read(currentUserProvider);
      if (userState.value != null) {
        _nameCtrl.text = userState.value!.fullName;
        _bioCtrl.text = userState.value!.bio;
        _cityCtrl.text = userState.value!.city;
        _phoneCtrl.text = userState.value!.phoneNumber;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser != null) {
      final updatedUser = currentUser.copyWith(
        fullName: _nameCtrl.text,
        bio: _bioCtrl.text,
        city: _cityCtrl.text,
        phoneNumber: _phoneCtrl.text,
      );
      
      await ref.read(currentUserProvider.notifier).updateProfile(updatedUser);
    }
    
    setState(() => _isSaving = false);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          if (_isSaving)
            const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())
          else
            TextButton(
              onPressed: _save,
              child: const Text('Save'),
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
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=mohan'),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        onPressed: () {},
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Full Name'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(labelText: 'Phone Number'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cityCtrl,
              decoration: const InputDecoration(labelText: 'City'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bioCtrl,
              decoration: const InputDecoration(labelText: 'Bio'),
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }
}
