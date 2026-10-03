import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../src/colors.dart';
import '../../../src/dialogs.dart';
import '../../../src/widgets.dart';
import '../controllers/attendance_list_controller.dart';

class AttendanceListView extends GetView<AttendanceListController> {
  const AttendanceListView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    if (!c.ready) return const Scaffold(body: LoadingView());
    return Obx(() => PageScaffold(
          showBack: true,
          title: c.lectureName,
          subtitle: '${'Attendance list'.tr} · ${c.courseName}',
          headerBottom: Column(
            children: [
              Row(children: [
                StatTile(
                    value: '${c.attendance.length}',
                    label: 'Present'.tr,
                    icon: Icons.how_to_reg_outlined),
                const SizedBox(width: 10),
                StatTile(
                    value: '${c.absentRows.length}',
                    label: 'Absent'.tr,
                    icon: Icons.person_off_outlined),
                const SizedBox(width: 10),
                StatTile(
                    value: '${c.percent}%',
                    label: 'Rate'.tr,
                    icon: Icons.pie_chart_outline),
              ]),
              const SizedBox(height: 14),
              _tabs(),
            ],
          ),
          body: c.loading.value ? const LoadingView() : _list(),
        ));
  }

  Widget _tabs() {
    final c = controller;
    Widget tab(int i, String text) => Expanded(
          child: GestureDetector(
            onTap: () => c.tab.value = i,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: c.tab.value == i ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Text(text,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: c.tab.value == i
                          ? AppColors.primaryColor
                          : Colors.white)),
            ),
          ),
        );
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(children: [
        tab(0, '${'Present'.tr} (${c.attendance.length})'),
        tab(1, '${'Absent'.tr} (${c.absentRows.length})'),
      ]),
    );
  }

  Widget _list() {
    final c = controller;
    final present = c.tab.value == 0;
    final rows = present ? c.presentRows : c.absentRows;
    if (rows.isEmpty) {
      return EmptyState(
        icon: present ? Icons.hourglass_empty : Icons.celebration_outlined,
        title: present ? 'No one has attended yet'.tr : 'Everyone is present!'.tr,
        subtitle: present
            ? 'Open the QR code and ask students to scan it.'.tr
            : null,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 12, bottom: 60),
      itemCount: rows.length,
      itemBuilder: (_, i) {
        final s = rows[i];
        return FadeSlideIn(
          index: i,
          child: AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: present
                      ? AppColors.success.withOpacity(.12)
                      : AppColors.danger.withOpacity(.1),
                  child: Text(
                    s.name.isEmpty ? '?' : s.name.characters.first.toUpperCase(),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: present ? AppColors.success : AppColors.danger),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(s.email,
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12)),
                      if (present && s.distance != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(children: [
                            Icon(Icons.location_on_outlined,
                                size: 13, color: AppColors.color2),
                            const SizedBox(width: 3),
                            Text(
                                '@d m from the classroom'
                                    .trParams({'d': '${s.distance}'}),
                                style: TextStyle(
                                    color: AppColors.color2, fontSize: 11)),
                          ]),
                        ),
                    ],
                  ),
                ),
                if (present) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(c.timeText(s.time),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.color1)),
                      ),
                      Text(
                          (s.method == 'manual'
                                  ? 'Manual'
                                  : s.method == 'code'
                                      ? 'Code'
                                      : 'QR')
                              .tr,
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 11)),
                    ],
                  ),
                  IconButton(
                    tooltip: 'Mark absent'.tr,
                    onPressed: () => AppDialogs.confirm(
                      title: 'Mark absent',
                      message: 'Remove the attendance of @name?'
                          .trParams({'name': s.name}),
                      confirmText: 'Remove',
                      onConfirm: () => c.unmark(s),
                    ),
                    icon: Icon(Icons.remove_circle_outline,
                        color: AppColors.danger),
                  ),
                ] else
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.success.withOpacity(.12),
                      foregroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    onPressed: () => c.markPresent(s),
                    icon: const Icon(Icons.check, size: 18),
                    label: Text('Mark present'.tr,
                        style: const TextStyle(fontSize: 12)),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
