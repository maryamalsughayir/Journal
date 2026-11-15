//
//  ContentView.swift
//  Journal
//
//  Created by maryam on 29/05/1448 AH.
//

import SwiftUI

/// الواجهة الجذرية للتطبيق. مسؤوليتها فقط:
/// 1) إنشاء الـ ViewModel الوحيد ومشاركته مع بقية الشاشات.
/// 2) عرض شاشة الـ Splash لمدة قصيرة ثم الانتقال للشاشة الرئيسية.
struct ContentView: View {

    /// الـ ViewModel الرئيسي. أنشأناه هنا بـ @StateObject لأن هذه الواجهة هي "المالك" له،
    /// فيبقى حيًا طوال عمر التطبيق ولا يُعاد إنشاؤه عند إعادة رسم الواجهة.
    // الهدف: State Management — @StateObject يُستخدم مرة واحدة في المكان الذي يُنشئ الكائن.
    // الهدف: MVVM Pattern — ربط الـ ViewModel بالواجهة من أعلى الشجرة وتمريره للأسفل.
    @StateObject private var viewModel = JournalViewModel()

    /// حالة محلية بسيطة تخص هذه الواجهة فقط: هل ما زلنا نعرض شاشة الـ Splash؟
    // الهدف: State Management — @State مناسب للحالة البسيطة التي لا يحتاجها أحد غير هذه الواجهة.
    @State private var isShowingSplash = true

    var body: some View {
        // الهدف: SwiftUI Layout — ZStack لوضع شاشة الـ Splash فوق الشاشة الرئيسية ثم إخفائها.
        ZStack {
            JournalListView(viewModel: viewModel)

            if isShowingSplash {
                SplashView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        // ننتظر ثانيتين باستخدام async/await ثم نخفي الـ Splash بحركة تلاشي.
        .task {
            try? await Task.sleep(for: .seconds(2))
            withAnimation(.easeOut(duration: 0.4)) {
                isShowingSplash = false
            }
        }
    }
}

#Preview("App") {
    ContentView()
        .preferredColorScheme(.dark)
}
