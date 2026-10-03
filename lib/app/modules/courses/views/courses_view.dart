import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';

import '../../../src/colors.dart';
import '../../../src/session.dart';
import '../../../src/widgets.dart';
import '../controllers/courses_controller.dart';

class CoursesView extends StatelessWidget {
  const CoursesView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.isRegistered<CoursesController>()
        ? Get.find<CoursesController>()
        : Get.put(CoursesController());
    return PageScaffold(
      title: 'Courses'.tr,
      subtitle: 'Admin panel'.tr,
      actions: [
        HeaderButton(
            icon: Icons.add_circle_outline,
            tooltip: 'Add Course'.tr,
            onTap: () => c.openForm()),
        HeaderButton(
            icon: Icons.logout, tooltip: 'Sign Out'.tr, onTap: Session.logout),
      ],
      headerBottom: Column(
        children: [
          Obx(() => Row(children: [
                StatTile(
                    value: '${c.courses.length}',
                    label: 'Courses'.tr,
                    icon: LineIcons.book),
                const SizedBox(width: 10),
                StatTile(
                    value: '${c.totalHours}',
                    label: 'Credit hours'.tr,
                    icon: Icons.schedule),
              ])),
          const SizedBox(height: 14),
          TextField(
            onChanged: (v) => c.search.value = v,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search by name or code'.tr,
              hintStyle: TextStyle(color: Colors.white.withOpacity(.6)),
              prefixIcon:
                  Icon(Icons.search, color: Colors.white.withOpacity(.8)),
              fillColor: Colors.white.withOpacity(.12),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (c.loading.value) return const LoadingView();
        final list = c.filtered;
        if (list.isEmpty) {
          return EmptyState(
            icon: LineIcons.book,
            title: 'No Courses Found!'.tr,
            subtitle: 'Tap + at the top to add the first one.'.tr,
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(top: 12, bottom: 100),
          itemCount: list.length,
          itemBuilder: (_, i) {
            final course = list[i];
            final d = course.data();
            return FadeSlideIn(
              index: i,
              child: AppCard(
                onTap: () => c.openForm(course: course),
                child: Row(
                  children: [
                    CourseBadge(code: '${d['code'] ?? ''}'),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${d['name'] ?? ''}',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          StatusChip(
                            text: '@hours hours'
                                .trParams({'hours': '${d['hours'] ?? '-'}'}),
                            color: AppColors.color1,
                            icon: Icons.schedule,
                          ),
                        ],
                      ),
                    ),
                    appMenu([
                      MenuAction(
                          title: 'Edit',
                          icon: Icons.edit_outlined,
                          onTap: () => c.openForm(course: course)),
                      MenuAction(
                          title: 'Delete',
                          icon: Icons.delete_outline,
                          destructive: true,
                          onTap: () => c.confirmDelete(course)),
                    ]),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
