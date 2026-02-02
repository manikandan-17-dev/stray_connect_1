import 'package:flutter/material.dart';
import 'package:stray_resuce_bih/core/storage/local_prefs.dart';
import 'package:stray_resuce_bih/features/home/home_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cityCtrl = TextEditingController(text: 'Erode');
  final _wardCtrl = TextEditingController();
  String _language = 'en';

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    final name = await LocalPrefs.getString(LocalPrefs.keyName);
    final phone = await LocalPrefs.getString(LocalPrefs.keyPhone);
    final city = await LocalPrefs.getString(LocalPrefs.keyCity);
    final ward = await LocalPrefs.getString(LocalPrefs.keyWard);
    final lang = await LocalPrefs.getString(LocalPrefs.keyLanguage);
    setState(() {
      if (name != null) _nameCtrl.text = name;
      if (phone != null) _phoneCtrl.text = phone;
      if (city != null) _cityCtrl.text = city;
      if (ward != null) _wardCtrl.text = ward;
      if (lang != null) _language = lang;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _wardCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await LocalPrefs.setString(LocalPrefs.keyName, _nameCtrl.text.trim());
    await LocalPrefs.setString(LocalPrefs.keyPhone, _phoneCtrl.text.trim());
    await LocalPrefs.setString(LocalPrefs.keyCity, _cityCtrl.text.trim());
    await LocalPrefs.setString(LocalPrefs.keyWard, _wardCtrl.text.trim());
    await LocalPrefs.setString(LocalPrefs.keyLanguage, _language);
    await LocalPrefs.setBool(LocalPrefs.keyProfileCompleted, true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Setup')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cityCtrl,
                decoration: const InputDecoration(labelText: 'City'),
              ),
              const SizedBox(height: 12), 
              TextFormField(
                controller: _wardCtrl,
                decoration: const InputDecoration(labelText: 'Ward'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _language,
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'ta', child: Text('Tamil')),
                ],
                onChanged: (v) => setState(() => _language = v ?? 'en'),
                decoration: const InputDecoration(labelText: 'Language'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Save & Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
