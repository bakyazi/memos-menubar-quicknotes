import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: MemoViewModel
    @Binding var showSettings: Bool
    @ObservedObject private var settings = SettingsManager.shared
    @ObservedObject private var localization = LocalizationManager.shared
    @FocusState private var isEditorFocused: Bool
    
    var body: some View {
        Group {
            if showSettings || !settings.isConfigured {
                SettingsView(isPresented: $showSettings)
            } else {
                editorView
            }
        }
    }
    
    private var editorView: some View {
        VStack(spacing: 12) {
            // Header with success indicator
            HStack {
                Text("content.title".localized)
                    .font(.headline)
                
                Spacer()
                
                if viewModel.showSuccess {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.showSuccess)
            
            // Text Editor with placeholder
            ZStack(alignment: .topLeading) {
                TextEditor(text: $viewModel.memoContent)
                    .font(.system(.body, design: .monospaced))
                    .scrollContentBackground(.hidden)
                    .focused($isEditorFocused)
                    .onSubmit {
                        // Command + Enter handling is done via keyboardShortcut
                    }
                
                if viewModel.memoContent.isEmpty {
                    Text("content.placeholder".localized)
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(.tertiary)
                        .padding(.top, 1)
                        .padding(.leading, 6)
                        .allowsHitTesting(false)
                }
            }
            .padding(8)
            .background(Color(nsColor: .textBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
            )
            
            // Error message
            if let errorMessage = viewModel.errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                    Spacer()
                    Button {
                        viewModel.clearError()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.red.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            
            // Action buttons
            HStack {
                // Settings button
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gear")
                }
                .buttonStyle(.borderless)
                .help("content.settings.tooltip".localized)
                
                Spacer()
                
                // Keyboard shortcut hint
                Text("content.send.shortcut".localized)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                
                // Send button
                Button {
                    Task {
                        await viewModel.sendMemo()
                    }
                } label: {
                    HStack(spacing: 4) {
                        if viewModel.isLoading {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Image(systemName: "paperplane.fill")
                        }
                        Text("content.send".localized)
                    }
                    .frame(minWidth: 80)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.canSend)
                .keyboardShortcut(.return, modifiers: .command)
            }
        }
        .padding()
        .onAppear {
            isEditorFocused = true
        }
        .id(localization.currentLanguage) // Force view refresh on language change
    }
}
