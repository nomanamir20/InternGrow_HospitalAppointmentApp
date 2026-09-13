import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../appointments/controllers/appointment_controller.dart';
import '../../auth/controllers/auth_controller.dart';

class VideoConsultationScreen extends StatefulWidget {
  final String appointmentId;

  const VideoConsultationScreen({super.key, required this.appointmentId});

  @override
  State<VideoConsultationScreen> createState() => _VideoConsultationScreenState();
}

class _VideoConsultationScreenState extends State<VideoConsultationScreen> {
  late final WebViewController _webViewController;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    final appointmentController = Get.find<AppointmentController>();
    final authController = Get.find<AuthController>();
    final appointment = appointmentController.byId(widget.appointmentId);

    final roomName = 'InternGrowHospital-${widget.appointmentId.substring(0, 8)}';
    final displayName = Uri.encodeComponent(authController.currentUser?.displayName ?? 'Patient');

    final meetingUrl =
        'https://meet.jit.si/$roomName#userInfo.displayName=%22$displayName%22&config.prejoinPageEnabled=false&config.disableDeepLinking=true';

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (_) {
            if (mounted) setState(() {
              _isLoading = false;
              _hasError = true;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(meetingUrl));

    if (appointment == null) {
      debugPrint('Warning: appointment ${widget.appointmentId} not found for video call context.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Video Consultation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_end, color: AppColors.error),
            tooltip: 'Leave Call',
            onPressed: () => Get.back(),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_hasError)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.videocam_off_outlined, size: 56, color: Colors.white54),
                    const SizedBox(height: 16),
                    const Text(
                      'Could not load the video call.',
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Check your internet connection and try again.',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => _hasError = false);
                        _initializeWebView();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else
            WebViewWidget(controller: _webViewController),

          if (_isLoading && !_hasError)
            Container(
              color: Colors.black,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 16),
                    Text('Connecting to your consultation...', style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}