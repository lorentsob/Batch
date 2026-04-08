import SwiftUI
import UIKit

struct KnowledgeView: View {
    @ObservedObject var library: KnowledgeLibrary
    @Binding var query: String

    @State private var selectedCategory: KnowledgeCategory? = nil
    @State private var isSearchFocused = false
    @State private var lastScrollOffset: CGFloat = 0

    private var filteredItems: [KnowledgeItem] {
        library.searchResults(matching: query, in: selectedCategory)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Layout.sectionGap) {
                GeometryReader { proxy in
                    Color.clear
                        .preference(
                            key: KnowledgeScrollOffsetKey.self,
                            value: proxy.frame(in: .named("KnowledgeScrollView")).minY
                        )
                }
                .frame(height: 0)

                SectionCard(emphasis: .tinted) {
                    ScreenTitleBlock(
                        title: "Guide",
                        subtitle: "Tutto sulla fermentazione"
                    )
                    StateBadge(text: "\(filteredItems.count) risultati", tone: .count)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        KnowledgeCategoryPillView(title: "Tutti", isSelected: selectedCategory == nil) {
                            selectedCategory = nil
                        }
                        ForEach(KnowledgeCategory.allCases) { category in
                            KnowledgeCategoryPillView(title: category.title, isSelected: selectedCategory == category) {
                                selectedCategory = category
                            }
                        }
                    }
                }

                VStack(spacing: 12) {
                    if filteredItems.isEmpty {
                        EmptyStateView(
                            title: "Nessun risultato",
                            message: "Prova a modificare la ricerca o rimuovere il filtro per categoria.",
                            actionTitle: "Mostra tutte le guide"
                        ) {
                            query = ""
                            selectedCategory = nil
                        }
                        .padding(.top, 40)
                    } else {
                        ForEach(filteredItems) { item in
                            NavigationLink(value: KnowledgeRoute.article(item.id)) {
                                KnowledgeRowView(item: item)
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("KnowledgeArticleRow-\(item.id)")
                        }
                    }
                }
            }
            .contentShape(Rectangle())
            .levainScrollScreenPadding()
            .simultaneousGesture(TapGesture().onEnded {
                dismissSearchIfNeeded()
            })
        }
        .coordinateSpace(name: "KnowledgeScrollView")
        .scrollDismissesKeyboard(.immediately)
        .simultaneousGesture(TapGesture().onEnded {
            dismissSearchIfNeeded()
        })
        .simultaneousGesture(
            DragGesture(minimumDistance: 8).onChanged { _ in
                dismissSearchIfNeeded()
            }
        )
        .background(Theme.Surface.app.ignoresSafeArea())
        .navigationTitle("")
        .tint(Theme.Control.primaryFill)
        .safeAreaInset(edge: .bottom, spacing: Theme.Spacing.xs) {
            GuideSearchField(
                text: $query,
                isFocused: $isSearchFocused,
                placeholder: "Cerca guide e consigli"
            )
                .frame(height: 44)
                .padding(.horizontal, Theme.Layout.screenHorizontalInset)
                .padding(.bottom, Theme.Spacing.sm)
        }
        .accessibilityIdentifier("KnowledgeScrollView")
        .onPreferenceChange(KnowledgeScrollOffsetKey.self) { newOffset in
            let delta = abs(newOffset - lastScrollOffset)
            lastScrollOffset = newOffset
            guard delta > 6 else { return }
            dismissSearchIfNeeded()
        }
        .task {
            library.loadIfNeeded()
        }
    }

    private func dismissSearchIfNeeded() {
        isSearchFocused = false
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview("Knowledge") {
    NavigationStack {
        KnowledgeView(library: KnowledgeLibrary(), query: .constant(""))
    }
}

private struct KnowledgeScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private struct GuideSearchField: UIViewRepresentable {
    @Binding var text: String
    @Binding var isFocused: Bool
    let placeholder: String

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, isFocused: $isFocused)
    }

    func makeUIView(context: Context) -> UISearchTextField {
        let searchField = UISearchTextField(frame: .zero)
        searchField.delegate = context.coordinator
        searchField.placeholder = placeholder
        searchField.returnKeyType = .search
        searchField.enablesReturnKeyAutomatically = false
        searchField.autocapitalizationType = .none
        searchField.autocorrectionType = .default
        searchField.clearButtonMode = .whileEditing
        searchField.borderStyle = .roundedRect
        searchField.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.96)
        searchField.accessibilityIdentifier = "KnowledgeBottomSearchField"
        searchField.text = text
        searchField.addTarget(context.coordinator, action: #selector(Coordinator.textDidChange(_:)), for: .editingChanged)
        return searchField
    }

    func updateUIView(_ searchField: UISearchTextField, context: Context) {
        if searchField.text != text {
            searchField.text = text
        }

        let isFirstResponder = searchField.isFirstResponder
        if isFocused && isFirstResponder == false {
            DispatchQueue.main.async {
                guard searchField.window != nil else { return }
                searchField.becomeFirstResponder()
            }
        } else if isFocused == false && isFirstResponder {
            DispatchQueue.main.async {
                searchField.resignFirstResponder()
            }
        }
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        @Binding private var text: String
        @Binding private var isFocused: Bool

        init(text: Binding<String>, isFocused: Binding<Bool>) {
            _text = text
            _isFocused = isFocused
        }

        func textFieldDidBeginEditing(_ textField: UITextField) {
            isFocused = true
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            isFocused = false
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            isFocused = false
            textField.resignFirstResponder()
            return true
        }

        @objc func textDidChange(_ sender: UISearchTextField) {
            text = sender.text ?? ""
        }
    }

    static func dismantleUIView(_ searchField: UISearchTextField, coordinator: Coordinator) {
        searchField.delegate = nil
        searchField.removeTarget(coordinator, action: #selector(Coordinator.textDidChange(_:)), for: .editingChanged)
    }
}
