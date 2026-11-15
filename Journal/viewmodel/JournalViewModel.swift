//
//  JournalViewModel.swift
//  Journal
//
//  Created by maryam on 05/06/1448 AH.
//

import Foundation

/// الـ ViewModel الرئيسي للتطبيق. يملك كل الحالة (State) وكل المنطق:
/// قائمة اليوميات، نص البحث، خيار الفلترة، مسودة الإضافة/التعديل، وتأكيد الحذف.
/// الواجهات (Views) تقرأ منه وتستدعي دواله فقط، ولا تحتوي على منطق بنفسها.
// الهدف: MVVM Pattern — هذا الملف هو طبقة الـ ViewModel. يفصل المنطق عن الواجهة:
// الـ View لا تعرف كيف يتم البحث أو الحذف، هي فقط تستدعي دالة وتعرض النتيجة.
// الهدف: State Management — الكلاس يطبّق ObservableObject، وكل خاصية @Published
// تُخبر SwiftUI تلقائيًا بإعادة رسم أي View تراقبها عند تغيّر قيمتها.
final class JournalViewModel: ObservableObject {

    // MARK: - الحالة المنشورة (Published State)

    /// مصدر الحقيقة الوحيد لكل اليوميات. أي إضافة أو تعديل أو حذف يحدث هنا.
    @Published var entries: [JournalEntry]

    /// النص المكتوب في شريط البحث. مربوط مباشرة بـ .searchable في الواجهة.
    @Published var searchText: String = ""

    /// خيار الفلترة الحالي. nil يعني عرض كل اليوميات بالترتيب الافتراضي.
    @Published var sortOption: JournalSortOption? = nil

    /// هل شاشة الإضافة/التعديل (sheet) معروضة الآن؟
    @Published var isEditorPresented: Bool = false

    /// اليومية التي يتم تعديلها حاليًا. nil يعني أننا نضيف يومية جديدة.
    @Published var editingEntry: JournalEntry? = nil

    /// مسودة العنوان أثناء الكتابة في شاشة الإضافة/التعديل.
    @Published var draftTitle: String = ""

    /// مسودة المحتوى أثناء الكتابة في شاشة الإضافة/التعديل.
    @Published var draftContent: String = ""

    /// التاريخ المعروض في شاشة الإضافة/التعديل (تاريخ اليوم للجديد، أو تاريخ اليومية عند التعديل).
    @Published var draftDate: Date = .now

    /// هل نعرض تنبيه "تجاهل التغييرات" عند الضغط على X؟
    @Published var isDiscardAlertPresented: Bool = false

    /// اليومية التي طلب المستخدم حذفها وننتظر تأكيده.
    @Published var entryPendingDeletion: JournalEntry? = nil

    /// هل نعرض تنبيه تأكيد الحذف؟
    @Published var isDeleteAlertPresented: Bool = false

    /// المُنشئ. افتراضيًا يبدأ التطبيق بقائمة فارغة حتى تظهر حالة الفراغ (Empty State)،
    /// ويمكن تمرير بيانات تجريبية للـ Previews.
    init(entries: [JournalEntry] = []) {
        self.entries = entries
    }

    // MARK: - خصائص محسوبة (Computed Properties)

    /// هل لا توجد أي يومية؟ تستخدمها الواجهة لتقرر عرض حالة الفراغ.
    // الهدف: User Experience — التعامل مع حالة الفراغ (Empty State).
    var isEmpty: Bool {
        entries.isEmpty
    }

