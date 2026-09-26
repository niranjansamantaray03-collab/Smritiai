import 'package:flutter/material.dart';

import '../core/native/smriti_native_services.dart';

class VoiceHelpButton extends StatefulWidget {
  final String text;
  final String locale;

  const VoiceHelpButton({
    super.key,
    required this.text,
    this.locale = 'en-IN',
  });

  @override
  State<VoiceHelpButton> createState() => _VoiceHelpButtonState();
}

class _VoiceHelpButtonState extends State<VoiceHelpButton> {
  bool speaking = false;

  Future<void> toggle() async {
    if (speaking) {
      await SmritiNativeServices.voice.stop();
      if (mounted) setState(() => speaking = false);
      return;
    }

    setState(() => speaking = true);

    try {
      await SmritiNativeServices.voice.speak(
        widget.text,
        locale: widget.locale,
      );
    } finally {
      if (mounted) setState(() => speaking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      tooltip: speaking ? 'Stop voice' : 'Listen',
      onPressed: toggle,
      icon: Icon(
        speaking ? Icons.stop_rounded : Icons.volume_up_rounded,
      ),
    );
  }
}
