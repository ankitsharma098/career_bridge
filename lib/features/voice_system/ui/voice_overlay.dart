// lib/features/voice_system/ui/voice_overlay.dart
import 'dart:async';

import 'package:flutter/material.dart';
import '../core/voice_controller.dart';
import '../core/voice_controller_buttons.dart';

class VoiceOverlay extends StatefulWidget {
  final VoiceController voiceController;
  final Widget child;

  const VoiceOverlay({
    Key? key,
    required this.voiceController,
    required this.child,
  }) : super(key: key);

  @override
  _VoiceOverlayState createState() => _VoiceOverlayState();
}

class _VoiceOverlayState extends State<VoiceOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isListening = false;
  String _recognizedText = '';
  bool _isProcessing = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Get listening state updates from the controller
    widget.voiceController.listeningStateStream.listen((isListening) {
      setState(() {
        _isListening = isListening;
      });

      if (isListening) {
        _animationController.repeat(reverse: true);
      } else if (!_isProcessing) {
        _animationController.stop();
      }
    });

    // Listen for processing state
    //  widget.voiceController.addListener(_updateProcessingState);

    // Get recognized text updates from the controller with debounce
    widget.voiceController.textStream.listen((text) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {
            _recognizedText = text;
            if (text.contains("unavailable") || text.contains("error")) {
              // Show error UI
            }
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    //  widget.voiceController.removeListener(_updateProcessingState);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          widget.child,
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Voice control buttons
                VoiceControlButtons(voiceController: widget.voiceController),

                // Status indicator
                if (_isListening || _isProcessing)
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return Container(
                                width: 60 + 10 * _animationController.value,
                                height: 60 + 10 * _animationController.value,
                                decoration: BoxDecoration(
                                  color: _isProcessing
                                      ? Colors.orange.withOpacity(0.3)
                                      : Colors.blue.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _isProcessing ? Icons.pending : Icons.mic,
                                  color: Colors.white,
                                  size: 30 + 5 * _animationController.value,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              _recognizedText.isEmpty
                                  ? _isProcessing
                                      ? 'Processing...'
                                      : 'Listening...'
                                  : _recognizedText,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
