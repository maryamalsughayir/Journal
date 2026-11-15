//
//  JournalEntry.swift
//  Journal
//
//  Created by maryam on 05/06/1448 AH.
//

import Foundation

/// نموذج البيانات (Model) الذي يمثل يومية واحدة في التطبيق.
/// يحتوي على البيانات فقط (عنوان، محتوى، تاريخ، إشارة مرجعية) بدون أي منطق،
/// لأن دور الـ Model في MVVM هو وصف شكل البيانات لا التعامل معها.
// الهدف: MVVM Pattern — هذا الملف هو طبقة الـ Model، بنية بيانات بحتة (struct)،
// وكل العمليات عليها (إضافة، تعديل، حذف، بحث) موجودة في JournalViewModel وليس هنا.
struct JournalEntry: Identifiable, Hashable {

    /// معرّف فريد لكل يومية. تحتاجه SwiftUI (بروتوكول Identifiable)
    /// لتمييز كل صف داخل List و ForEach وتحريك الإضافة والحذف بشكل صحيح.
    let id: UUID

    /// عنوان اليومية (يظهر باللون ColorAccent في البطاقة).
    var title: String

    /// نص اليومية الكامل.
    var content: String

    /// تاريخ إنشاء اليومية، يُعرض بصيغة dd/MM/yyyy ويُستخدم في الترتيب.
    var date: Date

    /// هل اليومية محفوظة كإشارة مرجعية (Bookmark) أم لا.
    var isBookmarked: Bool

    /// مُنشئ بقيم افتراضية: معرّف جديد، تاريخ اليوم، وبدون إشارة مرجعية.
    /// القيم الافتراضية تسهّل إنشاء يومية جديدة بتمرير العنوان والمحتوى فقط.
    init(
        id: UUID = UUID(),
        title: String,
        content: String,
        date: Date = .now,
        isBookmarked: Bool = false
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.date = date
        self.isBookmarked = isBookmarked
    }
}
