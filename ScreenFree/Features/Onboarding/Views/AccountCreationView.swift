import SwiftUI

struct AccountCreationView: View {
    @Environment(AppState.self) private var appState

    @State private var email = ""
    @State private var password = ""
    @State private var displayName = ""
    @State private var selectedAgeRange: AgeRange = .age25to34

    @State private var emailError: String?
    @State private var passwordError: String?
    @State private var displayNameError: String?

    @State private var isLoading = false
    @State private var showSignIn = false

    @FocusState private var focusedField: Field?

    enum Field {
        case email, password, displayName
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.xl) {
                // Header
                VStack(spacing: Theme.Spacing.sm) {
                    Text("Create your account")
                        .font(.system(size: Theme.Typography.xxl, weight: Theme.Typography.bold))
                        .foregroundColor(Theme.Colors.foreground)

                    Text("Start your journey to mindful phone use")
                        .font(.system(size: Theme.Typography.base))
                        .foregroundColor(Theme.Colors.mutedForeground)
                }
                .padding(.top, Theme.Spacing.xl)

                // Form
                VStack(spacing: Theme.Spacing.md) {
                    // Email
                    LabeledTextField(
                        label: "Email",
                        placeholder: "you@example.com",
                        text: $email,
                        errorMessage: emailError,
                        keyboardType: .emailAddress,
                        textContentType: .emailAddress,
                        autocapitalization: .never
                    )
                    .focused($focusedField, equals: .email)
                    .onChange(of: email) { _, _ in
                        emailError = nil
                    }

                    // Password
                    LabeledTextField(
                        label: "Password",
                        placeholder: "At least 8 characters",
                        text: $password,
                        isSecure: true,
                        errorMessage: passwordError,
                        textContentType: .newPassword
                    )
                    .focused($focusedField, equals: .password)
                    .onChange(of: password) { _, _ in
                        passwordError = nil
                    }

                    // Display Name
                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                        LabeledTextField(
                            label: "Display Name",
                            placeholder: "2-20 characters (letters, numbers, _)",
                            text: $displayName,
                            errorMessage: displayNameError,
                            autocapitalization: .never
                        )
                        .focused($focusedField, equals: .displayName)
                        .onChange(of: displayName) { _, _ in
                            displayNameError = nil
                        }
                    }

                    // Age Range
                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                        Text("Age Range")
                            .font(.system(size: Theme.Typography.sm, weight: Theme.Typography.medium))
                            .foregroundColor(Theme.Colors.foreground)

                        AgeRangePicker(selection: $selectedAgeRange)
                    }
                }

                // Sign Up Button
                PrimaryButton(
                    title: "Create Account",
                    action: signUp,
                    isLoading: isLoading,
                    isDisabled: !isFormValid
                )

                // Sign In Link
                HStack(spacing: Theme.Spacing.xxs) {
                    Text("Already have an account?")
                        .font(.system(size: Theme.Typography.sm))
                        .foregroundColor(Theme.Colors.mutedForeground)

                    Button("Sign in") {
                        showSignIn = true
                    }
                    .font(.system(size: Theme.Typography.sm, weight: Theme.Typography.medium))
                    .foregroundColor(Theme.Colors.primary)
                }

                Spacer(minLength: Theme.Spacing.xxl)
            }
            .padding(.horizontal, Theme.Spacing.lg)
        }
        .background(Theme.Colors.background)
        .sheet(isPresented: $showSignIn) {
            SignInSheet(isPresented: $showSignIn)
        }
    }

    // MARK: - Validation

    private var isFormValid: Bool {
        !email.isEmpty &&
        password.count >= 8 &&
        UserProfile.validateDisplayName(displayName)
    }

    private func validate() -> Bool {
        var isValid = true

        if email.isEmpty {
            emailError = "Email is required"
            isValid = false
        } else if !isValidEmail(email) {
            emailError = "Please enter a valid email"
            isValid = false
        }

        if password.isEmpty {
            passwordError = "Password is required"
            isValid = false
        } else if password.count < 8 {
            passwordError = "Password must be at least 8 characters"
            isValid = false
        }

        if displayName.isEmpty {
            displayNameError = "Display name is required"
            isValid = false
        } else if !UserProfile.validateDisplayName(displayName) {
            displayNameError = "2-20 characters: letters, numbers, underscore only"
            isValid = false
        }

        return isValid
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    // MARK: - Sign Up

    private func signUp() {
        focusedField = nil
        guard validate() else { return }

        isLoading = true

        Task {
            do {
                // Create auth user
                let user = try await AuthService.shared.signUp(email: email, password: password)

                // Create profile
                let profile = try await DatabaseService.shared.createProfile(
                    userId: user.id,
                    displayName: displayName,
                    ageRange: selectedAgeRange
                )

                // Update app state
                appState.setAuthenticated(user: user, profile: profile)
                appState.advanceOnboarding()

                isLoading = false
            } catch {
                isLoading = false
                appState.setError(error.localizedDescription)
            }
        }
    }
}

