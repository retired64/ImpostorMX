# GitHub Actions para Flutter

Esta guía te enseñará paso a paso cómo configurar GitHub Actions para compilar automáticamente tu aplicación Flutter y generar APK y AAB firmados listos para distribución.

## Tabla de contenidos

1. [Prerequisitos](https://github.com/retired64/ImpostorMX/blob/main/GUIA_GITHUB_ACTIONS_FLUTTER.md#prerequisitos)
2. [Preparar tu keystore](https://github.com/retired64/ImpostorMX/blob/main/GUIA_GITHUB_ACTIONS_FLUTTER.md#1-preparar-tu-keystore)
3. [Configurar GitHub Secrets](https://github.com/retired64/ImpostorMX/blob/main/GUIA_GITHUB_ACTIONS_FLUTTER.md#2-configurar-github-secrets)
4. [Crear el workflow](https://github.com/retired64/ImpostorMX/blob/main/GUIA_GITHUB_ACTIONS_FLUTTER.md#3-crear-el-workflow)
5. [Verificar la compilación](https://github.com/retired64/ImpostorMX/blob/main/GUIA_GITHUB_ACTIONS_FLUTTER.md#4-verificar-tu-configuraci%C3%B3n-de-buildgradlekts)
6. [Solución de problemas](https://github.com/retired64/ImpostorMX/blob/main/GUIA_GITHUB_ACTIONS_FLUTTER.md#7-soluci%C3%B3n-de-problemas)
7. [Recursos adicionales](https://github.com/retired64/ImpostorMX/blob/main/GUIA_GITHUB_ACTIONS_FLUTTER.md#8-recursos-adicionales)

---

## Prerequisitos

Antes de comenzar, asegúrate de tener:

- ✅ Una cuenta de GitHub
- ✅ Un proyecto Flutter funcionando localmente
- ✅ Un archivo keystore (`.jks` o `.keystore`) para firmar tu app [como tener tu firma para apps flutter](https://docs.flutter.dev/deployment/android#sign-the-app)
- ✅ Acceso a la terminal/consola de tu sistema

---

## 1. Preparar tu keystore

### Paso 1.1: Ubicar tu keystore

Primero, localiza tu archivo keystore. Generalmente está en:
- Linux/Mac: `/home/tu-usuario/keystore.jks`
- Windows: `C:\Users\TuUsuario\keystore.jks`

### Paso 1.2: Convertir keystore a Base64

Necesitas codificar tu keystore en Base64 para subirlo a GitHub de forma segura.

**En Linux/Mac:**
```bash
base64 -w 0 /ruta/a/tu/keystore.jks > keystore_base64.txt
```

**En Windows (PowerShell):**
```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("C:\ruta\a\tu\keystore.jks")) | Out-File keystore_base64.txt
```

**En Windows (Git Bash):**
```bash
base64 -w 0 /c/ruta/a/tu/keystore.jks > keystore_base64.txt
```

Esto creará un archivo `keystore_base64.txt` con tu keystore codificado.

### Paso 1.3: Obtener información del keystore

Necesitarás estos datos de tu archivo `key.properties`:

```properties
storePassword=tu_contraseña_del_store
keyPassword=tu_contraseña_de_la_key
keyAlias=tu_alias
storeFile=/ruta/al/keystore.jks
```

**¡Guarda esta información!** La necesitarás para los GitHub Secrets.

---

## 2. Configurar GitHub Secrets

Los Secrets son variables de entorno encriptadas que GitHub Actions puede usar de forma segura.

### Paso 2.1: Acceder a la configuración de Secrets

1. Ve a tu repositorio en GitHub
2. Click en **Settings** (Configuración)
3. En el menú lateral, busca **Secrets and variables** → **Actions**
4. Click en **New repository secret**

### Paso 2.2: Crear los 4 Secrets necesarios

Crea estos secrets uno por uno:

#### Secret 1: KEYSTORE_BASE64
- **Name:** `KEYSTORE_BASE64`
- **Value:** Pega todo el contenido del archivo `keystore_base64.txt`
- Click en **Add secret**

#### Secret 2: KEYSTORE_PASSWORD
- **Name:** `KEYSTORE_PASSWORD`
- **Value:** La contraseña de tu keystore (el valor de `storePassword`)
- Click en **Add secret**

#### Secret 3: KEY_PASSWORD
- **Name:** `KEY_PASSWORD`
- **Value:** La contraseña de tu key (el valor de `keyPassword`)
- Click en **Add secret**

#### Secret 4: KEY_ALIAS
- **Name:** `KEY_ALIAS`
- **Value:** El alias de tu key (el valor de `keyAlias`)
- Click en **Add secret**

### Verificación

Deberías tener 4 secrets configurados:
- ✓ KEYSTORE_BASE64
- ✓ KEYSTORE_PASSWORD
- ✓ KEY_PASSWORD
- ✓ KEY_ALIAS

---

## 3. Crear el workflow

### Paso 3.1: Crear la estructura de carpetas

En la raíz de tu proyecto Flutter, crea esta estructura:

```
tu-proyecto-flutter/
├── .github/
│   └── workflows/
│       └── build-apk.yml
├── android/
├── lib/
└── pubspec.yaml
```

### Paso 3.2: Crear el archivo de workflow

Crea el archivo `.github/workflows/build-apk.yml` con el siguiente contenido:

```yaml
name: Build Android APK

on:
  # Se ejecuta manualmente desde GitHub
  workflow_dispatch:
  
  # Opcional: también se ejecuta en push a main/master
  # push:
  #   branches: [ main, master ]
  
  # Opcional: también se ejecuta en pull requests
  # pull_request:
  #   branches: [ main, master ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
      # Paso 1: Clonar el repositorio
      - name: Checkout repository
        uses: actions/checkout@v4

      # Paso 2: Configurar Java 17 (requerido por Flutter)
      - name: Set up Java
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'

      # Paso 3: Configurar Flutter
      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.38.7'  # Cambia a tu versión
          channel: 'stable'
          cache: true

      # Paso 4: Decodificar el keystore desde GitHub Secrets
      - name: Decode Keystore
        run: |
          echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 -d > android/app/keystore.jks

      # Paso 5: Crear archivo key.properties
      - name: Create key.properties
        run: |
          cat > android/key.properties << EOF
          storePassword=${{ secrets.KEYSTORE_PASSWORD }}
          keyPassword=${{ secrets.KEY_PASSWORD }}
          keyAlias=${{ secrets.KEY_ALIAS }}
          storeFile=keystore.jks
          EOF

      # Paso 6: Obtener dependencias
      - name: Get dependencies
        run: flutter pub get

      # Paso 7: Ejecutar tests (opcional)
      - name: Run tests
        run: flutter test
        continue-on-error: true

      # Paso 8: Compilar APK
      - name: Build APK
        run: flutter build apk --release

      # Paso 9: Compilar App Bundle (AAB)
      - name: Build App Bundle
        run: flutter build appbundle --release

      # Paso 10: Subir APK como artefacto descargable
      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: app-apk
          path: build/app/outputs/flutter-apk/app-release.apk

      # Paso 11: Subir AAB como artefacto descargable
      - name: Upload App Bundle
        uses: actions/upload-artifact@v4
        with:
          name: app-aab
          path: build/app/outputs/bundle/release/app-release.aab

      # Paso 12: Limpiar archivos sensibles
      - name: Clean up keystore
        if: always()
        run: |
          rm -f android/app/keystore.jks
          rm -f android/key.properties
```

### Paso 3.3: Ajustar la versión de Flutter

En el paso "Set up Flutter", cambia `flutter-version` a la versión que usas localmente.

Para saber tu versión, ejecuta:
```bash
flutter --version
```

Ejemplo de salida:
```
Flutter 3.38.7 • channel stable
```

Usa esa versión en el workflow.

---

## 4. Verificar tu configuración de build.gradle.kts

Asegúrate de que tu archivo `android/app/build.gradle.kts` tenga la configuración de firma:

```kotlin
import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}


android {
    namespace = "com.impostormx.org"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.impostormx.org"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
```

---

## 5. Ejecutar el workflow

### Paso 5.1: Subir cambios a GitHub

```bash
git add .github/workflows/build-apk.yml
git commit -m "Add GitHub Actions workflow for APK/AAB build"
git push origin main
```

### Paso 5.2: Ejecutar manualmente

1. Ve a tu repositorio en GitHub
2. Click en la pestaña **Actions**
3. Selecciona el workflow **"Build Android APK"**
4. Click en **Run workflow**
5. Selecciona la rama (normalmente `main`)
6. Click en **Run workflow** (botón verde)

### Paso 5.3: Monitorear el progreso

- Verás el workflow ejecutándose en tiempo real
- Cada paso mostrará su progreso
- Si algo falla, verás el error específico

### Paso 5.4: Descargar los artefactos

Una vez completado exitosamente:

1. Click en el workflow completado
2. Scroll hasta **Artifacts**
3. Descarga:
   - `app-apk` (tu APK firmado)
   - `app-aab` (tu App Bundle firmado)

---

## 6. Verificar la firma del APK

Para verificar que tu APK está correctamente firmado:

### En Linux/Mac:

```bash
# Instala apksigner si no lo tienes
# En Ubuntu/Debian:
sudo apt-get install apksigner

# Verificar firma
apksigner verify --print-certs app-release.apk
```

### Usando Android SDK:

```bash
# Localiza apksigner en tu Android SDK
~/Android/Sdk/build-tools/[VERSION]/apksigner verify --print-certs app-release.apk
```

**Salida esperada:**
```
Signer #1 certificate DN: CN=Tu Nombre, OU=Tu Org...
Signer #1 certificate SHA-256 digest: ...
Verified using v2 scheme (APK Signature Scheme v2): true
```

---

## 7. Solución de problemas

### Error: "Keystore was tampered with, or password was incorrect"

**Causa:** Las contraseñas en los Secrets no coinciden con las del keystore.

**Solución:**
1. Verifica que `KEYSTORE_PASSWORD` y `KEY_PASSWORD` sean correctas
2. Revisa que no haya espacios extras al copiar las contraseñas
3. Elimina y vuelve a crear los secrets si es necesario

---

### Error: "Flutter version X.X.X not found"

**Causa:** La versión de Flutter especificada no existe.

**Solución:**
1. Verifica tu versión local: `flutter --version`
2. Usa una versión estable existente: `3.24.0`, `3.19.0`, etc.
3. O usa `channel: stable` sin especificar versión para la última

---

### Error: "Could not find the correct Provider"

**Causa:** Los tests por defecto de Flutter no funcionan con tu app.

**Solución:**
Esto es normal. El workflow tiene `continue-on-error: true` en el paso de tests, así que **no afectará la compilación del APK**.

Opcional: Elimina `test/widget_test.dart` o crea tests adecuados para tu app.

---

### Error: "Execution failed for task ':app:signReleaseBundle'"

**Causa:** Problema con la configuración de firma en `build.gradle.kts`.

**Solución:**
1. Verifica que el código de firma esté correctamente configurado
2. Asegúrate de que `key.properties` se esté creando correctamente
3. Revisa que el keystore se esté decodificando en la ruta correcta

---

### El workflow no aparece en Actions

**Causa:** El archivo `.yml` no está en la ubicación correcta.

**Solución:**
1. Verifica que la ruta sea exactamente: `.github/workflows/build-apk.yml`
2. El punto inicial (`.github`) es importante
3. Haz push del archivo a GitHub

---

## 8. Recursos adicionales

### Documentación oficial

- **Flutter Action (GitHub Marketplace):**  
  https://github.com/marketplace/actions/flutter-action
  
- **Documentación de GitHub Actions:**  
  https://docs.github.com/es/actions

- **Documentación de Flutter:**  
  https://docs.flutter.dev/deployment/android

### Opciones avanzadas

#### Activar en push automático

Descomentar en el workflow:
```yaml
on:
  push:
    branches: [ main, master ]
  workflow_dispatch:
```

#### Crear releases automáticos

Agregar paso al final del workflow:
```yaml
- name: Create Release
  uses: softprops/action-gh-release@v1
  if: startsWith(github.ref, 'refs/tags/')
  with:
    files: |
      build/app/outputs/flutter-apk/app-release.apk
      build/app/outputs/bundle/release/app-release.aab
```

#### Usar versión desde pubspec.yaml

```yaml
- name: Set up Flutter
  uses: subosito/flutter-action@v2
  with:
    channel: stable
    flutter-version-file: pubspec.yaml
    cache: true
```

Requiere en `pubspec.yaml`:
```yaml
environment:
  sdk: ">=3.3.0 <4.0.0"
  flutter: 3.19.0  # Versión exacta, sin rangos
```

---

## Checklist final

Antes de ejecutar el workflow, verifica:

- [ ] ✅ Los 4 GitHub Secrets están configurados correctamente
- [ ] ✅ El archivo `.github/workflows/build-apk.yml` está en la ubicación correcta
- [ ] ✅ La versión de Flutter en el workflow coincide con tu versión local
- [ ] ✅ El archivo `build.gradle.kts` tiene la configuración de firma
- [ ] ✅ Has hecho push del workflow a GitHub
- [ ] ✅ El keystore original está seguro (respaldo)

---

## ¡Listo!

Ahora tienes un pipeline de CI/CD completamente funcional que:

✅ Compila automáticamente tu app Flutter  
✅ Genera APK y AAB firmados  
✅ Usa firma digital segura con GitHub Secrets  
✅ Proporciona artefactos descargables  
✅ Se ejecuta con un solo click  

**¡Feliz desarrollo!**

---

## Licencia

Esta guía es de uso libre. Compártela y mejórala.

**Creado con ❤️ para la comunidad Flutter**

---

**Última actualización:** Febrero 2026
