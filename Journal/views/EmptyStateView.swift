//
//  EmptyStateView.swift
//  Journal
//

import SwiftUI

/// واجهة حالة الفراغ التي تظهر عندما لا توجد أي يومية بعد:
/// صورة الكتاب المفتوح، عنوان "Begin Your Journal"، ونص إرشادي.
/// مكوّن عرض فقط بدون حالة، قابل لإعادة الاستخدام في أي شاشة.
// الهدف: User Experience — التعامل مع حالة الفراغ (Empty State) بدل عرض شاشة سوداء.
struct EmptyStateView: View {

    var body: some View {
        // الهدف: SwiftUI Layout — VStack لترتيب الصورة والعنوان والنص عموديًا في المنتصف.
        VStack(spacing: 24) {
            Image("ImageOpenbook")
                .resizable()
                .scaledToFit()
                .frame(width: 77)

            // Heading / M Bold 24 حسب دليل التصميم، بلون العناوين ColorAccent.
            Text("Begin Your Journal")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color("ColorAccent"))

            // Body / Supporting Light 18 حسب دليل التصميم.
            Text("Craft your personal diary, tap the plus icon to begin")
                .font(.system(size: 18, weight: .light))
                .foregroundStyle(Color("ColorText"))
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)
        }
    }
}

#Preview {
    ZStack {
        Color("ColorBackground").ignoresSafeArea()
        EmptyStateView()
    }
    .preferredColorScheme(.dark)
}
