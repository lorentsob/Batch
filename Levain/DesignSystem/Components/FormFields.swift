import SwiftUI
import UIKit

/// Labeled text row for forms. The whole row is tappable and moves focus to
/// the field, so the user does not have to aim at the trailing text area.
struct FormTextRow: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var autofocus: Bool = false
    var capitalization: TextInputAutocapitalization = .sentences
    var keyboard: UIKeyboardType = .default
    var fieldAccessibilityIdentifier: String?

    @FocusState private var isFocused: Bool

    var body: some View {
        LabeledContent(title) {
            field
        }
        .contentShape(Rectangle())
        .onTapGesture { isFocused = true }
        .task {
            guard autofocus else { return }
            // Wait for the sheet presentation to settle before raising the keyboard.
            try? await Task.sleep(for: .milliseconds(450))
            isFocused = true
        }
    }

    @ViewBuilder
    private var field: some View {
        let base = TextField(placeholder, text: $text)
            .multilineTextAlignment(.trailing)
            .keyboardType(keyboard)
            .textInputAutocapitalization(capitalization)
            .submitLabel(.done)
            .focused($isFocused)

        if let fieldAccessibilityIdentifier {
            base.accessibilityIdentifier(fieldAccessibilityIdentifier)
        } else {
            base
        }
    }
}

/// Labeled numeric row for forms: decimal keypad, whole-row tap target and
/// the current value selected on focus so typing replaces it.
struct NumericField: View {
    let title: String
    @Binding var value: Double

    @FocusState private var isFocused: Bool

    var body: some View {
        LabeledContent(title) {
            TextField("0", value: $value, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .focused($isFocused)
                .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { notification in
                    guard isFocused, let field = notification.object as? UITextField else { return }
                    Task { @MainActor in
                        field.selectAll(nil)
                    }
                }
        }
        .contentShape(Rectangle())
        .onTapGesture { isFocused = true }
    }
}

extension View {
    /// Adds a "Fine" button above the keyboard (decimal pads have no return key)
    /// and lets the user dismiss the keyboard by scrolling the form.
    func formKeyboardToolbar() -> some View {
        scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Fine") {
                        UIApplication.shared.sendAction(
                            #selector(UIResponder.resignFirstResponder),
                            to: nil,
                            from: nil,
                            for: nil
                        )
                    }
                    .fontWeight(.semibold)
                }
            }
    }

    /// Makes the full row (including the empty space created by `Spacer`)
    /// respond to taps in plain-styled buttons.
    func formRowHitArea() -> some View {
        frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
    }
}

/// Plain button style whose whole label frame is tappable, including the empty
/// space created by `Spacer`. Use it for full-width rows instead of `.plain`.
struct FullRowPlainButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(Rectangle())
            .opacity(configuration.isPressed ? 0.55 : 1)
    }
}
