import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';

import 'alert.dart';
import 'bottom_sheet.dart';
import 'colors.dart';
import 'dialogs.dart';
import 'errors.dart';
import 'session.dart';
import 'widgets.dart';

typedef Doc = QueryDocumentSnapshot<Map<String, dynamic>>;

/// Shared logic for the admin's "Students" and "Lecturers" pages.
class UsersAdminController extends GetxController {
  UsersAdminController({required this.isStudent});

  final bool isStudent;

  final RxList<Doc> users = <Doc>[].obs;
  final RxList<Doc> courses = <Doc>[].obs;
  final RxList<String> selectedCourses = <String>[].obs;
  final RxString search = ''.obs;
  final RxBool loading = true.obs;
  final RxBool obscureText = true.obs;

  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  StreamSubscription? _usersSub;
  StreamSubscription? _coursesSub;

  String get label => isStudent ? 'Student' : 'Lecturer';

  List<Doc> get filtered {
    final q = search.value.trim().toLowerCase();
    if (q.isEmpty) return users;
    return users
        .where((u) =>
            '${u.data()['name']}'.toLowerCase().contains(q) ||
            '${u.data()['email']}'.toLowerCase().contains(q))
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    final db = FirebaseFirestore.instance;
    final Query<Map<String, dynamic>> q = isStudent
        ? db.collection('Users').where('type', isEqualTo: Session.studentType)
        : db
            .collection('Users')
            .where('type', whereIn: ['Lecturere', 'Lecturer']);
    _usersSub = q.snapshots().listen((qs) {
      final list = qs.docs.toList()
        ..sort((a, b) => '${a.data()['name']}'
            .toLowerCase()
            .compareTo('${b.data()['name']}'.toLowerCase()));
      users.value = list;
      loading.value = false;
    }, onError: (e) {
      loading.value = false;
      AppErrors.show(e);
    });
    _coursesSub = db.collection('Courses').snapshots().listen((qs) {
      final list = qs.docs.toList()
        ..sort((a, b) =>
            '${a.data()['code']}'.compareTo('${b.data()['code']}'));
      courses.value = list;
    }, onError: (e) => AppErrors.show(e));
  }

  @override
  void onClose() {
    _usersSub?.cancel();
    _coursesSub?.cancel();
    super.onClose();
  }

  String courseLabel(String id) {
    for (final c in courses) {
      if (c.id == id) return '${c.data()['code']}';
    }
    return '';
  }

  /// Opens the add / edit form.
  void openForm({Doc? user}) {
    final create = user == null;
    final data = user?.data() ?? <String, dynamic>{};
    name.text = '${data['name'] ?? ''}';
    email.text = '${data['email'] ?? ''}';
    password.clear();
    obscureText.value = true;
    selectedCourses.value = List<String>.from(data['courses'] ?? []);
    final userId = user?.id ?? '';
    AppBottomSheet(
      child: _form(create),
      function: () => create ? _create() : _edit(userId),
      buttonText: (create ? 'Create' : 'Save').tr,
    ).bottomSheet();
  }

