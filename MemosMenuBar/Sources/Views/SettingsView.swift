import SwiftUI

// MARK: - Settings View (inline in menu bar)

struct SettingsView: View {
    @ObservedObject private var settings = SettingsManager.shared
    @ObservedObject private var localization = LocalizationManager.shared
    @Binding var isPresented: Bool
    @FocusState private var focusedField: SettingsField?
    @State private var newTagText: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("settings.title".localized)
                    .font(.headline)
                Spacer()
                if settings.isConfigured {
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Divider()
            
            // Scrollable content
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    // Server URL
                    VStack(alignment: .leading, spacing: 4) {
                        Text("settings.server.url".localized)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        TextField("settings.server.url.placeholder".localized, text: $settings.serverURL)
                            .textFieldStyle(.roundedBorder)
                            .focused($focusedField, equals: .serverURL)
                    }
                    
                    // Access Token
                    VStack(alignment: .leading, spacing: 4) {
                        Text("settings.access.token".localized)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        SecureField("settings.access.token.placeholder".localized, text: $settings.accessToken)
                            .textFieldStyle(.roundedBorder)
                            .focused($focusedField, equals: .accessToken)
                    }
                    
                    Divider()
                    
                    // Language Selection
                    HStack {
                        Text("settings.language".localized)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Picker("", selection: $localization.currentLanguage) {
                            ForEach(AppLanguage.allCases) { language in
                                Text(language.displayName).tag(language)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                        .frame(width: 100)
                    }
                    
                    Divider()
                    
                    // Tags Section
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle("settings.tags.enabled".localized, isOn: $settings.tagsEnabled)
                            .toggleStyle(.switch)
                            .controlSize(.small)
                        
                        if settings.tagsEnabled {
                            // Mode Selection
                            HStack {
                                Text("settings.tags.mode".localized)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Picker("", selection: Binding(
                                    get: { settings.tagMode },
                                    set: { settings.tagMode = $0 }
                                )) {
                                    ForEach(TagMode.allCases) { mode in
                                        Text(mode.displayName).tag(mode)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .frame(width: 140)
                                .id(localization.currentLanguage) // Force refresh on language change
                            }
                            
                            // Tags
                            VStack(alignment: .leading, spacing: 4) {
                                Text("settings.tags.label".localized)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                
                                // Chips display
                                if !settings.tags.isEmpty {
                                    FlowLayout(spacing: 6) {
                                        ForEach(settings.tags, id: \.self) { tag in
                                            TagChip(tag: tag) {
                                                withAnimation(.easeInOut(duration: 0.2)) {
                                                    settings.tags.removeAll { $0 == tag }
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                // New tag input
                                HStack(spacing: 6) {
                                    TextField("settings.tags.placeholder".localized, text: $newTagText)
                                        .textFieldStyle(.roundedBorder)
                                        .focused($focusedField, equals: .newTag)
                                        .onSubmit {
                                            addTag()
                                        }
                                    
                                    Button {
                                        addTag()
                                    } label: {
                                        Image(systemName: "plus.circle.fill")
                                    }
                                    .buttonStyle(.borderless)
                                    .disabled(newTagText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                                }
                            }
                        }
                    }
                }
            }
            
            // Status indicator
            HStack {
                if settings.isConfigured {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("settings.status.configured".localized)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundStyle(.orange)
                    Text("settings.status.required".localized)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            
            // Done button
            if settings.isConfigured {
                Button {
                    isPresented = false
                } label: {
                    Text("settings.done".localized)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .onAppear {
            focusedField = .serverURL
        }
        .id(localization.currentLanguage) // Force entire view refresh on language change
    }
    
    private func addTag() {
        let trimmed = newTagText.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        guard !trimmed.isEmpty, !settings.tags.contains(trimmed) else {
            newTagText = ""
            return
        }
        withAnimation(.easeInOut(duration: 0.2)) {
            settings.tags.append(trimmed)
        }
        newTagText = ""
    }
}

// MARK: - Settings Field Enum

enum SettingsField {
    case serverURL
    case accessToken
    case newTag
}

// MARK: - Tag Chip Component

struct TagChip: View {
    let tag: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text("#\(tag)")
                .font(.caption)
                .foregroundStyle(.primary)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.accentColor.opacity(0.15))
        .clipShape(Capsule())
    }
}

// MARK: - Flow Layout for Chips

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        for (index, placement) in result.placements.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + placement.x, y: bounds.minY + placement.y), proposal: .unspecified)
        }
    }
    
    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, placements: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var placements: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalHeight: CGFloat = 0
        var totalWidth: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            
            placements.append(CGPoint(x: currentX, y: currentY))
            
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            totalWidth = max(totalWidth, currentX - spacing)
        }
        
        totalHeight = currentY + lineHeight
        
        return (CGSize(width: totalWidth, height: totalHeight), placements)
    }
}
