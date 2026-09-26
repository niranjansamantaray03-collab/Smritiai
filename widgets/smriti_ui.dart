
import 'package:flutter/material.dart';

import '../core/constants/accessibility.dart';

class SmritiPatientCard extends StatelessWidget {
  const SmritiPatientCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          SmritiAccessibility.patientCardRadius,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(
          SmritiAccessibility.patientCardRadius,
        ),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: (iconColor ??
                          Theme.of(context)
                              .colorScheme
                              .primary)
                      .withOpacity(.12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: iconColor ??
                      Theme.of(context)
                          .colorScheme
                          .primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize:
                            SmritiAccessibility.patientHeading,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 5),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize:
                              SmritiAccessibility.patientSmall,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SmritiPatientButton extends StatelessWidget {
  const SmritiPatientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.filled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisAlignment:
          MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 25),
          const SizedBox(width: 10),
        ],
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize:
                  SmritiAccessibility.patientButton,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );

    if (filled) {
      return SizedBox(
        height: SmritiAccessibility.minTouchTarget,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          child: child,
        ),
      );
    }

    return SizedBox(
      height: SmritiAccessibility.minTouchTarget,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}

class SmritiSectionTitle extends StatelessWidget {
  const SmritiSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
        top: 8,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize:
                  SmritiAccessibility.patientHeading,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize:
                    SmritiAccessibility.patientSmall,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