// MARK: - Age Range Picker

struct AgeRangePicker: View {
    @Binding var selection: AgeRange

    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            ForEach(AgeRange.allCases) { range in
                AgeRangeButton(
                    title: range.displayName,
                    isSelected: selection == range
                ) {
                    selection = range
                }
            }
        }
    }
}

struct AgeRangeButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: Theme.Typography.sm, weight: Theme.Typography.medium))
                .foregroundColor(isSelected ? .white : Theme.Colors.foreground)
                .padding(.horizontal, Theme.Spacing.sm)
                .padding(.vertical, Theme.Spacing.xs)
                .background(isSelected ? Theme.Colors.primary : Theme.Colors.inputBackground)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
        }
    }
}

// MARK: - Sign In Sheet

struct SignInSheet: View {
    @Environment(AppState.self) private var appState
    @Binding var isPresented: Bool

    @State private var email = ""
    @State private var password = ""
    @State private var emailError: String?
    @State private var passwordError: String?
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            VStack(spacing: Theme.Spacing.xl) {
                // Header
                VStack(spacing: Theme.Spacing.sm) {
                    Text("Welcome back")
                        .font(.system(size: Theme.Typography.xxl, weight: Theme.Typography.bold))
                        .foregroundColor(Theme.Colors.foreground)

                    Text("Sign in to continue your journey")
                        .font(.system(size: Theme.Typography.base))
                        .foregroundColor(Theme.Colors.mutedForeground)
                }
                .padding(.top, Theme.Spacing.xl)

                // Form
                VStack(spacing: Theme.Spacing.md) {
                    LabeledTextField(
                        label: "Email",
                        placeholder: "you@example.com",
                        text: $email,
                        errorMessage: emailError,
                        keyboardType: .emailAddress,
                        textContentType: .emailAddress,
                        autocapitalization: .never
                    )

                    LabeledTextField(
                        label: "Password",
                        placeholder: "Enter your password",
                        text: $password,
                        isSecure: true,
                        errorMessage: passwordError,
                        textContentType: .password
                    )
                }

                PrimaryButton(
                    title: "Sign In",
                    action: signIn,
                    isLoading: isLoading,
                    isDisabled: email.isEmpty || password.isEmpty
                )

                Spacer()
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .background(Theme.Colors.background)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }

    private func signIn() {
        isLoading = true

        Task {
            do {
                let user = try await AuthService.shared.signIn(email: email, password: password)

                if let profile = try await DatabaseService.shared.getProfile(userId: user.id) {
                    appState.setAuthenticated(user: user, profile: profile)

                    if profile.onboardingCompleted {
                        appState.completeOnboarding()
                    } else {
                        appState.advanceOnboarding()
                    }
                }

                isPresented = false
                isLoading = false
            } catch {
                isLoading = false
                let errorMessage = error.localizedDescription.lowercased()
                // Show error on appropriate field based on error message
                if errorMessage.contains("password") {
                    passwordError = error.localizedDescription
                } else {
                    // Default to email field for user/email errors
                    emailError = error.localizedDescription
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    AccountCreationView()
        .environment(AppState())
}
