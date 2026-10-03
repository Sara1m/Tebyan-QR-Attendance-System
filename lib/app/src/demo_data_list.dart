// Generated demo data for Tebyan (names are fictional).
// ignore_for_file: lines_longer_than_80_chars

class DemoCourse {
  const DemoCourse(this.code, this.name, this.hours, this.time, this.day);
  final String code;
  final String name;
  final int hours;
  final String time;
  final int day;
}

class DemoPerson {
  const DemoPerson(this.name, this.email, this.courses);
  final String name;
  final String email;
  final List<String> courses;
}

class DemoData {
  static const List<DemoCourse> courses = [
    DemoCourse('CS101', 'Introduction to Programming', 4, '08:00 AM', 0),
    DemoCourse('CS102', 'Object-Oriented Programming', 4, '10:00 AM', 1),
    DemoCourse('MATH151', 'Discrete Mathematics', 3, '12:30 PM', 2),
    DemoCourse('CS210', 'Data Structures', 3, '02:00 PM', 3),
    DemoCourse('CS221', 'Computer Organization', 3, '08:00 AM', 4),
    DemoCourse('CS340', 'Database Systems', 3, '10:00 AM', 0),
    DemoCourse('CS311', 'Algorithms Design & Analysis', 3, '12:30 PM', 1),
    DemoCourse('CS330', 'Operating Systems', 3, '02:00 PM', 2),
    DemoCourse('CS350', 'Computer Networks', 3, '08:00 AM', 3),
    DemoCourse('CS360', 'Software Engineering', 3, '10:00 AM', 4),
    DemoCourse('CS371', 'Web Development', 3, '12:30 PM', 0),
    DemoCourse('CS410', 'Artificial Intelligence', 3, '02:00 PM', 1),
    DemoCourse('CS420', 'Information Security', 3, '08:00 AM', 2),
    DemoCourse('CS431', 'Mobile App Development', 3, '10:00 AM', 3),
    DemoCourse('CS499', 'Graduation Project', 4, '12:30 PM', 4),
  ];

  static const List<DemoPerson> lecturers = [
    DemoPerson('Dr. Mohammed Alqahtani', 'm.alqahtani@tebyan.com', ['CS101', 'CS102']),
    DemoPerson('Dr. Hessa Alrashed', 'h.alrashed@tebyan.com', ['MATH151', 'CS311']),
    DemoPerson('Dr. Ahmed Alsubaie', 'a.alsubaie@tebyan.com', ['CS210', 'CS221', 'CS330']),
    DemoPerson('Dr. Maha Alanazi', 'm.alanazi@tebyan.com', ['CS340', 'CS360']),
    DemoPerson('Dr. Omar Alharthi', 'o.alharthi@tebyan.com', ['CS350', 'CS420']),
    DemoPerson('Dr. Asma Alshammari', 'a.alshammari@tebyan.com', ['CS371', 'CS410', 'CS431', 'CS499']),
    DemoPerson('Dr. Nouf Alhamdan', 'n.alhamdan@tebyan.com', ['CS102', 'CS431']),
    DemoPerson('Dr. Saleh Almalki', 's.almalki@tebyan.com', ['CS311', 'CS420']),
    DemoPerson('Dr. Reem Aljohani', 'r.aljohani@tebyan.com', ['MATH151', 'CS221']),
    DemoPerson('Dr. Turki Alamri', 't.alamri@tebyan.com', ['CS330', 'CS350']),
    DemoPerson('Dr. Lina Alsahli', 'l.alsahli@tebyan.com', ['CS360', 'CS499']),
    DemoPerson('Dr. Fahad Alyami', 'f.alyami@tebyan.com', ['CS101', 'CS371', 'CS410']),
  ];

