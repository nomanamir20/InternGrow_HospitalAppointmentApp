import 'package:get/get.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/sign_up_screen.dart';
import '../../features/search/screens/search_screen.dart';
import '../../features/doctor/screens/doctor_details_screen.dart';
import '../../features/appointments/screens/book_appointment_screen.dart';
import '../../features/prescription/screens/prescription_viewer_screen.dart';
import '../../features/appointments/screens/qr_token_screen.dart';
import '../../features/video_call/screens/video_consultation_screen.dart';
import '../../shared/widgets/scaffold_with_nav_bar.dart';
import '../../shared/widgets/splash_screen.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final pages = [
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
    GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
    GetPage(name: AppRoutes.signUp, page: () => const SignUpScreen()),
    GetPage(name: AppRoutes.home, page: () => const ScaffoldWithNavBar()),
    GetPage(name: AppRoutes.search, page: () => const SearchScreen()),
    GetPage(
      name: '${AppRoutes.doctorDetails}/:id',
      page: () => DoctorDetailsScreen(doctorId: Get.parameters['id'] ?? ''),
    ),
    GetPage(name: AppRoutes.bookAppointment, page: () => const BookAppointmentScreen()),
    GetPage(
      name: '${AppRoutes.prescriptionViewer}/:appointmentId',
      page: () => PrescriptionViewerScreen(appointmentId: Get.parameters['appointmentId'] ?? ''),
    ),
        GetPage(name: AppRoutes.bookAppointment, page: () => const BookAppointmentScreen()),
    GetPage(
      name: '${AppRoutes.qrToken}/:appointmentId',
      page: () => QrTokenScreen(appointmentId: Get.parameters['appointmentId'] ?? ''),
    ),
    GetPage(
      name: '${AppRoutes.videoConsultation}/:appointmentId',
      page: () => VideoConsultationScreen(appointmentId: Get.parameters['appointmentId'] ?? ''),
    ),
  ];
}