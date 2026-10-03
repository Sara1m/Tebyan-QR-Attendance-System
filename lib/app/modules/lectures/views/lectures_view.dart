import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../src/colors.dart';
import '../../../src/widgets.dart';
import '../controllers/lectures_controller.dart';

class LecturesView extends GetView<LecturesController> {
  const LecturesView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    if (!c.ready) {
      return const Scaffold(body: LoadingView());
    }
    return Obx(() => PageScaffold(
          showBack: true,
          title: c.courseName,
          subtitle: c.isStudent
              ? 'Lectures and your attendance'.tr
              : 'Lectures and attendance'.tr,
          actions: [
            if (!c.isStudent)
              HeaderButton(
                  icon: Icons.add_circle_outline,
                  tooltip: 'Add Lecture'.tr,
                  onTap: () => c.openForm(context)),
          ],
          headerBottom: Row(children: [
            StatTile(
                value: '${c.lectures.length}',
                label: 'Lectures'.tr,
                icon: Icons.co_present_outlined),
            const SizedBox(width: 10),
            if (c.isStudent)
              StatTile(
                  value: '${c.attendedCount}/${c.pastOrTodayCount}',
                  label: 'Attended'.tr,
                  icon: Icons.how_to_reg_outlined)
            else
              StatTile(
                  value: c.courseCode, label: 'Course code'.tr, icon: Icons.tag),
          ]),
          floatingActionButton: c.isStudent
              ? null
              : FloatingActionButton.extended(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  onPressed: () => c.openForm(context),
                  icon: const Icon(Icons.add),
                  label: Text('Add Lecture'.tr,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
          body: c.loading.value
              ? const LoadingView()
              : c.lectures.isEmpty
                  ? EmptyState(
                      icon: Icons.co_present_outlined,
                      title: 'No Lectures Found!'.tr,
                      subtitle: c.isStudent
                          ? 'Lectures added by your lecturer will appear here.'
                              .tr
                          : 'Add your first lecture with the + button.'.tr,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 12, bottom: 110),
                      itemCount: c.lectures.length,
                      itemBuilder: (_, i) => FadeSlideIn(
                          index: i, child: _card(context, c.lectures[i])),
                    ),
        ));
  }

  Widget _card(BuildContext context, LectureDoc l) {
    final c = controller;
    final d = l.data();
    final open = c.isOpen(l);
    final today = c.isToday(l);
    final attended = c.attended.contains(l.id);

    Widget? status;
    if (c.isStudent) {
      if (attended) {
        status = StatusChip(
            text: 'Present'.tr,
            color: AppColors.success,
            icon: Icons.check_circle);
      } else if (open) {
        status = StatusChip(
            text: 'Attendance open — scan now'.tr,
            color: AppColors.warning,
            icon: Icons.qr_code_scanner);
      } else if (c.isPast(l)) {
        status = StatusChip(
            text: 'Absent'.tr, color: AppColors.danger, icon: Icons.cancel);
      }
    } else if (open) {
      status = StatusChip(
          text: 'Attendance is open'.tr,
          color: AppColors.warning,
          icon: Icons.timer_outlined);
    }

    final menu = c.isStudent
        ? <MenuAction>[
            MenuAction(
                title: 'Scan Code',
                icon: Icons.qr_code_scanner,
                onTap: () => c.scan(l)),
            MenuAction(
                title: 'Enter code',
                icon: Icons.keyboard_alt_outlined,
                onTap: () => c.enterCode(l)),
          ]
        : <MenuAction>[
            MenuAction(
                title: 'Attendance QR code',
                icon: Icons.qr_code_2,
                onTap: () => c.openAttendanceSheet(l)),
            MenuAction(
                title: 'Attendance list',
                icon: Icons.fact_check_outlined,
                onTap: () => c.openAttendanceList(l)),
            MenuAction(
                title: 'Edit',
                icon: Icons.edit_outlined,
                onTap: () => c.openForm(context, lecture: l)),
            MenuAction(
                title: 'Delete',
                icon: Icons.delete_outline,
                destructive: true,
                onTap: () => c.confirmDelete(l)),
          ];

    return AppCard(
      onTap: () {
        if (c.isStudent) {
          if (!attended) c.scan(l);
        } else {
          c.openAttendanceList(l);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _dateBox('${d['date'] ?? ''}', today),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${d['name'] ?? ''}',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        _meta(Icons.calendar_today_outlined,
                            c.prettyDate('${d['date'] ?? ''}')),
                        _meta(Icons.access_time, '${d['time'] ?? ''}'),
                      ],
                    ),
                  ],
                ),
              ),
              appMenu(menu),
            ],
          ),
          if (status != null || (!c.isStudent && !open)) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (status != null) Flexible(child: status),
                const Spacer(),
                if (!c.isStudent)
                  _smallButton(
                    icon: Icons.qr_code_2,
                    text: open ? 'Show code'.tr : 'Take attendance'.tr,
                    onTap: () => c.openAttendanceSheet(l),
                  ),
                if (c.isStudent && open && !attended)
                  _smallButton(
                    icon: Icons.qr_code_scanner,
                    text: 'Scan'.tr,
                    onTap: () => c.scan(l),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _dateBox(String raw, bool today) {
    final d = DateTime.tryParse(raw);
    final color = today ? AppColors.accent : AppColors.color1;
    return Container(
      width: 56,
      height: 60,
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(d == null ? '--' : '${d.day}',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(
              today
                  ? 'Today'.tr
                  : (d == null ? '' : '${d.month}/${d.year % 100}'),
              style: TextStyle(fontSize: 11, color: color)),
        ],
      ),
    );
  }

  Widget _meta(IconData icon, String text) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
        ],
      );

  Widget _smallButton(
      {required IconData icon,
      required String text,
      required VoidCallback onTap}) {
    return TextButton.icon(
      style: TextButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(text, style: const TextStyle(fontSize: 13)),
    );
  }
}
