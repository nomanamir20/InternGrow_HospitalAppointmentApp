import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/doctor_model.dart';

class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onTap;

  const DoctorCard({super.key, required this.doctor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: doctor.photoUrl,
                width: 96,
                height: 110,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 96,
                  height: 110,
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
                errorWidget: (context, url, error) => Container(
                  width: 96,
                  height: 110,
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  child: const Icon(Icons.person),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      doctor.specialization,
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor.hospital,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: subTextColor, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: AppColors.ratingStar, size: 14),
                        const SizedBox(width: 3),
                        Text(doctor.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                        const SizedBox(width: 10),
                        Icon(Icons.work_outline, size: 13, color: subTextColor),
                        const SizedBox(width: 3),
                        Text('${doctor.yearsExperience} yrs', style: TextStyle(color: subTextColor, fontSize: 12)),
                        const Spacer(),
                        Text(
                          '\$${doctor.consultationFee.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}