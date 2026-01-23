# DearDay - DearDay

Bir premium Flutter uygulaması - "Museum Aesthetic" tasarım felsefesi ile geliştirilmiş, şiirlerin duygusal derinliğini ve görsel zenginliğini bir araya getiren bir şiir günlüğü uygulaması.

## 🎨 Tasarım Felsefesi

### Sessiz Lüks (Quiet Luxury)
- **Renk Paleti**: Gözü yormayan, sofistike renkler
- **Tipografi**: Serif (Playfair Display) ve Sans-Serif (Montserrat) kombinasyonu
- **Boşluk**: Minimal ve zarif düzen
- **Ayrıntılar**: Museum-quality shadows ve glassmorphism efektleri

## 📱 Ekranlar

### 1. Ana Ekran (Home Screen)
- **İmmersif Kart Görünümü**: Tam ekranı kaplayan, kenarları oval dev kart
- **Atmosferik Arka Planlar**: Her şiir için ruh haline uygun gradyen
- **Etkileşim**: Ekrana dokunulduğunda UI butonları belirir (Fade in)
- **Navigasyon**: Swiping ile şiirler arasında geçiş

### 2. Tasarım Editörü
- **Renk Paleti Seçici**: Arka plan rengini değiştir
- **Yazı Tipi Seçimi**: Şiir tipografisini özelleştir
- **Canlı Önizleme**: Değişiklikler anında görüntülenir

### 3. Ruh Hali Keşfi (Mood Discovery)
- **Ruh Hali Kategorileri**: Hüzün, Neşe, Nostaljik, Düşlemeci, Umut, Sakinlik
- **Pinterest Tarzı Kartlar**: Dikey dikdörtgen şekilde ruh hali kartları
- **Mikro Animasyonlar**: Hero animation ile sayfalar arası geçiş

## 🎯 Premium UX Özellikleri

### Animasyonlar
- Smooth fade-in/fade-out efektleri (600-800ms)
- Glassmorphism backdrop filters
- Scale & transform animasyonlar

### Haptik Geri Bildirim
- Şiir beğenme zamanı hafif titreşim
- Arka plan değiştirme sırasında haptic feedback

### Tasarım Detayları
- Museum-quality shadows (çoklu katman gölgeler)
- Border radius: 20px (premiumRadius) ve 12px (subtleRadius)
- Altın vurgu rengi (#D4AF37) - Sessiz lüks için

## 🛠️ Teknoloji Stack

- **Framework**: Flutter 3.10+
- **State Management**: Provider
- **Typography**: Google Fonts (Playfair Display, Montserrat)
- **Animasyonlar**: Flutter animations, custom transitions
- **UI Efektleri**: Glassmorphism, custom shadows
- **Haptik**: Vibration plugin

## 📦 Proje Yapısı

```
lib/
├── core/
│   ├── theme.dart          # Dark & Light theme tanımları
│   ├── providers.dart      # State management (Theme, Poem, Mood)
│   └── premium_effects.dart# Shadow, animasyon, gradient definisyonları
├── models/
│   └── poem_model.dart     # Poem ve MoodCategory modelleri
├── screens/
│   ├── home_screen.dart    # Ana ekran
│   └── mood_discovery_screen.dart # Ruh hali keşfi ekranı
├── widgets/
│   └── premium_poem_card.dart # İmmersif şiir kartı
└── main.dart               # App entry point
```

## 🚀 Başlangıç

### Gereksinimler
- Flutter SDK 3.10+
- Android SDK veya Xcode (iOS için)
- VS Code veya Android Studio

### Kurulum

1. Bağımlılıkları yükle:
```bash
flutter pub get
```

2. Uygulamayı çalıştır:
```bash
flutter run
```

## 🎨 Renk Paleti

### Karanlık Mod (Dark Mode - Varsayılan)
- **Zemin**: Koyu Kömür (#121212)
- **Metin**: Kırık Beyaz (#E0E0E0)
- **Vurgu**: Soluk Altın (#D4AF37)
- **İkincil Vurgu**: Bakır (#B87333)

### Işık Mod (Light Mode)
- **Zemin**: Eski Kağıt (#FAF9F6)
- **Metin**: Koyu Kahve (#2C1810)
- **Vurgu**: Altın Sarısı (#D4AF37)

## 📝 Şiir Ekleme

1. Ana ekranda "Yeni Şiir" butonuna tıkla
2. Şiir başlığı, metni ve yazar adını gir
3. "Ekle" butonuna basarak kaydet

## 🌙 Tema Değiştirme

Sağ üst köşedeki güneş/ay ikonuna basarak koyu ve açık mod arasında geçiş yapabilirsiniz.

## 🔍 Keşfet

Explore ikonuna basarak ruh hali kategorilerine göre şiirler keşfedin.

---

**Tasarım**: Museum Aesthetic - Sessiz lüks ve minimal tasarım felsefesi
