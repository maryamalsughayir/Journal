//
//  PlaceholderTextEditor.swift
//  Journal
//

import SwiftUI

/// مكوّن قابل لإعادة الاستخدام يغلّف TextEditor ويضيف له نص placeholder،
/// لأن TextEditor في SwiftUI لا يدعم الـ placeholder بشكل مدمج مثل TextField.
/// يستقبل النص كـ @Binding حتى يكتب مباشرة في مصدر الحقيقة الموجود في الـ ViewModel.
// الهدف: State Management — @Binding يسمح لمكوّن فرعي بتعديل قيمة يملكها غيره بدون نسخها.
// الهدف: Form Editing — TextEditor هو المكوّن الأساسي لكتابة نص متعدد الأسطر.
struct PlaceholderTextEditor: View {

    /// النص المربوط بمسودة المحتوى في الـ ViewModel (ثنائي الاتجاه).
    @Binding var text: String

    /// النص الإرشادي الذي يظهر عندما يكون المحرر فارغًا.
    let placeholder: String

    var body: some View {
        // الهدف: SwiftUI Layout — ZStack لوضع نص الـ placeholder خلف المحرر في نفس الموضع.
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundStyle(Color("ColorSecondary"))
                    // إزاحة بسيطة حتى يتطابق موضع الـ placeholder مع موضع المؤشر داخل TextEditor.
                    .padding(.top, 8)
                    .padding(.leading, 5)
                    // نترك اللمسات تمر إلى المحرر تحته.
                    .allowsHitTesting(false)
            }

            TextEditor(text: $text)
                .foregroundStyle(Color("ColorText"))
                // إخفاء الخلفية الافتراضية حتى يظهر المحرر على الخلفية السوداء.
                .scrollContentBackground(.hidden)
                // نعطّل التمرير الداخلي لأن الـ ScrollView الخارجي هو من يتولى التمرير.
                .scrollDisabled(true)
        }
        // Body / L Regular 20 حسب دليل التصميم.
        .font(.system(size: 20))
    }
}

#Preview {
    @Previewable @State var text = ""
    ZStack {
        Color("ColorBackground").ignoresSafeArea()
        PlaceholderTextEditor(text: $text, placeholder: "Type your Journal…")
            .padding()
    }
    .preferredColorScheme(.dark)
}
