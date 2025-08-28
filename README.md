# 📱 Calculadora Paso a Paso

> Una **app educativa** que muestra **cómo se resuelven las operaciones básicas** (suma, resta, multiplicación y división) **paso a paso**, con animaciones claras y diseño simple.

![platforms](https://img.shields.io/badge/platforms-Android%20%7C%20iOS-informational)
![flutter](https://img.shields.io/badge/Flutter-stable-blue)
![license](https://img.shields.io/badge/license-MIT-green)

---

## ✨ Características

- ✅ **Operaciones básicas**: suma, resta, multiplicación, división.
- 🎬 **Animaciones paso a paso** para visualizar el procedimiento (ej. multiplicación larga dígito a dígito).
- 📴 **Funciona sin conexión** (100% offline).
- 🖼️ **Splash screen** y **app icon** configurados.
- 🎨 Paleta limpia y amigable (**#2A7A7B** como color principal).

> Nombre de la app en tienda: **Calculadora Paso a Paso**

---

## 🧰 Tecnologías y paquetes

- **Flutter** (Dart)
- Paquetes:
  - [`flutter_native_splash`](https://pub.dev/packages/flutter_native_splash) – genera splash screen para Android/iOS.
  - [`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons) – genera íconos de app multi‑tamaño.

---

## 🗂️ Estructura del proyecto (resumen)

```
lib/
 ├─ main.dart
 ├─ app/
 │   ├─ theme/
 │   ├─ routes/
 │   └─ widgets/
 ├─ features/
 │   ├─ calculator/
 │   │   ├─ presentation/   # páginas, widgets, animaciones
 │   │   ├─ domain/         # entidades y lógica
 │   │   └─ data/           # fuentes de datos (si aplica)
 assets/
 ├─ icon.png
 ├─ splash_logo.png
 └─ brand.png (opcional)
```

---

## 🚀 Empezar

### Requisitos

- Flutter instalado (canal _stable_).
- Android Studio / Xcode (para emuladores o compilación).

### Instalación y ejecución

```bash
# 1) Obtener dependencias
flutter pub get

# 2) Correr en dispositivo/emulador
flutter run

# 3) (opcional) Generar splash e íconos si cambiaste assets
dart run flutter_native_splash:create
dart run flutter_launcher_icons:main
```

---

## ⚙️ Configuración

### 1) Nombre, descripción y versión

`pubspec.yaml`

```yaml
name: calculadora_paso_a_paso
description: Calculadora educativa paso a paso con animaciones
version: 1.0.0+1
```

### 2) App icon

`pubspec.yaml`

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_icons:
  android: true
  ios: true
  image_path: "assets/icon.png"
```

```bash
dart run flutter_launcher_icons:main
```

### 3) Splash screen

`pubspec.yaml`

```yaml
dev_dependencies:
  flutter_native_splash: ^2.4.0

flutter_native_splash:
  color: "#2A7A7B"
  image: assets/splash_logo.png
  branding: assets/brand.png # opcional
  android_12:
    color: "#2A7A7B"
    image: assets/splash_logo.png
```

```bash
dart run flutter_native_splash:create
```

### 4) Identificadores de app

- **Android**: `android/app/build.gradle` → `applicationId "com.jovannyrch.step_by_step_calculator"`
- **iOS**: en Xcode → _Signing & Capabilities_ → `Bundle Identifier`

> Cambia también el **label** visible en Android: `android/app/src/main/res/values/strings.xml` (`app_name`).

---

## 🏗️ Builds de producción

### Android (App Bundle para Play Store)

```bash
flutter build appbundle --release
# Archivo: build/app/outputs/bundle/release/app-release.aab
```

### iOS (IPA para App Store)

```bash
flutter build ipa --release
# O abre ios/Runner.xcworkspace en Xcode y usa Product > Archive
```

---

## 🔐 Privacidad

La app **no recopila datos personales** y funciona sin conexión. Consulta la **[Política de Privacidad](https://jovannyrch.github.io/politicas/calculadora_paso_a_paso.html)** para más detalles.

---

## 🧭 Roadmap

- [ ] Historial de operaciones recientes
- [ ] Modo práctica con ejercicios aleatorios
- [ ] Exportar paso a paso a imagen/PDF
- [ ] Localización EN/ES
- [ ] Accesibilidad (lectores de pantalla, contraste aumentado)

---

## 🤝 Contribuir

1. Haz un fork y crea una rama: `feat/mi-mejora`
2. Asegúrate de seguir el estilo de código (Dart `flutter format`)
3. Abre un PR describiendo cambios y capturas si aplica

---

## 🧪 Troubleshooting

- **No sale el splash nuevo** → `flutter clean` y vuelve a generar: `dart run flutter_native_splash:create`.
- **Ícono borroso** → usa un PNG base de **1024×1024**.
- **Android 12 ignora mi imagen** → completa la sección `android_12` en `flutter_native_splash`.
- **Error de firma Android** → configura `android/key.properties` y `signingConfigs` en `build.gradle`.
- **Xcode no archiva** → revisa `Bundle Identifier`, _Team_ y certificados.

---

## 📄 Licencia

Distribuido bajo licencia **MIT**. Consulta `LICENSE` para más información.

---

## 🙌 Créditos

Hecha con ❤️ usando **Flutter**.  
Nombre de la app: **Calculadora Paso a Paso**.
