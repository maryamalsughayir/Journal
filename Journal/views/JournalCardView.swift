//
//  JournalCardView.swift
//  Journal
//
//  Created by maryam on 05/06/1448 AH.
//

import SwiftUI

/// بطاقة يومية واحدة كما في التصميم: العنوان بالبنفسجي، التاريخ بالرمادي، المحتوى بالأبيض،
/// وزر الإشارة المرجعية في الزاوية. مكوّن قابل لإعادة الاستخدام لكل صف في القائمة.
/// البطاقة لا تعرف شيئًا عن الـ ViewModel؛ تستقبل البيانات الجاهزة و closure للضغط فقط.
// الهدف: MVVM Pattern — الـ View تعرض بيانات جاهزة وتُبلّغ عن الحدث عبر closure، ولا تعدّل البيانات بنفسها.
struct JournalCardView: View {

    /// اليومية التي تعرضها البطاقة.
    let entry: JournalEntry

    /// التاريخ منسّقًا مسبقًا من الـ ViewModel (حتى لا تحتوي الواجهة على منطق تنسيق).
    let formattedDate: String

    /// يُستدعى عند الضغط على أيقونة الإشارة المرجعية.
    let onToggleBookmark: () -> Void

    var body: some View {
        // الهدف: SwiftUI Layout — HStack للنصوص وزر الإشارة المرجعية جنبًا إلى جنب،
        // و VStack للعنوان والتاريخ والمحتوى فوق بعضها.
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                // Title / Card Semibold 24 حسب دليل التصميم.
                Text(entry.title)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Color("ColorAccent"))

                // Caption / S Regular 14 حسب دليل التصميم، بلون التواريخ ColorSecondary.
                Text(formattedDate)
                    .font(.system(size: 14))
                    .foregroundStyle(Color("ColorSecondary"))

                // Body / Supporting Light 18 حسب دليل التصميم.
                Text(entry.content)
                    .font(.system(size: 18, weight: .light))
                    .foregroundStyle(Color("ColorText"))
                    .lineLimit(5)
                    .padding(.top, 6)
            }

            Spacer(minLength: 0)

            // زر الإشارة المرجعية: الأيقونة تتبدل بين bookmark و bookmark.fill حسب الحالة.
            Button(action: onToggleBookmark) {
                Image(systemName: entry.isBookmarked ? "bookmark.fill" : "bookmark")
                    .font(.system(size: 24))
                    .foregroundStyle(Color("ColorAccent"))
            }
            // .plain حتى لا يأخذ الزر شكل الأزرار الافتراضي ولا يتداخل مع ضغطة البطاقة داخل List.
            .buttonStyle(.plain)
            .accessibilityLabel(entry.isBookmarked ? "Remove bookmark" : "Add bookmark")
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color("ColorSurface"))
        }
    }
}

#Preview {
    ZStack {
        Color("ColorBackground").ignoresSafeArea()
        VStack(spacing: 12) {
            JournalCardView(
                entry: JournalViewModel.sampleEntries[0],
                formattedDate: "02/09/2024",
                onToggleBookmark: {}
            )
            JournalCardView(
                entry: JournalViewModel.sampleEntries[1],
                formattedDate: "02/09/2024",
                onToggleBookmark: {}
            )
        }
        .padding()
    }
    .preferredColorScheme(.dark)
}
