# ⚡ Hızlı Başlangıç

## 1 Dakikada Başlangıç

### Adım 1: Hazırla
```bash
cd C:\Users\Yadeliya\Desktop\Projelerim\poem_diary\poem_diary
flutter pub get
```

### Adım 2: Çalıştır
```bash
flutter run
```

### Adım 3: Keşfet
- Şiirleri okumak için ekrana dokunun
- Sağa/sola kaydırarak diğer şiirleri görün
- Tema değiştirmek için ☀️/🌙 ikonuna tıklayın

---

## 🎯 Başlıca Özellikler

| Özellik | Konum | Açıklama |
|---------|-------|----------|
| **Tema Değişikliği** | Sağ üst | Koyu/Açık mod toggle |
| **Keşfet** | Sağ üst | Ruh hali kategorilerine göz at |
| **Yeni Şiir** | Alt buton | Şiir ekleme dialogu |
| **Tasarım** | Ekranı tap → Palet | Arka plan rengi değiştir |
| **Favori** | Ekranı tap → ❤️ | Şiiri favorilere ekle |

---

## 📱 Ekrandan İlk Görüntü

```
┌─────────────────────────────────┐
│ [☰] [🔍] [🌙]                  │  Header
├─────────────────────────────────┤
│                                 │
│   Sana gitme demeyeceğim.       │  Full-screen
│   Üşüyorsun ceketimi al.        │  Poem Card
│   Günün en güzel saatleri       │  with Gradient
│   bunlar. Yanımda kal.          │  Background
│                                 │
│   - Özdemir Asaf                │
│                                 │
├─────────────────────────────────┤
│ [+ Yeni Şiir] [♥ Favorilerim]  │  Bottom Actions
└─────────────────────────────────┘
```

---

## 🔧 Hata Giderme

**Problem**: Emülatör bulunamıyor
```bash
flutter emulators
flutter emulators --launch emulator-5554
```

**Problem**: "Dependency issue"
```bash
flutter clean
flutter pub get
```

**Problem**: Hot Reload çalışmıyor
- Yapılandırma dosyasını değiştirdiysen → `r` tuşu (Restart)
- Kodları değiştirdiysen → `r` tuşu (Reload) yeterli

---

## 📚 Daha Fazla Bilgi

- **Kurulum**: `SETUP_GUIDE.md`
- **Tasarım**: `README.md`
- **Tamamlama Raporu**: `PROJECT_COMPLETION_REPORT.md`

---

**Başarılar!** 🎭✨
