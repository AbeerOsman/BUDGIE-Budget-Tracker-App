//
//  AddCategorySheet.swift
//  BUDGIE
//

import SwiftUI

struct AddCategorySheet: View {
    var categoryIndex: Int = 0
    var recommendedDailyLimit: Int = 50
    var onSave: (CategoryCardItem) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var title = ""
    @State private var emoji = ""
    @State private var categoryType: CategoryType = .spending
    @State private var budget = ""
    @State private var dailySpending = ""

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canSave: Bool {
        let base = !trimmedTitle.isEmpty && !emoji.isEmpty && !budget.isEmpty
        if categoryType == .spending {
            return base && !dailySpending.isEmpty
        }
        return base
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    primaryFieldsSection
                    typeSection
                    budgetSection

                    if categoryType == .spending {
                        dailySpendingSection

                        Text("Recommended spending limit: $ \(recommendedDailyLimit)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .background(Color(.systemBackground))
            .navigationTitle("Add Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
             
                ToolbarItem(placement: .topBarTrailing) {
                    CircleNavButton(systemImage: "checkmark") {
                        saveCategory()
                    }
                    .opacity(canSave ? 1 : 0.4)
                    .disabled(!canSave)
                }
            }
        }
        .presentationDragIndicator(.visible)
    }

    private var primaryFieldsSection: some View {
        formSection {
            CategoryFormRow(placeholder: "Title", text: $title, fieldKind: .title)

            formDivider

            EmojiFormRow(emoji: $emoji)
        }
    }

    private var typeSection: some View {
        formSection {
            Text("Type")
                .font(.body)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)

            formDivider

            CategoryTypeRadioRow(
                title: CategoryType.spending.displayName,
                isSelected: categoryType == .spending
            ) {
                categoryType = .spending
            }

            CategoryTypeRadioRow(
                title: CategoryType.fixed.displayName,
                isSelected: categoryType == .fixed
            ) {
                categoryType = .fixed
            }
        }
    }

    private var budgetSection: some View {
        formSection {
            CategoryFormRow(
                placeholder: "Budget",
                text: $budget,
                fieldKind: .integer,
                showsCurrency: true
            )
        }
    }

    private var dailySpendingSection: some View {
        formSection {
            CategoryFormRow(
                placeholder: "Maximum daily spending",
                text: $dailySpending,
                fieldKind: .integer,
                showsCurrency: true
            )
        }
    }

    private func formSection<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .background(formSectionBackground)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    /// On sheets, grouped background is often white-on-white in light mode — use gray6 for contrast.
    private var formSectionBackground: Color {
        colorScheme == .dark
            ? Color(.secondarySystemGroupedBackground)
            : Color(.systemGray6)
    }

    private var formDivider: some View {
        Divider()
            .overlay(Color(.separator))
            .padding(.leading, 16)
    }

    private func saveCategory() {
        guard canSave else { return }

        let item = CategoryCardItem(
            emoji: emoji.isEmpty ? "📁" : emoji,
            name: trimmedTitle,
            type: categoryType,
            spent: 0,
            budget: parsedInteger(budget),
            color: CategoryCardItem.color(forIndex: categoryIndex)
        )

        onSave(item)
        dismiss()
    }

    private func parsedInteger(_ text: String) -> Double {
        Double(Int(text.filter(\.isNumber)) ?? 0)
    }
}

// MARK: - Input sanitization

private enum FormFieldKind {
    case title
    case integer
}

private enum FormInput {
    static func sanitize(_ input: String, for kind: FormFieldKind) -> String {
        switch kind {
        case .title:
            return titleText(from: input)
        case .integer:
            return digitsOnly(from: input)
        }
    }

    /// Letters, spaces, and common name punctuation only.
    static func titleText(from input: String) -> String {
        let allowedPunctuation: Set<Character> = ["-", "'", "&"]
        return input.filter { character in
            character.isLetter
                || character.isWhitespace
                || allowedPunctuation.contains(character)
        }
    }

    static func digitsOnly(from input: String) -> String {
        input.filter(\.isNumber)
    }
}

// MARK: - Emoji field

private struct EmojiFormRow: View {
    @Binding var emoji: String

    var body: some View {
        HStack(spacing: 12) {
            TextField("Emoji", text: $emoji)
                .foregroundStyle(.primary)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .onChange(of: emoji) { _, newValue in
                    let sanitized = EmojiInput.singleEmoji(from: newValue)
                    if sanitized != newValue {
                        emoji = sanitized
                    }
                }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

private enum EmojiInput {
    /// Keeps at most one emoji grapheme; strips letters, numbers, and symbols.
    static func singleEmoji(from input: String) -> String {
        for character in input.reversed() {
            if character.isEmojiCharacter {
                return String(character)
            }
        }
        return ""
    }
}

private extension Character {
    var isEmojiCharacter: Bool {
        unicodeScalars.contains { $0.properties.isEmoji }
    }
}

// MARK: - Type radio row

private struct CategoryTypeRadioRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.body)
                    .foregroundStyle(.primary)

                Spacer()

                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? Color("Sky Blue") : .secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Form row

private struct CategoryFormRow: View {
    let placeholder: String
    @Binding var text: String
    var fieldKind: FormFieldKind = .title
    var showsCurrency: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            TextField(placeholder, text: $text)
                .keyboardType(fieldKind == .integer ? .numberPad : .default)
                .foregroundStyle(.primary)
                .textInputAutocapitalization(fieldKind == .title ? .words : .never)
                .autocorrectionDisabled(fieldKind == .integer)
                .onChange(of: text) { _, newValue in
                    let sanitized = FormInput.sanitize(newValue, for: fieldKind)
                    if sanitized != newValue {
                        text = sanitized
                    }
                }

            if showsCurrency {
                Text("$")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

// MARK: - Previews

#Preview {
    AddCategorySheet { _ in }
}
