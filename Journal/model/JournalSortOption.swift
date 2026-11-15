//
//  JournalSortOption.swift
//  Journal
//

import Foundation

/// خيارات الفلترة/الترتيب التي تظهر في قائمة زر الفلتر في الشاشة الرئيسية.
/// هذا enum جزء من طبقة الـ Model لأنه يصف "بيانات" الخيار فقط بدون منطق التطبيق.
// الهدف: Search & Filter — يحدد الخيارين المطلوبين في التصميم:
// الترتيب حسب تاريخ الإدخال، وعرض اليوميات المحفوظة (Bookmark) فقط.
enum JournalSortOption: String, CaseIterable, Identifiable {

    /// ترتيب اليوميات من الأحدث إلى الأقدم حسب التاريخ.
    case entryDate = "Sort by Entry Date"

    /// عرض اليوميات التي عليها إشارة مرجعية فقط.
    case bookmark = "Sort by Bookmark"

    /// المعرّف المطلوب من Identifiable حتى نستخدم الخيارات داخل ForEach.
    var id: String { rawValue }

    /// النص الذي يظهر للمستخدم في القائمة (نفس النص الموجود في التصميم).
    var title: String { rawValue }
}
