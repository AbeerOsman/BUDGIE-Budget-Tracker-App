//
//  WesternDigitTextField.swift
//  BUDGIE
//
//  UITextField wrapper so Arabic digits convert to 0–9 while typing (not only on blur).
//

import SwiftUI
import UIKit

/// Numeric field that shows Western digits immediately when the user types Arabic numerals.
struct WesternDigitField: View {
    let placeholder: LocalizedStringKey
    @Binding var text: String
    let kind: BudgieNumericInput.FieldKind

    private var rowHeight: CGFloat {
        ceil(UIFont.preferredFont(forTextStyle: .body).lineHeight)
    }

    var body: some View {
        ZStack(alignment: .leading) {
            WesternDigitTextFieldRepresentable(text: $text, kind: kind)
                .frame(height: rowHeight)

            if text.isEmpty {
                Text(placeholder)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .allowsHitTesting(false)
            }
        }
        .frame(maxWidth: .infinity, minHeight: rowHeight, maxHeight: rowHeight, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
    }
}

private struct WesternDigitTextFieldRepresentable: UIViewRepresentable {
    @Binding var text: String
    let kind: BudgieNumericInput.FieldKind

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, kind: kind)
    }

    func makeUIView(context: Context) -> UITextField {
        let field = UITextField()
        field.delegate = context.coordinator
        field.keyboardType = BudgieNumericInput.keyboardType(for: kind)
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.text = text
        field.font = UIFont.preferredFont(forTextStyle: .body)
        field.textColor = .label
        field.borderStyle = .none
        field.backgroundColor = .clear
        field.setContentHuggingPriority(.required, for: .vertical)
        field.setContentCompressionResistancePriority(.required, for: .vertical)
        context.coordinator.textField = field
        return field
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        context.coordinator.kind = kind
        uiView.keyboardType = BudgieNumericInput.keyboardType(for: kind)

        guard !uiView.isFirstResponder else { return }
        if uiView.text != text {
            uiView.text = text
        }
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UITextField, context: Context) -> CGSize? {
        let width = proposal.replacingUnspecifiedDimensions().width
        let height = ceil(UIFont.preferredFont(forTextStyle: .body).lineHeight)
        return CGSize(width: width, height: height)
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        var kind: BudgieNumericInput.FieldKind
        weak var textField: UITextField?

        init(text: Binding<String>, kind: BudgieNumericInput.FieldKind) {
            _text = text
            self.kind = kind
        }

        func textField(
            _ textField: UITextField,
            shouldChangeCharactersIn range: NSRange,
            replacementString string: String
        ) -> Bool {
            let current = textField.text ?? ""
            guard let textRange = Range(range, in: current) else { return false }

            let proposed = current.replacingCharacters(in: textRange, with: string)
            let western = BudgieNumericInput.displayText(for: proposed, kind: kind)

            textField.text = western
            text = western
            return false
        }
    }
}
