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

  bool _isCapturingFullCommand = false;
  Timer? _debounceTimer;
  Timer? _commandCaptureTimer;
  final commandCaptureDelay = const Duration(milliseconds: 1500);
  StreamSubscription<bool>? _listeningSubscription; // Add subscription variable
  StreamSubscription<String>? _textSubscription; // Add for text stream

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Get listening state updates from the controller
    _listeningSubscription =
        widget.voiceController.listeningStateStream.listen((isListening) {
      if (mounted) {
        // Check if widget is still mounted
        setState(() {
          _isListening = isListening;
        });

        if (isListening) {
          _animationController.repeat(reverse: true);
        } else if (!_isProcessing) {
          _animationController.stop();
        }
      }
    });

    // Get recognized text updates from the controller with debounce
    _textSubscription = widget.voiceController.textStream.listen((text) {
      _debounceTimer?.cancel();

      if (mounted) {
        // Check if widget is still mounted
        setState(() {
          _recognizedText = text;

          // Check if we're still collecting a command
          if (text.startsWith('Heard:')) {
            _isCapturingFullCommand = true;
            _commandCaptureTimer?.cancel();
            _commandCaptureTimer = Timer(commandCaptureDelay, () {
              if (mounted && _isCapturingFullCommand) {
                setState(() {
                  _recognizedText += " (still listening...)";
                });
              }
            });
          } else if (text.contains("Processing:")) {
            _isCapturingFullCommand = false;
            _commandCaptureTimer?.cancel();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _listeningSubscription?.cancel(); // Cancel the stream subscription
    _textSubscription?.cancel(); // Cancel the text stream subscription
    _debounceTimer?.cancel();
    _commandCaptureTimer?.cancel();
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
                VoiceControlButtons(voiceController: widget.voiceController),
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
