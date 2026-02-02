import 'package:flutter/material.dart';
import 'package:stray_resuce_bih/core/storage/local_prefs.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _name;
  String? _phone;
  String? _city;
  String? _ward;
  String? _lang;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final name = await LocalPrefs.getString(LocalPrefs.keyName);
    final phone = await LocalPrefs.getString(LocalPrefs.keyPhone);
    final city = await LocalPrefs.getString(LocalPrefs.keyCity);
    final ward = await LocalPrefs.getString(LocalPrefs.keyWard);
    final lang = await LocalPrefs.getString(LocalPrefs.keyLanguage);
    setState(() {
      _name = name;
      _phone = phone;
      _city = city;
      _ward = ward;
      _lang = lang;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Name: ${_name ?? ''}')
              ,
          const SizedBox(height: 8),
          Text('Phone: ${_phone ?? ''}')
              ,
          const SizedBox(height: 8),
          Text('City: ${_city ?? ''}')
              ,
          const SizedBox(height: 8),
          Text('Ward: ${_ward ?? ''}')
              ,
          const SizedBox(height: 8),
          Text('Language: ${_lang ?? ''}')
              ,
        ],
      ),
    );
  }
}
