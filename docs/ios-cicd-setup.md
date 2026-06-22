# iOS CI/CD sozlash qo'llanmasi (Fastlane Match + GitHub Actions)

Bu qo'llanma `ketamiz` ilovasini iOS uchun avtomatik build qilib **TestFlight**ga
yuklashni sozlaydi. Imzolash uchun **Fastlane Match** ishlatiladi.

Loyiha ma'lumotlari:
- Bundle ID: `uz.ketamiz.app`
- Apple Team ID: `2N8JD58W7U`
- Build muhiti: GitHub Actions `macos-latest` runner

> ⚠️ **Tartib muhim:** iOS ilovasi hali App Store'ga chiqarilmagan. Birinchi
> TestFlight build'ini **qo'lda** yuklash tavsiya etiladi (App Store Connect'da
> metadata to'ldirilishi va Apple'ning dastlabki tekshiruvi uchun). Match setup'i
> ham qo'lda, ham CI yuklashda ishlatiladi.

---

## 0. Oldindan kerak bo'ladigan narsalar

- Apple Developer Program a'zoligi (yillik $99) — Team `2N8JD58W7U`
- App Store Connect'da `uz.ketamiz.app` ilovasi yaratilgan bo'lishi
- Match sertifikatlarini saqlash uchun **alohida private git repo**
  (masalan `AbbosbekBotirjonovich/ketamiz-ios-certs`)

---

## 1. Fastlane'ni lokalda o'rnatish

Loyiha ildizida `Gemfile` orqali o'rnatamiz (versiya barqarorligi uchun):

```bash
# ios/ papkasida ishlaymiz
cd ios

# Gemfile yaratiladi (pastdagi 2-bo'limda mazmuni berilgan), keyin:
bundle install
```

`fastlane` to'g'ridan-to'g'ri ham o'rnatsa bo'ladi, lekin Gemfile usuli CI bilan
bir xil versiyani kafolatlaydi.

---

## 2. Fastlane fayllari

`ios/` ichida quyidagi fayllar bo'ladi (skript ularni yaratadi):

- `ios/Gemfile` — fastlane versiyasi
- `ios/fastlane/Appfile` — bundle id, Apple ID, team
- `ios/fastlane/Fastfile` — build/upload lane'lari
- `ios/fastlane/Matchfile` — Match sozlamalari

(Mazmuni quyida "Fayllar" bo'limida.)

---

## 3. App Store Connect API Key yaratish

CI'da Apple ID + parol o'rniga API kalit ishlatiladi (2FA muammosini yo'q qiladi).

1. https://appstoreconnect.apple.com → **Users and Access → Integrations → App Store Connect API**
2. **"Generate API Key"** (yoki "+") → nom: `github-ci`, Access: **App Manager**
3. Yaratilgach yuklab oling: `AuthKey_XXXXXXXXXX.p8` (**faqat bir marta yuklanadi!**)
4. Eslab qoling:
   - **Key ID** (masalan `XXXXXXXXXX`)
   - **Issuer ID** (sahifaning tepasida, UUID ko'rinishida)

---

## 4. Fastlane Match'ni birinchi marta ishga tushirish (lokalda)

Match sertifikat va profillarni shifrlab private repo'ga joylaydi.

```bash
cd ios

# Match init — certs repo URL'ini so'raydi
bundle exec fastlane match init

# AppStore turidagi sertifikat + profil yaratish va repo'ga yuklash
bundle exec fastlane match appstore
```

- Match sizdan **parol** so'raydi (`MATCH_PASSWORD`) — shifrlash uchun. Eslab qoling.
- Bu sertifikat/profilni certs repo'siga shifrlangan holda push qiladi.

---

## 5. GitHub Secrets (iOS uchun)

Repo: `AbbosbekBotirjonovich/ketamiz-mobile`
→ Settings → Secrets and variables → Actions

| Secret nomi | Qiymati |
|-------------|---------|
| `MATCH_PASSWORD` | Match shifrlash paroli (4-qadamdan) |
| `MATCH_GIT_URL` | `git@github.com:AbbosbekBotirjonovich/ketamiz-ios-certs.git` (CI uchun standart github.com host) |
| `MATCH_SSH_PRIVATE_KEY` | Certs repo'ga read-only deploy key'ning PRIVATE qismi (BEGIN…END to'liq) |
| `APP_STORE_CONNECT_KEY_ID` | API Key ID (3-qadam) |
| `APP_STORE_CONNECT_ISSUER_ID` | API Issuer ID (3-qadam) |
| `APP_STORE_CONNECT_KEY_P8` | `.p8` faylning to'liq matni |

> **Certs repo'ga CI kirishi — SSH deploy key:**
> 1. Lokalda kalit juftligi yaratiladi (`ssh-keygen -t ed25519`).
> 2. PUBLIC qismi certs repo → Settings → Deploy keys → "Add deploy key"
>    (read-only, "Allow write access" BELGILANMAYDI).
> 3. PRIVATE qismi `MATCH_SSH_PRIVATE_KEY` secret bo'ladi.
> 4. Workflow `webfactory/ssh-agent` action bilan kalitni runner'ga yuklaydi.

---

## 6. GitHub Actions workflow

`.github/workflows/ios-release.yml` (skript yaratadi). `v*` tag push'da:
1. macOS runner'da Flutter + CocoaPods o'rnatadi
2. Match orqali sertifikat/profilni tiklaydi
3. `flutter build ipa` (imzolangan)
4. App Store Connect API bilan TestFlight'ga yuklaydi

---

## Eslatmalar

- **macOS runner qimmatroq:** public repo'da bepul, lekin Linux'dan ~10x daqiqa
  hisoblanadi. Private bo'lsa, byudjetga e'tibor bering.
- **Build raqami:** iOS'da ham har yuklamada `versionCode` (build number) oshishi
  kerak. `pubspec.yaml`dagi `+N` qism iOS build raqamiga ham aylanadi.
- **Birinchi TestFlight build qo'lda:** App Store Connect to'liq sozlangach,
  CI silliq ishlaydi.
