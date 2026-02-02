import 'package:flutter/material.dart';
import 'package:stray_resuce_bih/core/theme/app_theme.dart';
import 'package:stray_resuce_bih/core/models/enums.dart';
import 'package:stray_resuce_bih/features/auth/screens/signup_screen.dart';

/// Role Selection Screen - User chooses their role
class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  UserRole? _selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Role'),
        backgroundColor: AppTheme.primaryOrange,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryOrange.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 16),
                
                // Title
                const Text(
                  'How do you want to use\nStrayCare Connect?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                const Text(
                  'Choose one role to get started',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                // Role Cards
                Expanded(
                  child: ListView(
                    children: [
                      _buildRoleCard(UserRole.citizen),
                      const SizedBox(height: 16),
                      _buildRoleCard(UserRole.volunteer),
                      const SizedBox(height: 16),
                      _buildRoleCard(UserRole.ngo),
                      const SizedBox(height: 16),
                      _buildRoleCard(UserRole.vet),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Continue Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _selectedRole == null
                        ? null
                        : () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => SignupScreen(role: _selectedRole!),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryOrange,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(UserRole role) {
    final isSelected = _selectedRole == role;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryOrange : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryOrange : Colors.grey.shade300,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppTheme.primaryOrange.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
          ],
        ),
        child: Row(
          children: [
            // Emoji Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Colors.white.withOpacity(0.2) 
                    : AppTheme.primaryOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                role.emoji,
                style: const TextStyle(fontSize: 40),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Role Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role.displayName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppTheme.primaryDeep,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected 
                          ? Colors.white.withOpacity(0.9) 
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            
            // Selection Indicator
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 32,
              )
            else
              Icon(
                Icons.circle_outlined,
                color: Colors.grey.shade400,
                size: 32,
              ),
          ],
        ),
      ),
    );
  }
}
