//
//  SplashView.swift
//  Journal
//

import SwiftUI

/// شاشة البداية (Splash) المطابقة للتصميم: أيقونة الدفتر، اسم التطبيق "Journali"،
/// وتحته الشعار "Your thoughts, your story" على خلفية سوداء.
/// واجهة عرض فقط بدون أي حالة أو منطق.
struct SplashView: View {

    var body: some View {
        // الهدف: SwiftUI Layout — ZStack للخلفية، و VStack لترتيب العناصر عموديًا.
        ZStack {
            Color("ColorBackground")
                .ignoresSafeArea()

            VStack(spacing: 8) {
                Image("App Icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)

                // Display / Black 42 حسب دليل التصميم.
                Text("Journali")
                    .font(.system(size: 42, weight: .black))
                    .foregroundStyle(Color("ColorText"))

                // Body / Supporting Light 18 حسب دليل التصميم.
                Text("Your thoughts, your story")
                    .font(.system(size: 18, weight: .light))
                    .foregroundStyle(Color("ColorText"))
            }
        }
    }
}

#Preview {
    SplashView()
        .preferredColorScheme(.dark)
}
