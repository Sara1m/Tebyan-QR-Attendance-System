import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';

import '../routes/app_pages.dart';
import 'colors.dart';
import 'errors.dart';
import 'session.dart';
import 'widgets.dart';

typedef MyCourseDoc = DocumentSnapshot<Map<String, dynamic>>;

/// Loads the courses of the signed-in student or lecturer.
class MyCoursesController extends GetxController {
  final RxList<MyCourseDoc> courses = <MyCourseDoc>[].obs;
  final RxMap<String, dynamic> me = <String, dynamic>{}.obs;
  final RxBool loading = true.obs;

  int get totalHours => courses.fold<int>(
      0, (s, c) => s + (int.tryParse('${c.data()?['hours']}') ?? 0));

  String get firstName {
    final n = '${me['name'] ?? ''}'.trim();
    return n.isEmpty ? '' : n.split(' ').first;
  }

  String get greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    final uid = Session.userId;
    if (uid == null) return;
    try {
      final db = FirebaseFirestore.instance;
      final ds = await db.collection('Users').doc(uid).get();
      me.value = ds.data() ?? <String, dynamic>{};
      final ids = List<String>.from(me['courses'] ?? []);
      final list = <MyCourseDoc>[];
      // Firestore allows up to 30 ids per "whereIn" query.
      for (var i = 0; i < ids.length; i += 30) {
        final chunk = ids.sublist(i, i + 30 > ids.length ? ids.length : i + 30);
        final qs = await db
            .collection('Courses')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        list.addAll(qs.docs);
      }
      list.sort((a, b) =>
          '${a.data()?['code']}'.compareTo('${b.data()?['code']}'));
      courses.value = list;
    } catch (e) {
      AppErrors.show(e);
    } finally {
      loading.value = false;
    }
  }

  void openCourse(MyCourseDoc course) =>
      Get.toNamed(Routes.LECTURES, arguments: {'course': course});
}

/// Home page listing the user's courses (used by students and lecturers).
class MyCoursesPage extends StatelessWidget {
  const MyCoursesPage({super.key, required this.c, required this.isStudent});
  final MyCoursesController c;
  final bool isStudent;

  @override
  Widget build(BuildContext context) {
    return Obx(() => PageScaffold(
          title: c.firstName.isEmpty
              ? c.greeting.tr
              : '${c.greeting.tr}${Get.locale?.languageCode == 'ar' ? '،' : ','} ${c.firstName}',
          subtitle: (isStudent
                  ? 'Your courses and attendance in one place'
                  : 'Manage your lectures and take attendance in seconds')
              .tr,
          actions: [
            if (isStudent)
              HeaderButton(
                  icon: Icons.qr_code_scanner,
                  tooltip: 'Scan attendance'.tr,
                  onTap: () => Get.toNamed(Routes.SCAN)),
            HeaderButton(
                icon: Icons.refresh, tooltip: 'Refresh'.tr, onTap: c.load),
          ],
          headerBottom: Row(children: [
            StatTile(
                value: '${c.courses.length}',
                label: 'Courses'.tr,
                icon: LineIcons.book),
            const SizedBox(width: 10),
            StatTile(
                value: '${c.totalHours}',
                label: 'Credit hours'.tr,
                icon: Icons.schedule),
          ]),
          floatingActionButton: isStudent
              ? FloatingActionButton.extended(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  onPressed: () => Get.toNamed(Routes.SCAN),
                  icon: const Icon(Icons.qr_code_scanner),
                  label: Text('Scan attendance'.tr,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                )
              : null,
          body: c.loading.value
              ? const LoadingView()
              : RefreshIndicator(
                  color: AppColors.color1,
                  onRefresh: c.load,
                  child: c.courses.isEmpty
                      ? ListView(children: [
                          const SizedBox(height: 40),
                          EmptyState(
                            icon: LineIcons.book,
                            title: 'No Courses Found!'.tr,
                            subtitle:
                                'The administrator has not registered any courses for you yet.'
                                    .tr,
                          ),
                        ])
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 12, bottom: 110),
                          itemCount: c.courses.length,
                          itemBuilder: (_, i) =>
                              FadeSlideIn(index: i, child: _card(c.courses[i])),
                        ),
                ),
        ));
  }

  Widget _card(MyCourseDoc course) {
    final d = course.data() ?? <String, dynamic>{};
    final code = '${d['code'] ?? ''}';
    final color = AppColors.courseColor(code);
    return AppCard(
      onTap: () => c.openCourse(course),
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 6, color: color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CourseBadge(code: code),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${d['name'] ?? ''}',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Row(children: [
                              Icon(Icons.schedule,
                                  size: 15, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                  '@hours hours'
                                      .trParams({'hours': '${d['hours'] ?? '-'}'}),
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 13)),
                            ]),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: color.withOpacity(.1),
                            shape: BoxShape.circle),
                        child: Icon(Icons.arrow_forward, color: color, size: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
