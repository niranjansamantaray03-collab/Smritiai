
import 'package:flutter/material.dart';

class SmritiErrorScreen
    extends StatelessWidget {
  const SmritiErrorScreen({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmritiAI'),
      ),
      body: Center(
        child: Padding(
          padding:
              const EdgeInsets.all(24),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              const Icon(
                Icons.info_outline,
                size: 60,
              ),
              const SizedBox(height: 18),
              Text(
                message,
                textAlign:
                    TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context)
                        .pop();
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                  ),
                  label: const Text(
                    'Go Back',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
