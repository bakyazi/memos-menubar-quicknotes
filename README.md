# Memos Menu Bar - macOS Quick Notes Client

macOS Menu Bar'da çalışan minimalist bir [Memos](https://github.com/usememos/memos) istemcisi.

## Özellikler

- 📝 Menu Bar'dan hızlı not ekleme
- ⌨️ `Command + Enter` ile hızlı gönderme
- 🔒 Bearer Token ile güvenli kimlik doğrulama
- 🎨 Monospace font ile Markdown desteği
- 🚀 Dock ikonu yok - sadece Menu Bar

## Gereksinimler

- macOS 13.0+ (Ventura)
- Swift 5.9+
- Xcode 15+

## Kurulum

1. Xcode'da `Package.swift` dosyasını açın:
   ```bash
   cd MemosMenuBar
   open Package.swift
   ```

2. Xcode'da scheme'i seçin ve `Product > Run` (⌘R) ile çalıştırın.

## Kullanım

1. İlk çalıştırmada Ayarlar ekranı açılır
2. Memos sunucu URL'inizi girin (örn: `https://memos.example.com`)
3. Access Token'ınızı girin
4. "Tamam" butonuna tıklayın

Artık Menu Bar'daki not ikonuna tıklayarak hızlıca not ekleyebilirsiniz!

## Proje Yapısı

```
MemosMenuBar/
├── Package.swift
└── Sources/
    ├── MemosMenuBarApp.swift    # App entry point
    ├── Info.plist               # App configuration
    ├── Models/
    │   ├── Memo.swift           # Data models
    │   └── MemoError.swift      # Error types
    ├── Views/
    │   ├── ContentView.swift    # Main editor view
    │   └── SettingsView.swift   # Settings form
    ├── ViewModels/
    │   └── MemoViewModel.swift  # State management
    └── Services/
        ├── MemoService.swift    # API client
        └── SettingsManager.swift # Settings persistence
```

## Mimari

Uygulama MVVM (Model-View-ViewModel) mimarisini kullanır:

- **Model**: Veri yapıları ve hata tipleri
- **View**: SwiftUI görünümleri
- **ViewModel**: İş mantığı ve state yönetimi
- **Service**: API iletişimi ve ayar yönetimi

## Lisans

MIT