  static const List<DemoPerson> students = [
    DemoPerson('Noura Alqahtani', 'noura@tebyan.com', ['CS101', 'MATH151']),
    DemoPerson('Reem Alharbi', 'reem@tebyan.com', ['CS101', 'CS102']),
    DemoPerson('Lama Alotaibi', 'lama@tebyan.com', ['CS210', 'CS340']),
    DemoPerson('Shahad Alzahrani', 'shahad@tebyan.com', ['CS102', 'CS210']),
    DemoPerson('Abdullah Alshehri', 'abdullah@tebyan.com', ['CS101', 'CS340']),
    DemoPerson('Faisal Aldosari', 'faisal@tebyan.com', ['MATH151', 'CS210']),
    DemoPerson('Raghad Almutairi', 'raghad@tebyan.com', ['CS340', 'CS360']),
    DemoPerson('Khalid Alghamdi', 'khalid@tebyan.com', ['CS360', 'CS371']),
    DemoPerson('Danah Alsahli', 'danah.sahli@tebyan.com', ['CS330', 'CS221', 'CS499', 'CS371']),
    DemoPerson('Hassan Alsahli', 'hassan.sahli@tebyan.com', ['CS350', 'CS431', 'CS330', 'CS360']),
    DemoPerson('Rawan Albalawi', 'rawan.balawi@tebyan.com', ['CS350', 'CS499', 'CS221']),
    DemoPerson('Alanoud Alghamdi', 'alanoud.ghamdi@tebyan.com', ['CS410', 'CS102', 'CS330']),
    DemoPerson('Lina Alotaibi', 'lina.otaibi@tebyan.com', ['CS420', 'CS311', 'CS350']),
    DemoPerson('Dalia Alotaibi', 'dalia.otaibi@tebyan.com', ['CS420', 'CS410', 'CS221', 'CS499']),
    DemoPerson('Sultan Alotaibi', 'sultan.otaibi@tebyan.com', ['CS410', 'CS371', 'CS102']),
    DemoPerson('Saud Alenezi', 'saud.enezi@tebyan.com', ['MATH151', 'CS221', 'CS210']),
    DemoPerson('Atheer Alzahrani', 'atheer.zahrani@tebyan.com', ['CS311', 'CS431', 'CS420']),
    DemoPerson('Nada Alyami', 'nada.yami@tebyan.com', ['CS431', 'CS311', 'CS360']),
    DemoPerson('Salman Alsahli', 'salman.sahli@tebyan.com', ['CS371', 'CS340', 'CS311']),
    DemoPerson('Sara Alshehri', 'sara.shehri@tebyan.com', ['CS350', 'CS101', 'CS330']),
    DemoPerson('Bandar Alqahtani', 'bandar.qahtani@tebyan.com', ['CS499', 'CS431', 'MATH151']),
    DemoPerson('Areej Alhajri', 'areej.hajri@tebyan.com', ['CS410', 'CS420', 'CS102', 'CS499']),
    DemoPerson('Basil Alyami', 'basil.yami@tebyan.com', ['CS330', 'CS101', 'CS371']),
    DemoPerson('Asma Almutairi', 'asma.mutairi@tebyan.com', ['CS221', 'MATH151', 'CS340']),
    DemoPerson('Turki Alshehri', 'turki.shehri@tebyan.com', ['CS311', 'CS350', 'CS360', 'CS210']),
    DemoPerson('Hamad Alshehri', 'hamad.shehri@tebyan.com', ['CS431', 'CS410', 'CS420', 'CS102']),
    DemoPerson('Ziyad Alenezi', 'ziyad.enezi@tebyan.com', ['CS350', 'CS210', 'MATH151']),
    DemoPerson('Yousef Alamri', 'yousef.amri@tebyan.com', ['CS340', 'CS330', 'CS101', 'CS420']),
    DemoPerson('Jana Alqahtani', 'jana.qahtani@tebyan.com', ['CS410', 'CS431', 'CS221', 'CS102']),
    DemoPerson('Fahad Aldosari', 'fahad.dosari@tebyan.com', ['CS499', 'CS371', 'CS101']),
    DemoPerson('Wejdan Alhajri', 'wejdan.hajri@tebyan.com', ['CS311', 'CS210', 'CS330']),
    DemoPerson('Rakan Alamri', 'rakan.amri@tebyan.com', ['CS360', 'CS410', 'CS420']),
    DemoPerson('Mansour Alrashed', 'mansour.rashed@tebyan.com', ['CS360', 'CS340', 'CS499']),
    DemoPerson('Shatha Alsubaie', 'shatha.subaie@tebyan.com', ['CS371', 'CS102', 'CS499']),
    DemoPerson('Maha Alotaibi', 'maha.otaibi@tebyan.com', ['CS221', 'CS350', 'MATH151', 'CS420']),
    DemoPerson('Hessa Albalawi', 'hessa.balawi@tebyan.com', ['CS311', 'CS221', 'CS410', 'CS330']),
    DemoPerson('Meshal Aldosari', 'meshal.dosari@tebyan.com', ['CS431', 'MATH151', 'CS360']),
    DemoPerson('Remas Alhajri', 'remas.hajri@tebyan.com', ['CS371', 'CS210', 'CS350']),
    DemoPerson('Majed Aljohani', 'majed.johani@tebyan.com', ['CS311', 'CS431', 'CS101', 'CS210']),
    DemoPerson('Yazeed Alanazi', 'yazeed.anazi@tebyan.com', ['CS340', 'MATH151', 'CS330', 'CS360']),
    DemoPerson('Omar Alharbi', 'omar.harbi@tebyan.com', ['CS350', 'CS340', 'CS371', 'CS311']),
    DemoPerson('Ghala Alsahli', 'ghala.sahli@tebyan.com', ['CS101', 'CS499', 'CS420']),
    DemoPerson('Anas Aldosari', 'anas.dosari@tebyan.com', ['CS410', 'CS102', 'CS340']),
    DemoPerson('Lujain Aljohani', 'lujain.johani@tebyan.com', ['CS330', 'CS311', 'CS420', 'CS102']),
    DemoPerson('Joud Alshammari', 'joud.shammari@tebyan.com', ['CS431', 'CS210', 'CS350']),
    DemoPerson('Nawaf Alhajri', 'nawaf.hajri@tebyan.com', ['CS221', 'CS360', 'CS410', 'CS431']),
    DemoPerson('Haya Alghamdi', 'haya.ghamdi@tebyan.com', ['CS499', 'MATH151', 'CS340', 'CS210']),
    DemoPerson('Mohammed Alyami', 'mohammed.yami@tebyan.com', ['CS101', 'CS371', 'CS221']),
    DemoPerson('Danah Alzahrani', 'danah.zahrani@tebyan.com', ['CS330', 'CS102', 'CS221']),
    DemoPerson('Hassan Alamri', 'hassan.amri@tebyan.com', ['CS350', 'MATH151', 'CS410']),
  ];
}
