// lib/features/voice_system/ui/voice_control_buttons.dart
import 'package:flutter/material.dart';
import '../core/voice_controller.dart';

class VoiceControlButtons extends StatelessWidget {
  final VoiceController voiceController;

  const VoiceControlButtons({
    Key? key,
    required this.voiceController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: voiceController,
      builder: (context, _) {
        final isListening = voiceController.isActive;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isListening)
              ElevatedButton.icon(
                onPressed: () async {
                  await voiceController.startListening();
                },
                icon: const Icon(Icons.mic),
                label: const Text('Start Listening'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            if (isListening)
              ElevatedButton.icon(
                onPressed: () async {
                  await voiceController.stopListening();
                },
                icon: const Icon(Icons.mic_off),
                label: const Text('Stop Listening'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        );
      },
    );
  }
}
