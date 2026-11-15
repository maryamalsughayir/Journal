//
//  JournalEditorView.swift
//  Journal
//

import SwiftUI

/// شاشة الإضافة والتعديل (تُعرض كـ sheet). نفس الشاشة تُستخدم للحالتين:
/// إذا كان editingEntry في الـ ViewModel فارغًا فهي إضافة، وإلا فهي تعديل.
/// تحتوي على حقل العنوان، التاريخ، محرر النص، وزرّي الإلغاء (X) والحفظ (✓) في الـ toolbar.
// الهدف: Form Editing — TextField للعنوان و TextEditor للمحتوى مع مسار حفظ/إلغاء كامل.
struct JournalEditorView: View {

    /// الـ ViewModel المشترك، مُمرَّر من الشاشة الرئيسية. نراقبه بـ @ObservedObject
    /// لأننا لا نملكه هنا، ونربط حقول الإدخال مباشرة بمسودته عبر $viewModel.
    // الهدف: State Management — @ObservedObject + ربط ثنائي الاتجاه ($) مع خصائص @Published.
    @ObservedObject var viewModel: JournalViewModel

    /// الحقول التي يمكن أن يكون الكيبورد مركّزًا عليها.
    private enum Field: Hashable {
        case title
        case content
    }

    /// الحقل المركّز حاليًا. نستخدمه لفتح الكيبورد على العنوان عند الظهور ولإغلاقه عند الحاجة.
    // الهدف: User Experience — التحكم بالكيبورد (فتحه تلقائيًا وإغلاقه بزر Done).
    @FocusState private var focusedField: Field?

    var body: some View {
        // الهدف: Navigation & Toolbar — NavigationStack داخل الـ sheet حتى نضع أزرار X و ✓ في الـ toolbar.
        NavigationStack {
            ZStack {
                Color("ColorBackground")
                    .ignoresSafeArea()

                // الهدف: SwiftUI Layout — ScrollView حتى يبقى المحتوى الطويل قابلًا للتمرير مع ظهور الكيبورد.
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        // Heading / L Bold 34 حسب دليل التصميم، بلون العناوين ColorAccent.
                        TextField("Title", text: $viewModel.draftTitle)
                            .font(.system(size: 34, weight: .bold))
                            .foregroundStyle(Color("ColorAccent"))
                            .focused($focusedField, equals: .title)
                            .submitLabel(.next)
                            // عند الضغط على "التالي" في الكيبورد ننتقل إلى حقل المحتوى.
                            .onSubmit { focusedField = .content }

                        // Caption / M Regular 16 حسب دليل التصميم، بلون التواريخ ColorSecondary.
                        Text(viewModel.formattedDate(viewModel.draftDate))
                            .font(.system(size: 16))
                            .foregroundStyle(Color("ColorSecondary"))

                        // مكوّن قابل لإعادة الاستخدام يغلّف TextEditor ويضيف له نص placeholder.
                        PlaceholderTextEditor(
                            text: $viewModel.draftContent,
                            placeholder: "Type your Journal…"
                        )
                        .focused($focusedField, equals: .content)
                        .frame(minHeight: 400)
                        .padding(.top, 12)
                    }
                    .padding(20)
                }
                // الهدف: User Experience — سحب القائمة للأسفل يخفي الكيبورد تدريجيًا.
                .scrollDismissesKeyboard(.interactively)
            }
            .toolbar { toolbarContent }
            // نفتح الكيبورد على حقل العنوان مباشرة كما يظهر في التصميم.
            .onAppear { focusedField = .title }
            // الهدف: List Interactions / User Experience — التأكيد قبل تجاهل التغييرات.
            // استخدمنا confirmationDialog لأن التصميم يعرض الخيارات من أسفل الشاشة.
            .confirmationDialog(
                "Are you sure you want to discard changes on this journal?",
                isPresented: $viewModel.isDiscardAlertPresented,
                titleVisibility: .visible
            ) {
                Button("Discard Changes", role: .destructive) {
                    viewModel.discardChanges()
                }
                Button("Keep Editing", role: .cancel) { }
            }
        }
        // نمنع إغلاق الـ sheet بالسحب للأسفل إذا كانت هناك تغييرات غير محفوظة حتى لا تضيع بالخطأ.
        .interactiveDismissDisabled(viewModel.hasUnsavedChanges)
        .tint(Color("ColorPrimary"))
    }

    // MARK: - أزرار الـ Toolbar

    /// زر X للإلغاء، زر ✓ للحفظ، وزر Done فوق الكيبورد لإغلاقه.
    // الهدف: Navigation & Toolbar — أزرار الـ toolbar داخل sheet.
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        // زر الإلغاء: لا يغلق مباشرة بل يطلب من الـ ViewModel التحقق من وجود تغييرات أولًا.
        // الهدف: Form Editing — مسار الإلغاء (Cancel flow).
        ToolbarItem(placement: .cancellationAction) {
            Button {
                viewModel.requestDismissEditor()
            } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(Color("ColorText"))
            }
        }

        // زر الحفظ: معطّل حتى يُكتب عنوان، ويأخذ اللون الأساسي ColorPrimary حسب دليل التصميم.
        // الهدف: Form Editing — مسار الحفظ (Save flow).
        ToolbarItem(placement: .confirmationAction) {
            Button {
                viewModel.saveDraft()
            } label: {
                Image(systemName: "checkmark")
            }
            .disabled(!viewModel.canSaveDraft)
        }

        // زر Done فوق الكيبورد لإغلاقه، لأن زر الرجوع في TextEditor يضيف سطرًا جديدًا ولا يغلق الكيبورد.
        // الهدف: User Experience — إخفاء الكيبورد (keyboard dismiss).
        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            Button("Done") {
                focusedField = nil
            }
        }
    }
}

#Preview("New entry") {
    JournalEditorView(viewModel: JournalViewModel())
        .preferredColorScheme(.dark)
}

#Preview("Edit entry") {
    let viewModel = JournalViewModel(entries: JournalViewModel.sampleEntries)
    viewModel.presentEditor(for: JournalViewModel.sampleEntries[2])
    return JournalEditorView(viewModel: viewModel)
        .preferredColorScheme(.dark)
}
