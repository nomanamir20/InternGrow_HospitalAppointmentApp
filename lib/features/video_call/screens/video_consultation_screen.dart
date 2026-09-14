import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
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
  WebViewController? _webViewController;
  bool _isLoading = true;
  bool _hasError = false;
  late final Uri _meetingUri;
  bool _hasOpenedWebTab = false;

  @override
  void initState() {
    super.initState();

    final appointmentController = Get.find<AppointmentController>();
    final authController = Get.find<AuthController>();
    final appointment = appointmentController.byId(widget.appointmentId);

    final roomName = 'InternGrowHospital-${widget.appointmentId.substring(0, 8)}';
    final displayName = Uri.encodeComponent(authController.currentUser?.displayName ?? 'Patient');

    _meetingUri = Uri.parse(
      'https://meet.jit.si/$roomName#userInfo.displayName=%22$displayName%22&config.prejoinPageEnabled=false&config.disableDeepLinking=true',
    );

    if (appointment == null) {
      debugPrint('Warning: appointment ${widget.appointmentId} not found for video call context.');
    }

    // Browsers block camera/mic access inside cross-origin iframes, which
    // is exactly what an embedded WebView is on Flutter Web — so on web,
    // we open the REAL Jitsi call in its own tab instead, where camera/mic
    // permissions work normally. Android/iOS keep the true embedded
    // in-app experience via native WebView, which doesn't have this
    // restriction.
    if (!kIsWeb) {
      _initializeNativeWebView();
    } else {
      _isLoading = false;
    }
  }

  void _initializeNativeWebView() {
    final controller = WebViewController()
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
            if (mounted) {
              setState(() {
                _isLoading = false;
                _hasError = true;
              });
            }
          },
        ),
      )
      ..loadRequest(_meetingUri);

    setState(() => _webViewController = controller);
  }

  Future<void> _openInNewTab() async {
    setState(() => _hasOpenedWebTab = true);
    final launched = await launchUrl(_meetingUri, webOnlyWindowName: '_blank');
    if (!launched && mounted) {
      setState(() => _hasError = true);
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
      body: kIsWeb ? _buildWebLaunchView() : _buildNativeWebView(),
    );
  }

  Widget _buildWebLaunchView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.videocam_outlined, size: 64, color: AppColors.primary),
            const SizedBox(height: 20),
            const Text(
              'Ready to join your consultation',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Your video call will open in a new tab.\nCamera and microphone access will be requested there.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: _openInNewTab,
              icon: const Icon(Icons.open_in_new),
              label: Text(_hasOpenedWebTab ? 'Reopen Call' : 'Join Video Call'),
            ),
            if (_hasError) ...[
              const SizedBox(height: 16),
              const Text(
                'Could not open the call. Please check your browser settings.',
                style: TextStyle(color: AppColors.error, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNativeWebView() {
    return Stack(
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
                  const Text('Could not load the video call.', style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 6),
                  Text(
                    'Check your internet connection and try again.',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() => _hasError = false);
                      _initializeNativeWebView();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          )
        else if (_webViewController != null)
          WebViewWidget(controller: _webViewController!),

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
    );
  }
}