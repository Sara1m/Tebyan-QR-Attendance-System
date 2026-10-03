// Arabic translations. English is the key itself.
class AppTranslation {
  static Map<String, Map<String, String>> translations = {
    'ar': Locales.ar,
  };
}

class Locales {
  static const ar = <String, String>{
    // ---- General ----
    "Tebyan": "تبيان",
    "Home": "الرئيسية",
    "Profile": "حسابي",
    "Settings": "الإعدادات",
    "Account": "الحساب",
    "Name": "الاسم",
    "Full Name": "الاسم الكامل",
    "Email": "البريد الإلكتروني",
    "Password": "كلمة المرور",
    "Account Type": "نوع الحساب",
    "Admin": "مسؤول",
    "Student": "طالب",
    "Lecturer": "محاضر",
    "Students": "الطلاب",
    "Lecturers": "المحاضرون",
    "Courses": "المقررات",
    "Lectures": "المحاضرات",
    "Admin panel": "لوحة الإدارة",
    "Create": "إضافة",
    "Save": "حفظ",
    "Edit": "تعديل",
    "Delete": "حذف",
    "Remove": "إزالة",
    "Cancel": "إلغاء",
    "Confirm": "تأكيد",
    "OK": "حسنًا",
    "Refresh": "تحديث",
    "Try again": "حاول مرة أخرى",
    "Search by name or email": "ابحث بالاسم أو البريد",
    "Search by name or code": "ابحث بالاسم أو الرمز",
    "Tap + at the top to add the first one.": "اضغط + في الأعلى لإضافة أول عنصر.",
    "Today": "اليوم",
    "Date": "التاريخ",
    "Time": "الوقت",
    "Sign Out": "تسجيل الخروج",
    "Good morning": "صباح الخير",
    "Good afternoon": "مساء الخير",
    "Good evening": "مساء الخير",
    "Credit hours": "ساعات معتمدة",
    "@hours hours": "@hours ساعات",
    "My courses": "مقرراتي",

    // ---- Login ----
    "LOGIN": "دخول",
    "Welcome back 👋": "أهلًا بعودتك 👋",
    "Smart attendance and course platform": "منصة المقررات والحضور الذكي",
    "Sign in to your account": "سجّل الدخول إلى حسابك",
    "Forgot your password?": "نسيت كلمة المرور؟",
    "Enter your email": "أدخل بريدك الإلكتروني",
    "Enter your email and we will send you a link to choose a new password.":
        "أدخل بريدك الإلكتروني وسنرسل لك رابطًا لاختيار كلمة مرور جديدة.",
    "Send link": "إرسال الرابط",
    "If this email is registered, a reset link has been sent to it. Check your inbox and spam folder.":
        "إذا كان البريد مسجلًا فقد أرسلنا إليه رابط الاستعادة. تفقّد صندوق الوارد والرسائل غير المرغوب فيها.",
    "Please enter the email": "فضلًا أدخل البريد الإلكتروني",
    "Please enter the password": "فضلًا أدخل كلمة المرور",
    "Email address is invalid": "البريد الإلكتروني غير صحيح",
    "Email address or password was wrong":
        "البريد الإلكتروني أو كلمة المرور غير صحيحة",
    "Too many requests, try again later":
        "محاولات كثيرة، انتظر قليلًا ثم حاول مرة أخرى",
    "This account has been disabled": "تم إيقاف هذا الحساب",
    "This account no longer exists. Contact the administrator.":
        "هذا الحساب لم يعد موجودًا، تواصل مع المسؤول.",
    "Unknown account type": "نوع الحساب غير معروف",
    "Email sign-in is not enabled in Firebase":
        "تسجيل الدخول بالبريد غير مفعّل في Firebase",

    // ---- Errors ----
    "Check your internet connection": "تأكد من اتصالك بالإنترنت",
    "Please sign in again and retry": "سجّل الدخول من جديد ثم حاول مرة أخرى",
    "You don't have permission to do this": "ليست لديك صلاحية لتنفيذ هذا الإجراء",
    "Item not found": "العنصر غير موجود",
    "Something went wrong, please try again": "حدث خطأ ما، حاول مرة أخرى",
    "Email address already in use": "البريد الإلكتروني مستخدم مسبقًا",
    "Password must be at least 6 characters long":
        "كلمة المرور يجب أن تكون 6 أحرف على الأقل",

    // ---- Users (admin) ----
    "Add Student": "إضافة طالب",
    "Edit Student": "تعديل طالب",
    "Delete Student": "حذف طالب",
    "Add Lecturer": "إضافة محاضر",
    "Edit Lecturer": "تعديل محاضر",
    "Delete Lecturer": "حذف محاضر",
    "No Students Found!": "لا يوجد طلاب بعد!",
    "No Lecturers Found!": "لا يوجد محاضرون بعد!",
    "At least 6 characters": "6 أحرف على الأقل",
    "No courses yet. Add courses first from the Courses tab.":
        "لا توجد مقررات بعد. أضف المقررات أولًا من تبويب المقررات.",
    "Please enter the name": "فضلًا أدخل الاسم",
    "Please choose courses": "فضلًا اختر مقررًا واحدًا على الأقل",
    "Account created successfully": "تم إنشاء الحساب بنجاح",
    "Changes saved": "تم حفظ التعديلات",
    "Account deleted": "تم حذف الحساب",
    "Are you sure you want to delete @name? They will not be able to sign in any more.":
        "هل أنت متأكد من حذف @name؟ لن يتمكن من تسجيل الدخول بعد ذلك.",
    "Send password reset link": "إرسال رابط استعادة كلمة المرور",
    "A password reset link was sent to @email":
        "تم إرسال رابط استعادة كلمة المرور إلى @email",

    // ---- Courses ----
    "Add Course": "إضافة مقرر",
    "Edit Course": "تعديل مقرر",
    "Delete Course": "حذف المقرر",
    "Course Name": "اسم المقرر",
    "Course Code": "رمز المقرر",
    "Course code": "رمز المقرر",
    "Course Hours": "عدد الساعات",
    "e.g. Data Structures": "مثال: هياكل البيانات",
    "No Courses Found!": "لا توجد مقررات!",
    "Please enter the course name": "فضلًا أدخل اسم المقرر",
    "Please enter the course code": "فضلًا أدخل رمز المقرر",
    "Please enter the course hours": "فضلًا أدخل عدد الساعات",
    "A course with this code already exists": "يوجد مقرر بنفس الرمز",
    "Course added": "تمت إضافة المقرر",
    "Course deleted": "تم حذف المقرر",
    "Are you sure you want to delete @name? Its lectures will no longer appear.":
        "هل أنت متأكد من حذف مقرر @name؟ لن تظهر محاضراته بعد ذلك.",
    "The administrator has not registered any courses for you yet.":
        "لم يسجّل لك المسؤول أي مقرر حتى الآن.",
    "Your courses and attendance in one place": "مقرراتك وحضورك في مكان واحد",
    "Manage your lectures and take attendance in seconds":
        "أدِر محاضراتك وسجّل الحضور في ثوانٍ",

    // ---- Lectures ----
    "Add Lecture": "إضافة محاضرة",
    "Edit Lecture": "تعديل محاضرة",
    "Delete Lecture": "حذف المحاضرة",
    "Lecture Name": "اسم المحاضرة",
    "e.g. Introduction to Data Structures": "مثال: مقدمة في هياكل البيانات",
    "Choose Date": "اختر التاريخ",
    "Choose Time": "اختر الوقت",
    "No Lectures Found!": "لا توجد محاضرات!",
    "Lectures added by your lecturer will appear here.":
        "ستظهر هنا المحاضرات التي يضيفها المحاضر.",
    "Add your first lecture with the + button.": "أضف أول محاضرة بزر +",
    "Please enter the lecture name": "فضلًا أدخل اسم المحاضرة",
    "Please enter the lecture date": "فضلًا اختر تاريخ المحاضرة",
    "Please enter the lecture time": "فضلًا اختر وقت المحاضرة",
    "Lecture added": "تمت إضافة المحاضرة",
    "Lecture deleted": "تم حذف المحاضرة",
    "Are you sure you want to delete @name and its attendance records?":
        "هل أنت متأكد من حذف محاضرة @name وسجلات حضورها؟",
    "Lectures and your attendance": "المحاضرات وحضورك",
    "Lectures and attendance": "المحاضرات والحضور",
    "Attended": "حضرت",

    // ---- Attendance ----
    "Attendance": "الحضور",
    "Take attendance": "تسجيل الحضور",
    "Attendance QR code": "رمز الحضور QR",
    "Attendance list": "كشف الحضور",
    "Show QR code": "عرض رمز QR",
    "Show code": "عرض الرمز",
    "Valid for": "مدة الصلاحية",
    "@m min": "@m دقيقة",
    "Valid for @m min": "صالح لمدة @m دقيقة",
    "Choose how long the code stays valid. Students scan it with their phone camera.":
        "اختر مدة صلاحية الرمز، ويمسحه الطلاب بكاميرا الجوال.",
    "Scan to record your attendance": "امسح الرمز لتسجيل حضورك",
    "Or enter this code": "أو أدخل هذا الرمز",
    "Code expired": "انتهت صلاحية الرمز",
    "New code": "رمز جديد",
    "End now": "إنهاء الآن",
    "Time left": "الوقت المتبقي",
    "Attendance closed": "تم إغلاق الحضور",
    "Present now": "الحاضرون الآن",
    "Attendance is open": "الحضور مفتوح",
    "Attendance open — scan now": "الحضور مفتوح، امسح الآن",
    "Present": "حاضر",
    "Absent": "غائب",
    "Rate": "النسبة",
    "No one has attended yet": "لم يسجّل أحد حضوره بعد",
    "Everyone is present!": "الجميع حاضرون!",
    "Open the QR code and ask students to scan it.":
        "اعرض رمز QR واطلب من الطلاب مسحه.",
    "Mark present": "تسجيل حضور",
    "Mark absent": "تسجيل غياب",
    "Remove the attendance of @name?": "إزالة حضور @name؟",
    "@name marked present": "تم تسجيل حضور @name",
    "@name marked absent": "تم تسجيل غياب @name",
    "Manual": "يدوي",
    "Code": "رمز",
    "QR": "QR",
    "Scan Code": "مسح الرمز",
    "Scan": "مسح",
    "Scan attendance": "مسح الحضور",
    "Enter code": "إدخال الرمز",
    "Enter code instead": "إدخال الرمز يدويًا",
    "Enter attendance code": "أدخل رمز الحضور",
    "Type the 8-character code shown under the QR code on the lecturer's screen right now. It changes every 20 seconds.":
        "اكتب الرمز المكوّن من 8 أحرف الظاهر الآن أسفل رمز QR على شاشة المحاضر، فهو يتغيّر كل 20 ثانية.",
    "Confirm attendance": "تأكيد الحضور",
    "Attendance recorded": "تم تسجيل الحضور",
    "Your attendance for @lecture has been recorded.":
        "تم تسجيل حضورك في محاضرة @lecture.",
    "Could not record attendance": "تعذّر تسجيل الحضور",
    "Checking the code…": "جارٍ التحقق من الرمز…",
    "Point the camera at the QR code on the lecturer's screen":
        "وجّه الكاميرا إلى رمز QR على شاشة المحاضر",
    "Flash": "الفلاش",
    "Switch camera": "تبديل الكاميرا",
    "Choose the lecture first": "اختر المحاضرة أولًا",
    "To type the code, open the course, then choose the lecture and tap \"Enter code\".":
        "لإدخال الرمز يدويًا افتح المقرر ثم اختر المحاضرة واضغط \"إدخال الرمز\".",
    "This is not a Tebyan attendance code": "هذا ليس رمز حضور من تبيان",
    "This code belongs to another lecture": "هذا الرمز خاص بمحاضرة أخرى",
    "This code has expired, ask the lecturer for a new one":
        "انتهت صلاحية الرمز، اطلب من المحاضر رمزًا جديدًا",
    "You are not registered in this course": "أنت غير مسجّل في هذا المقرر",
    "Your attendance is already recorded": "حضورك مسجّل مسبقًا",
    "The code is invalid or has expired": "الرمز غير صحيح أو انتهت صلاحيته",
    "Invalid code": "رمز غير صحيح",
    "Camera is not available": "الكاميرا غير متاحة",
    "Make sure no other app is using the camera, then try again.":
        "تأكد أن الكاميرا غير مستخدمة في تطبيق آخر ثم حاول مجددًا.",
    "Camera permission denied": "لم يتم السماح باستخدام الكاميرا",
    "Allow camera access for this site from the browser settings (the lock icon next to the address), then reload the page.":
        "اسمح للموقع باستخدام الكاميرا من إعدادات المتصفح (أيقونة القفل بجانب العنوان) ثم أعد تحميل الصفحة.",
    "This browser does not support the camera": "هذا المتصفح لا يدعم الكاميرا",
    "Open the site in Chrome or Safari, and make sure the address starts with https://":
        "افتح الموقع في Chrome أو Safari وتأكد أن العنوان يبدأ بـ https://",


    // ---- Anti-sharing: rotating code + location ----
    "Getting your location…": "جارٍ تحديد موقعك…",
    "Creating the code…": "جارٍ إنشاء الرمز…",
    "Checking your location…": "جارٍ التحقق من موقعك…",
    "Recording your attendance…": "جارٍ تسجيل حضورك…",
    "Code changes in @s s": "يتغيّر الرمز بعد @s ث",
    "Within @r m of you (±@a m)": "ضمن @r م منك (±@a م)",
    "Students must be in the classroom": "يجب أن يكون الطالب داخل القاعة",
    "Your location is used as the classroom location.": "يُستخدم موقعك كموقع للقاعة.",
    "Allowed distance": "المسافة المسموحة",
    "1 km (campus)": "1 كم (الحرم الجامعي)",
    "@r m": "@r م",
    "Tip: indoors, phone locations can be off by 20–100 m. If students inside are rejected, choose a larger distance.":
        "تنبيه: داخل المباني قد يخطئ الجوال في تحديد الموقع من 20 إلى 100 م. إذا رُفض طلاب موجودون في القاعة، اختر مسافة أكبر.",
    "@d m from the classroom": "على بعد @d م من القاعة",
    "This code is old. Scan the code shown on the lecturer's screen right now.":
        "هذا الرمز قديم. امسح الرمز الظاهر الآن على شاشة المحاضر.",
    "The code is invalid or has expired. Scan the code shown on the screen right now.":
        "الرمز غير صحيح أو انتهت صلاحيته. امسح الرمز الظاهر الآن على الشاشة.",
    "You are @d m away from the classroom. You must be within @r m to check in.":
        "أنت على بعد @d م من القاعة، ويجب أن تكون ضمن @r م لتسجيل الحضور.",
    "Turn on location services on your device, then try again":
        "فعّل خدمة الموقع في جهازك ثم حاول مرة أخرى",
    "Location permission is needed to confirm you are in the classroom. Allow it from the browser settings, then try again.":
        "نحتاج إذن الموقع للتأكد أنك داخل القاعة. اسمح به من إعدادات المتصفح ثم حاول مرة أخرى.",
    "Could not get your location. Turn on Wi-Fi or move near a window, then try again.":
        "تعذّر تحديد موقعك. فعّل الواي فاي أو اقترب من نافذة ثم حاول مرة أخرى.",

    // ---- Profile ----
    "Change password": "تغيير كلمة المرور",
    "Current password": "كلمة المرور الحالية",
    "New password": "كلمة المرور الجديدة",
    "Confirm new password": "تأكيد كلمة المرور الجديدة",
    "Please enter your current password": "فضلًا أدخل كلمة المرور الحالية",
    "The two passwords do not match": "كلمتا المرور غير متطابقتين",
    "The current password is wrong": "كلمة المرور الحالية غير صحيحة",
    "Your password has been changed": "تم تغيير كلمة المرور بنجاح",
  };
}
