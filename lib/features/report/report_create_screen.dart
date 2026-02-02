import 'package:flutter/material.dart';

class ReportCreateScreen extends StatefulWidget {
  const ReportCreateScreen({super.key});

  @override
  State<ReportCreateScreen> createState() => _ReportCreateScreenState();
}

class _ReportCreateScreenState extends State<ReportCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  String _animalType = 'dog';
  String _condition = 'injured';
  String _emergency = 'medium';
  final _descriptionCtrl = TextEditingController();

  @override
  void dispose() {
    _descriptionCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report submitted (local stub).')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: _animalType,
              items: const [
                DropdownMenuItem(value: 'dog', child: Text('Dog')),
                DropdownMenuItem(value: 'cat', child: Text('Cat')),
                DropdownMenuItem(value: 'cow', child: Text('Cow')),
                DropdownMenuItem(value: 'other', child: Text('Other')),
              ],
              onChanged: (v) => setState(() => _animalType = v ?? 'dog'),
              decoration: const InputDecoration(labelText: 'Animal Type'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _condition,
              items: const [
                DropdownMenuItem(value: 'injured', child: Text('Injured')),
                DropdownMenuItem(value: 'sick', child: Text('Sick')),
                DropdownMenuItem(value: 'accident', child: Text('Accident')),
                DropdownMenuItem(value: 'aggressive', child: Text('Aggressive')),
                DropdownMenuItem(value: 'pregnant', child: Text('Pregnant')),
              ],
              onChanged: (v) => setState(() => _condition = v ?? 'injured'),
              decoration: const InputDecoration(labelText: 'Condition'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _emergency,
              items: const [
                DropdownMenuItem(value: 'critical', child: Text('Critical')),
                DropdownMenuItem(value: 'medium', child: Text('Medium')),
                DropdownMenuItem(value: 'low', child: Text('Low')),
              ],
              onChanged: (v) => setState(() => _emergency = v ?? 'medium'),
              decoration: const InputDecoration(labelText: 'Emergency Level'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description (optional)'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Submit Report'),
            ),
          ],
        ),
      ),
    );
  }
}
