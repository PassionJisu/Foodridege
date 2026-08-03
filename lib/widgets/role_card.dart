import 'package:flutter/material.dart';

import '../../models/user_role.dart';

class RoleCard extends StatelessWidget {
  const RoleCard({
    super.key,
    required this.role,
    required this.icon,
    required this.description,
    required this.onTap,
  });

  final UserRole role;
  final IconData icon;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: role.isProvider
                    ? const Color(0xFF1565C0).withValues(alpha: 0.1)
                    : Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  icon,
                  color: role.isProvider
                      ? const Color(0xFF1565C0)
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role.label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
