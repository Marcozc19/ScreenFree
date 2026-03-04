import Foundation

// MARK: - Demo Mode Configuration
// Set to false and uncomment Supabase imports when ready to use real backend

enum SupabaseConfig {
    static let useDemoMode = true

    // TODO: Replace with actual Supabase credentials when ready
    static let url = "https://YOUR_PROJECT_ID.supabase.co"
    static let anonKey = "YOUR_ANON_KEY"
}

// Placeholder for Supabase client - not used in demo mode
// When ready to use Supabase:
// 1. Add supabase-swift package to project
// 2. import Supabase
// 3. Set useDemoMode = false
