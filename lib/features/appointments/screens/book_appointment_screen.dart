import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../shared/widgets/scaffold_with_nav_bar.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/appointment_model.dart';
import '../../../data/models/doctor_model.dart';
import '../controllers/appointment_controller.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  late final Doctor doctor;
  late final AppointmentController _controller;

  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeSlot;
  ConsultationType _consultationType = ConsultationType.inPerson;
  final _notesController = TextEditingController();
  bool _isBooking = false;

  static const _timeSlots = [
    '09:00 AM', '10:00 AM', '11:00 AM',
    '01:00 PM', '02:00 PM', '03:00 PM', '04:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    doctor = Get.arguments as Doctor;
    _controller = Get.find<AppointmentController>();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  List<DateTime> get _nextSevenDays {
    return List.generate(7, (i) => DateTime.now().add(Duration(days: i)));
  }

  bool _isDayAvailable(DateTime date) {
    final dayAbbrev = DateFormat('EEE').format(date);
    return doctor.availableDays.contains(dayAbbrev);
  }

  void _handleBooking() {
    if (_selectedTimeSlot == null) {
      Get.snackbar('Select a Time', 'Please choose an available time slot.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    setState(() => _isBooking = true);

    final appointment = _controller.createAppointment(
      doctorId: doctor.id,
      doctorName: doctor.fullName,
      doctorPhotoUrl: doctor.photoUrl,
      specialization: doctor.specialization,
      date: _selectedDate,
      timeSlot: _selectedTimeSlot!,
      consultationType: _consultationType,
      consultationFee: doctor.consultationFee,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    // Signal which appointment to highlight, since Appointment History
    // isn't a standalone route — it's a tab inside the shared bottom-nav
    // shell, so we switch tabs directly rather than trying to navigate to
    // a route that doesn't independently exist.
    _controller.justBookedAppointmentId.value = appointment.id;

    setState(() => _isBooking = false);

    // We're currently on the /book-appointment route (pushed on top of the
    // shell), so offAllNamed to /home correctly clears back to the shell —
    // this only fails as a no-op when called FROM WITHIN the shell itself.
    Get.offAllNamed(AppRoutes.home);
    Get.find<NavShellController>().changeTab(1); // switch to the History tab

    Get.snackbar(
      'Appointment Booked',
      'Your appointment with ${doctor.fullName} is confirmed.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final bookedSlots = _controller.bookedSlotsFor(doctor.id, _selectedDate);

    return Scaffold(
      appBar: AppBar(title: const Text('Book Appointment')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Doctor summary card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: doctor.photoUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(width: 56, height: 56, color: borderColor, child: const Icon(Icons.person)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doctor.fullName, style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text(doctor.specialization, style: const TextStyle(color: AppColors.primary, fontSize: 13)),
                    ],
                  ),
                ),
                Text('\$${doctor.consultationFee.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text('Consultation Type', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ConsultationTypeCard(
                  icon: Icons.local_hospital_outlined,
                  label: 'In-Person',
                  isSelected: _consultationType == ConsultationType.inPerson,
                  onTap: () => setState(() => _consultationType = ConsultationType.inPerson),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ConsultationTypeCard(
                  icon: Icons.videocam_outlined,
                  label: 'Video Call',
                  isSelected: _consultationType == ConsultationType.video,
                  onTap: () => setState(() => _consultationType = ConsultationType.video),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text('Select Date', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          SizedBox(
            height: 76,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _nextSevenDays.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final date = _nextSevenDays[index];
                final isAvailable = _isDayAvailable(date);
                final isSelected = _selectedDate.year == date.year &&
                    _selectedDate.month == date.month &&
                    _selectedDate.day == date.day;

                return GestureDetector(
                  onTap: isAvailable
                      ? () => setState(() {
                            _selectedDate = date;
                            _selectedTimeSlot = null;
                          })
                      : null,
                  child: Container(
                    width: 56,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? AppColors.primary : borderColor),
                    ),
                    child: Opacity(
                      opacity: isAvailable ? 1.0 : 0.35,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(DateFormat('EEE').format(date), style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : subTextColor)),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('d').format(date),
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : null),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          Text('Select Time', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final slot in _timeSlots)
                _TimeSlotChip(
                  label: slot,
                  isBooked: bookedSlots.contains(slot),
                  isSelected: _selectedTimeSlot == slot,
                  onTap: bookedSlots.contains(slot) ? null : () => setState(() => _selectedTimeSlot = slot),
                ),
            ],
          ),
          const SizedBox(height: 24),

          Text('Notes (optional)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Describe your symptoms or reason for visit...'),
          ),
          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isBooking ? null : _handleBooking,
              child: _isBooking
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Confirm Booking'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsultationTypeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ConsultationTypeCard({required this.icon, required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primary : borderColor),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : null),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(color: isSelected ? AppColors.primary : null, fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _TimeSlotChip extends StatelessWidget {
  final String label;
  final bool isBooked;
  final bool isSelected;
  final VoidCallback? onTap;

  const _TimeSlotChip({required this.label, required this.isBooked, required this.isSelected, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? AppColors.primary : borderColor),
        ),
        child: Text(
          isBooked ? '$label (Booked)' : label,
          style: TextStyle(
            color: isBooked ? subTextColor : (isSelected ? Colors.white : null),
            fontWeight: FontWeight.w600,
            fontSize: 13,
            decoration: isBooked ? TextDecoration.lineThrough : null,
          ),
        ),
      ),
    );
  }
}