  Widget _form(bool create) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        Row(
          children: [
            IconBubble(
                icon: isStudent ? Icons.school_outlined : LineIcons.userTie),
            const SizedBox(width: 12),
            Text('${create ? 'Add' : 'Edit'} $label'.tr,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        FieldLabel('Name'.tr),
        TextField(
          controller: name,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
              hintText: 'Full Name'.tr,
              prefixIcon: const Icon(Icons.person_outline)),
        ),
        FieldLabel('Email'.tr),
        TextField(
          controller: email,
          enabled: create,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
              hintText: 'name@example.com',
              prefixIcon: const Icon(Icons.alternate_email)),
        ),
        if (create) ...[
          FieldLabel('Password'.tr),
          Obx(() => TextField(
                controller: password,
                obscureText: obscureText.value,
                decoration: InputDecoration(
                  hintText: 'At least 6 characters'.tr,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: () => obscureText.value = !obscureText.value,
                    icon: Icon(obscureText.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                  ),
                ),
              )),
        ],
        FieldLabel('Courses'.tr),
        Obx(() {
          if (courses.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(.1),
                  borderRadius: BorderRadius.circular(16)),
              child: Text('No courses yet. Add courses first from the Courses tab.'.tr,
                  style: TextStyle(color: AppColors.primaryColor)),
            );
          }
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: courses.map((c) {
              final selected = selectedCourses.contains(c.id);
              return FilterChip(
                selected: selected,
                showCheckmark: true,
                checkmarkColor: AppColors.primaryColor,
                label: Text('${c.data()['code']} · ${c.data()['name']}'),
                onSelected: (v) =>
                    v ? selectedCourses.add(c.id) : selectedCourses.remove(c.id),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  bool _validate({required bool create}) {
    if (name.text.trim().isEmpty) {
      Ui.info('Please enter the name');
      return false;
    }
    if (create) {
      if (!GetUtils.isEmail(email.text.trim())) {
        Ui.info('Email address is invalid');
        return false;
      }
      if (password.text.length < 6) {
        Ui.info('Password must be at least 6 characters long');
        return false;
      }
    }
    if (selectedCourses.isEmpty) {
      Ui.info('Please choose courses');
      return false;
    }
    return true;
  }

  /// A second Firebase connection so creating an account does not sign the
  /// admin out.
  Future<FirebaseAuth> _secondaryAuth() async {
    FirebaseApp app;
    try {
      app = Firebase.app('secondary');
    } catch (_) {
      app = await Firebase.initializeApp(
          name: 'secondary', options: Firebase.app().options);
    }
    return FirebaseAuth.instanceFor(app: app);
  }

  Future<void> _create() async {
    if (!_validate(create: true)) return;
    UserCredential? cred;
    FirebaseAuth? auth;
    try {
      auth = await _secondaryAuth();
      cred = await auth.createUserWithEmailAndPassword(
          email: email.text.trim(), password: password.text);
      final uid = cred.user!.uid;
      await FirebaseFirestore.instance.collection('Users').doc(uid).set({
        'id': uid,
        'name': name.text.trim(),
        'email': email.text.trim(),
        'courses': selectedCourses.toList(),
        'type': isStudent ? Session.studentType : Session.lecturerType,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await auth.signOut();
      Get.back();
      Ui.success('Account created successfully');
    } catch (e) {
      // If the profile could not be saved, remove the half-created account.
      if (cred?.user != null) {
        try {
          await cred!.user!.delete();
        } catch (_) {}
      }
      AppErrors.show(e);
    }
  }

  Future<void> _edit(String id) async {
    if (!_validate(create: false)) return;
    try {
      await FirebaseFirestore.instance.collection('Users').doc(id).update({
        'name': name.text.trim(),
        'courses': selectedCourses.toList(),
      });
      Get.back();
      Ui.success('Changes saved');
    } catch (e) {
      AppErrors.show(e);
    }
  }

  void confirmDelete(Doc user) {
    AppDialogs.confirm(
      title: 'Delete $label',
      message: 'Are you sure you want to delete @name? They will not be able to sign in any more.'
          .trParams({'name': '${user.data()['name']}'}),
      onConfirm: () async {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.id)
            .delete();
        Ui.success('Account deleted');
      },
    );
  }

  Future<void> sendReset(Doc user) async {
    final mail = '${user.data()['email']}';
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: mail);
      Ui.success('A password reset link was sent to @email'
          .trParams({'email': mail}));
    } catch (e) {
      AppErrors.show(e);
    }
  }
}

/// Shared page for the admin's "Students" and "Lecturers" tabs.
class UsersAdminPage extends StatelessWidget {
  const UsersAdminPage({super.key, required this.c});
  final UsersAdminController c;

  @override
  Widget build(BuildContext context) {
    final icon = c.isStudent ? Icons.school_outlined : LineIcons.userTie;
    return PageScaffold(
      title: (c.isStudent ? 'Students' : 'Lecturers').tr,
      subtitle: 'Admin panel'.tr,
      actions: [
        HeaderButton(
            icon: Icons.person_add_alt_1_outlined,
            tooltip: 'Add ${c.label}'.tr,
            onTap: () => c.openForm()),
        HeaderButton(
            icon: Icons.logout, tooltip: 'Sign Out'.tr, onTap: Session.logout),
      ],
      headerBottom: Column(
        children: [
          Obx(() => Row(children: [
                StatTile(
                    value: '${c.users.length}',
                    label: (c.isStudent ? 'Students' : 'Lecturers').tr,
                    icon: icon),
                const SizedBox(width: 10),
                StatTile(
                    value: '${c.courses.length}',
                    label: 'Courses'.tr,
                    icon: LineIcons.book),
              ])),
          const SizedBox(height: 14),
          TextField(
            onChanged: (v) => c.search.value = v,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search by name or email'.tr,
              hintStyle: TextStyle(color: Colors.white.withOpacity(.6)),
              prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(.8)),
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
            icon: icon,
            title: (c.isStudent ? 'No Students Found!' : 'No Lecturers Found!')
                .tr,
            subtitle: 'Tap + at the top to add the first one.'.tr,
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(top: 12, bottom: 100),
          itemCount: list.length,
          itemBuilder: (_, i) {
            final u = list[i];
            final data = u.data();
            final ids = List<String>.from(data['courses'] ?? []);
            final userName = '${data['name'] ?? ''}';
            return FadeSlideIn(
              index: i,
              child: AppCard(
                onTap: () => c.openForm(user: u),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.courseColor(userName),
                      child: Text(
                          userName.isEmpty ? '?' : userName.characters.first.toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 2),
                          Text('${data['email'] ?? ''}',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 13)),
                          if (ids.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: ids
                                  .map((id) => c.courseLabel(id))
                                  .where((t) => t.isNotEmpty)
                                  .map((t) => StatusChip(
                                      text: t,
                                      color: AppColors.courseColor(t)))
                                  .toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                    appMenu([
                      MenuAction(
                          title: 'Edit',
                          icon: Icons.edit_outlined,
                          onTap: () => c.openForm(user: u)),
                      MenuAction(
                          title: 'Send password reset link',
                          icon: Icons.lock_reset,
                          onTap: () => c.sendReset(u)),
                      MenuAction(
                          title: 'Delete',
                          icon: Icons.delete_outline,
                          destructive: true,
                          onTap: () => c.confirmDelete(u)),
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
