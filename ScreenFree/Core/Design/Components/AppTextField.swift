import SwiftUI

struct AppTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var errorMessage: String? = nil
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil
    var autocapitalization: TextInputAutocapitalization = .sentences

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .textContentType(textContentType)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboardType)
                        .textContentType(textContentType)
                        .textInputAutocapitalization(autocapitalization)
                }
            }
            .font(.system(size: Theme.Typography.base))
            .foregroundColor(Theme.Colors.foreground)
            .padding(.horizontal, Theme.Spacing.md)
            .frame(height: Theme.Sizes.inputHeight)
            .background(Theme.Colors.inputBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.lg)
                    .stroke(
                        errorMessage != nil ? Theme.Colors.destructive :
                            (isFocused ? Theme.Colors.primary : Color.clear),
                        lineWidth: 1.5
                    )
            )
            .focused($isFocused)

            if let error = errorMessage {
                Text(error)
                    .font(.system(size: Theme.Typography.sm))
                    .foregroundColor(Theme.Colors.destructive)
            }
        }
    }
}

// MARK: - Labeled TextField

struct LabeledTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var errorMessage: String? = nil
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil
    var autocapitalization: TextInputAutocapitalization = .sentences

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text(label)
                .font(.system(size: Theme.Typography.sm, weight: Theme.Typography.medium))
                .foregroundColor(Theme.Colors.foreground)

            AppTextField(
                placeholder: placeholder,
                text: $text,
                isSecure: isSecure,
                errorMessage: errorMessage,
                keyboardType: keyboardType,
                textContentType: textContentType,
                autocapitalization: autocapitalization
            )
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Theme.Spacing.lg) {
        AppTextField(placeholder: "Enter email", text: .constant(""))
        AppTextField(placeholder: "Enter password", text: .constant(""), isSecure: true)
        AppTextField(
            placeholder: "With error",
            text: .constant("test"),
            errorMessage: "This field is required"
        )
        LabeledTextField(
            label: "Email",
            placeholder: "Enter your email",
            text: .constant("")
        )
    }
    .padding()
}
