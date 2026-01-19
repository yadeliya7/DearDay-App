# Image Assets Placeholder

Bu klasör, uygulamada kullanılacak arka plan görsellerini içerir.

## Gerekli Görsel Yapısı

### Ruh Hali Arka Planları
Her ruh hali kategorisi için 1 adet atmosferik görsel:

- `sad_mood.webp` - Yağmurlu/hüzünlü bir sahne
- `happy_mood.webp` - Güneşli/neşeli bir sahne
- `nostalgic_mood.webp` - Autumn/eski zamanlar hissiyatı
- `dreamy_mood.webp` - Gece/rüya gibi sahne
- `hopeful_mood.webp` - Sunrise/umut dolu sahne
- `peaceful_mood.webp` - Deniz/sakin sahne

### Görsel Özellikleri

- **Format**: WebP (en iyi sıkıştırma)
- **Çözünürlük**: Minimum 1080x1920px (Full HD)
- **Dosya boyutu**: Her bir görsel 300KB-500KB arası
- **Duygulandırıcı**: Soyut, minimal atmosferik görseller

## Placeholder Görselleri

Eğer henüz gerçek görseller yoksa, uygulamada kullanılan gradient'ler (açık renkli) otomatik olarak arka plan olarak gösterilecektir.

## Kurulum Adımları

1. Ruh hali arka plan görsellerini indirin veya tasarlayın
2. WebP formatına dönüştürün
3. `assets/images/` klasörüne kopyalayın
4. Dosya adlarını yukarıdaki gibi adlandırın
5. `pubspec.yaml`'da assets listesi zaten yapılandırılmıştır

**Not**: Görsel dosyaları olmasa bile, uygulama gradient renklerle çalışacaktır.
