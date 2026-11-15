//
//  JournalApp.swift
//  Journal
//
//  Created by maryam on 29/05/1448 AH.
//

import SwiftUI

/// نقطة دخول التطبيق (@main). تنشئ نافذة واحدة وتعرض فيها الواجهة الجذرية ContentView.
/// فرضنا المظهر الداكن لأن التصميم كله مبني على خلفية سوداء.
@main
struct JournalApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}
