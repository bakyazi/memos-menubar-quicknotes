import Foundation
import SwiftUI

@MainActor
class MemoViewModel: ObservableObject {
    @Published var memoContent: String = ""
    @Published var isLoading: Bool = false
    @Published var showSuccess: Bool = false
    @Published var errorMessage: String?
    
    private let memoService = MemoService.shared
    
    var canSend: Bool {
        !memoContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isLoading
    }
    
    func sendMemo() async {
        guard canSend else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Apply tags to content if enabled
            let finalContent = SettingsManager.shared.applyTags(to: memoContent)
            try await memoService.createMemo(content: finalContent)
            
            // Success
            memoContent = ""
            showSuccess = true
            
            // Hide success indicator after 2 seconds
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            showSuccess = false
            
        } catch let error as MemoError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func clearError() {
        errorMessage = nil
    }
}