    /// القائمة النهائية التي تعرضها الشاشة الرئيسية بعد تطبيق البحث ثم الفلترة.
    // الهدف: Search & Filter — هنا يتم البحث في العنوان والمحتوى معًا بدون حساسية
    // لحالة الأحرف، ثم يُطبّق خيار الترتيب (حسب التاريخ) أو الفلترة (المحفوظة فقط).
    var displayedEntries: [JournalEntry] {
        var result = entries

        // الخطوة الأولى: البحث بالكلمات أو العبارات في العنوان أو المحتوى.
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !query.isEmpty {
            result = result.filter { entry in
                entry.title.localizedCaseInsensitiveContains(query)
                    || entry.content.localizedCaseInsensitiveContains(query)
            }
        }

        // الخطوة الثانية: تطبيق خيار الفلتر المختار من القائمة.
        switch sortOption {
        case .entryDate:
            result.sort { $0.date > $1.date }
        case .bookmark:
            result = result.filter { $0.isBookmarked }
        case nil:
            break
        }

        return result
    }

    /// هل المستخدم يعدّل يومية موجودة (true) أم يضيف جديدة (false)؟
    var isEditingExistingEntry: Bool {
        editingEntry != nil
    }

    /// هل يمكن الحفظ؟ نشترط وجود عنوان غير فارغ حتى لا تُحفظ يومية بلا اسم.
    // الهدف: Form Editing — التحقق من صحة المدخلات قبل السماح بالحفظ.
    var canSaveDraft: Bool {
        !draftTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// هل توجد تغييرات غير محفوظة في المسودة؟
    /// عند التعديل نقارن المسودة بالقيم الأصلية، وعند الإضافة نتحقق أن الحقول ليست فارغة.
    // الهدف: List Interactions — نحتاج هذه القيمة لنقرر هل نعرض تنبيه التأكيد قبل تجاهل التغييرات.
    var hasUnsavedChanges: Bool {
        if let editingEntry {
            return draftTitle != editingEntry.title || draftContent != editingEntry.content
        }
        return !draftTitle.isEmpty || !draftContent.isEmpty
    }

    // MARK: - الإضافة والتعديل (Add / Edit)

    /// يفتح شاشة إضافة يومية جديدة بمسودة فارغة وتاريخ اليوم.
    // الهدف: Navigation & Toolbar — تغيير isEditorPresented هو ما يفتح الـ sheet في الواجهة.
    func presentNewEntry() {
        editingEntry = nil
        draftTitle = ""
        draftContent = ""
        draftDate = .now
        isEditorPresented = true
    }

    /// يفتح شاشة التعديل ويملأ المسودة ببيانات اليومية المختارة.
    func presentEditor(for entry: JournalEntry) {
        editingEntry = entry
        draftTitle = entry.title
        draftContent = entry.content
        draftDate = entry.date
        isEditorPresented = true
    }

    /// يحفظ المسودة: إما يحدّث اليومية الموجودة أو يضيف يومية جديدة في أعلى القائمة.
    // الهدف: Form Editing — مسار الحفظ (Save flow) بعد الكتابة في TextField و TextEditor.
    func saveDraft() {
        guard canSaveDraft else { return }
        let cleanTitle = draftTitle.trimmingCharacters(in: .whitespacesAndNewlines)

        if let editingEntry,
           let index = entries.firstIndex(where: { $0.id == editingEntry.id }) {
            // تعديل يومية موجودة: نحدّث العنوان والمحتوى فقط ونحافظ على التاريخ والإشارة المرجعية.
            entries[index].title = cleanTitle
            entries[index].content = draftContent
        } else {
            // إضافة يومية جديدة في بداية القائمة حتى تظهر أولًا.
            let newEntry = JournalEntry(title: cleanTitle, content: draftContent, date: draftDate)
            entries.insert(newEntry, at: 0)
        }

        dismissEditor()
    }

    /// يُستدعى عند الضغط على زر X: إذا كانت هناك تغييرات غير محفوظة نعرض تنبيه التأكيد،
    /// وإلا نغلق الشاشة مباشرة.
    // الهدف: List Interactions / User Experience — التأكيد قبل تجاهل التغييرات عبر تنبيه.
    func requestDismissEditor() {
        if hasUnsavedChanges {
            isDiscardAlertPresented = true
        } else {
            dismissEditor()
        }
    }

    /// يتجاهل التغييرات ويغلق شاشة التعديل (يُستدعى من زر Discard Changes).
    func discardChanges() {
        dismissEditor()
    }

    /// يغلق شاشة الإضافة/التعديل ويصفّر المسودة.
    // الهدف: Form Editing — مسار الإلغاء (Cancel flow).
    func dismissEditor() {
        isEditorPresented = false
        editingEntry = nil
        draftTitle = ""
        draftContent = ""
    }

    // MARK: - الإشارة المرجعية (Bookmark)

    /// يبدّل حالة الإشارة المرجعية لليومية المحددة.
    /// نبحث عن اليومية بالمعرّف ثم نعدّلها داخل المصفوفة حتى تنتشر التغييرات عبر @Published.
    func toggleBookmark(for entry: JournalEntry) {
        guard let index = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[index].isBookmarked.toggle()
    }

    // MARK: - الحذف (Delete)

    /// يُستدعى من زر السحب (swipe): يحفظ اليومية المطلوب حذفها ويعرض تنبيه التأكيد.
    // الهدف: List Interactions — الحذف عبر swipe action مع تأكيد قبل التنفيذ.
    func requestDelete(_ entry: JournalEntry) {
        entryPendingDeletion = entry
        isDeleteAlertPresented = true
    }

    /// ينفّذ الحذف فعليًا بعد موافقة المستخدم في التنبيه.
    func confirmDelete() {
        if let entry = entryPendingDeletion {
            entries.removeAll { $0.id == entry.id }
        }
        entryPendingDeletion = nil
    }

    /// يلغي عملية الحذف (زر Cancel في التنبيه).
    func cancelDelete() {
        entryPendingDeletion = nil
    }

    // MARK: - الفلترة (Filter)

    /// يختار خيار الفلترة، والضغط على نفس الخيار مرة أخرى يلغيه ويعيد العرض الافتراضي.
    // الهدف: Search & Filter — ربط خيارات القائمة بالحالة التي تعتمد عليها displayedEntries.
    func selectSortOption(_ option: JournalSortOption) {
        sortOption = (sortOption == option) ? nil : option
    }

    // MARK: - تنسيق التاريخ (Date Formatting)

    /// مُنسّق تاريخ واحد مشترك بصيغة التصميم dd/MM/yyyy (مثال: 02/09/2024).
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()

    /// يحوّل التاريخ إلى نص بالصيغة المطلوبة في التصميم.
    /// وضعنا التنسيق هنا وليس في الـ View حتى تبقى الواجهة للعرض فقط.
    func formattedDate(_ date: Date) -> String {
        JournalViewModel.dateFormatter.string(from: date)
    }

    // MARK: - بيانات تجريبية للـ Previews

    /// تاريخ ثابت (02/09/2024) مطابق للتصميم، يُستخدم في البيانات التجريبية فقط.
    private static let sampleDate: Date = {
        var components = DateComponents()
        components.year = 2024
        components.month = 9
        components.day = 2
        return Calendar.current.date(from: components) ?? .now
    }()

    /// ثلاث يوميات تجريبية مطابقة لشاشة التصميم، تُستخدم في الـ Previews فقط
    /// وليس في التطبيق الفعلي الذي يبدأ فارغًا.
    static let sampleEntries: [JournalEntry] = [
        JournalEntry(
            title: "My Birthday",
            content: "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Donec odio. Quisque volutpat mattis eros. Nullam malesuada erat ut turpis. Suspendisse urna nibh viverra non semper suscipit posuere a pede.",
            date: sampleDate,
            isBookmarked: true
        ),
        JournalEntry(
            title: "Today’s Journal",
            content: "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Donec odio. Quisque volutpat mattis eros. Nullam malesuada erat ut turpis. Suspendisse urna nibh viverra non semper suscipit posuere a pede.",
            date: sampleDate
        ),
        JournalEntry(
            title: "Great Day",
            content: "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Donec odio. Quisque volutpat mattis eros. Nullam malesuada erat ut turpis. Suspendisse urna nibh viverra non semper suscipit posuere a pede.",
            date: sampleDate
        )
    ]
}
