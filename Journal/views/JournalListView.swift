//
//  JournalListView.swift
//  Journal
//

import SwiftUI

/// الشاشة الرئيسية للتطبيق: عنوان "Journal"، أزرار الفلتر والإضافة في الـ toolbar،
/// قائمة اليوميات (أو حالة الفراغ)، شريط البحث، وتنبيه تأكيد الحذف.
/// الواجهة تعرض فقط ما يوجد في الـ ViewModel وتستدعي دواله عند تفاعل المستخدم.
struct JournalListView: View {

    /// الـ ViewModel المشترك. استخدمنا @ObservedObject لأن هذه الواجهة "تراقب" كائنًا
    /// أنشأه غيرها (ContentView) ولا تملكه، فلا يجوز استخدام @StateObject هنا.
    // الهدف: State Management — @ObservedObject لمراقبة كائن ObservableObject مُمرَّر من الأعلى.
    @ObservedObject var viewModel: JournalViewModel

    var body: some View {
        // الهدف: Navigation & Toolbar — NavigationStack يوفر شريط العنوان والـ toolbar وشريط البحث.
        NavigationStack {
            // الهدف: SwiftUI Layout — ZStack للخلفية السوداء وفوقها إما القائمة أو حالة الفراغ.
            ZStack {
                Color("ColorBackground")
                    .ignoresSafeArea()

                // الهدف: User Experience — عرض حالة الفراغ بدلًا من شاشة سوداء عندما لا توجد يوميات.
                if viewModel.isEmpty {
                    EmptyStateView()
                } else {
                    entriesList
                }
            }
            .navigationTitle("Journal")
            .toolbar { toolbarContent }
            // الهدف: Search & Filter — شريط البحث الأصلي مربوط مباشرة بـ searchText في الـ ViewModel.
            .searchable(text: $viewModel.searchText, prompt: "Search")
            // الهدف: Navigation & Toolbar — فتح شاشة الإضافة/التعديل كـ sheet عند تغيّر isEditorPresented.
            .sheet(isPresented: $viewModel.isEditorPresented) {
                JournalEditorView(viewModel: viewModel)
            }
            // الهدف: User Experience / List Interactions — تنبيه أصلي لتأكيد الحذف قبل تنفيذه.
            .alert("Delete Journal?", isPresented: $viewModel.isDeleteAlertPresented) {
                Button("Cancel", role: .cancel) {
                    viewModel.cancelDelete()
                }
                Button("Delete", role: .destructive) {
                    viewModel.confirmDelete()
                }
            } message: {
                Text("Are you sure you want to delete this journal?")
            }
        }
        // لون التفاعل الأساسي حسب دليل التصميم (Primary / Accent).
        .tint(Color("ColorPrimary"))
    }

    // MARK: - قائمة اليوميات

    /// قائمة البطاقات. استخدمنا List (وليس ScrollView) لأن swipe actions لا تعمل إلا داخل List.
    // الهدف: SwiftUI Layout — List لعرض مجموعة من العناصر مع دعم السحب.
    private var entriesList: some View {
        List {
            // رسالة بسيطة عندما لا يطابق البحث أو الفلتر أي يومية.
            if viewModel.displayedEntries.isEmpty {
                Text("No journals found")
                    .font(.system(size: 18, weight: .light))
                    .foregroundStyle(Color("ColorSecondary"))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .padding(.top, 40)
            }

            ForEach(viewModel.displayedEntries) { entry in
                JournalCardView(
                    entry: entry,
                    formattedDate: viewModel.formattedDate(entry.date),
                    onToggleBookmark: { viewModel.toggleBookmark(for: entry) }
                )
                // نجعل كامل مساحة البطاقة قابلة للضغط لفتح شاشة التعديل.
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.presentEditor(for: entry)
                }
                // إخفاء خلفية الصف وفواصله حتى تظهر البطاقات على الخلفية السوداء كما في التصميم.
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                // الهدف: List Interactions — السحب لليسار يُظهر زر الحذف باللون ColorSemantic،
                // ولا ننفّذ الحذف مباشرة بل نطلب من الـ ViewModel عرض تنبيه التأكيد أولًا.
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button {
                        viewModel.requestDelete(entry)
                    } label: {
                        Image(systemName: "trash.fill")
                    }
                    .tint(Color("ColorSemantic"))
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        // الهدف: User Experience — إخفاء الكيبورد تلقائيًا عند التمرير في القائمة أثناء البحث.
        .scrollDismissesKeyboard(.immediately)
    }

    // MARK: - أزرار الـ Toolbar

    /// زر الفلتر (قائمة بخيارين) وزر الإضافة (+) في أعلى يمين الشاشة.
    // الهدف: Navigation & Toolbar — إضافة أزرار إلى الـ toolbar باستخدام ToolbarItem.
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            // الهدف: Search & Filter — قائمة الفلترة بخياري التصميم، والخيار المختار يظهر بجانبه علامة صح.
            Menu {
                ForEach(JournalSortOption.allCases) { option in
                    Button {
                        viewModel.selectSortOption(option)
                    } label: {
                        if viewModel.sortOption == option {
                            Label(option.title, systemImage: "checkmark")
                        } else {
                            Text(option.title)
                        }
                    }
                }
            } label: {
                Image(systemName: "line.3.horizontal.decrease")
                    // عندما يكون هناك فلتر مفعّل نلوّن الأيقونة باللون الأساسي كإشارة بصرية.
                    .foregroundStyle(viewModel.sortOption == nil ? Color("ColorText") : Color("ColorPrimary"))
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button {
                viewModel.presentNewEntry()
            } label: {
                Image(systemName: "plus")
                    .foregroundStyle(Color("ColorText"))
            }
        }
    }
}

#Preview("With entries") {
    JournalListView(viewModel: JournalViewModel(entries: JournalViewModel.sampleEntries))
        .preferredColorScheme(.dark)
}

#Preview("Empty state") {
    JournalListView(viewModel: JournalViewModel())
        .preferredColorScheme(.dark)
}
