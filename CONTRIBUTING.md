# Guía de Contribución — Impostor MX

Gracias por tu interés en contribuir a Impostor MX. Este documento explica cómo podés ayudar, reportar problemas y enviar código.

---

## Código de conducta

Este proyecto se rige por el respeto mutuo. Tratá a los demás colaboradores con cortesía. No se tolerará acoso, lenguaje ofensivo ni comentarios despectivos.

---

## Cómo contribuir

Hay muchas formas de aportar sin necesidad de escribir código:

- **Reportar bugs**: si encontrás un error, abrí un [issue](https://github.com/Retired64/ImpostorMX/issues) describiendo el problema, los pasos para reproducirlo, tu dispositivo y versión de Android.
- **Sugerir funcionalidades**: abrí un issue con la etiqueta `enhancement` explicando qué te gustaría ver y por qué.
- **Traducir**: si hablás un idioma que no está soportado, podés crear un archivo de diccionario en `lib/lang/` siguiendo el formato de los existentes.
- **Mejorar la documentación**: corregí erratas, mejorá guías, añadí ejemplos.

---

## Flujo de trabajo para código

### 1. Configurá tu entorno

**Requisitos:**
- Flutter SDK 3.10 o superior ([guía de instalación](https://docs.flutter.dev/get-started/install))
- Android Studio o las herramientas de línea de comandos de Android
- Git

```bash
git clone https://github.com/Retired64/ImpostorMX.git
cd ImpostorMX
flutter pub get
flutter analyze    # Confirmá que no hay errores
```

### 2. Elegí una tarea

Revisá los [issues abiertos](https://github.com/Retired64/ImpostorMX/issues) etiquetados como `good first issue` o `help wanted`. Si vas a trabajar en algo, comentá en el issue para evitar duplicar esfuerzo.

### 3. Creá una rama

```bash
git checkout -b feat/descripcion-breve   # Para funcionalidades
git checkout -b fix/descripcion-breve    # Para correcciones
git checkout -b docs/descripcion-breve   # Para documentación
```

### 4. Escribí tu código

- Lenguaje: Dart (variables, métodos y clases en inglés). Comentarios y mensajes de commit en español.
- Formato: el proyecto sigue las reglas de `flutter_lints ^6.0.0`. Ejecutá `flutter analyze` antes de commitear.
- Estado: usá Provider para el estado global. No agregues `setState` innecesario.
- Offline: no agregues dependencias de red (`http`, `dio`, analíticas).
- Accesibilidad: los elementos interactivos nuevos deben incluir `Semantics` para TalkBack.
- Diseño responsive: usá helpers de `MediaQuery`, no valores fijos.
- Licencia: los archivos nuevos deben incluir el header GPLv3 (ver `lib/main.dart` como referencia).

Leé la guía detallada con estándares de código, convenciones de commits y arquitectura en [AGENTS.md](AGENTS.md).

### 5. Probá tus cambios

```bash
flutter analyze                # Sin errores
flutter test                   # Si hay tests
flutter build apk --debug      # Construí el APK y probalo en un dispositivo
```

### 6. Hacé commit

Seguí el formato de commits del proyecto:

```
tipo(alcance): descripción breve en español

- Cambio específico 1
- Cambio específico 2
```

Tipos de commit: `feat`, `fix`, `refactor`, `perf`, `style`, `docs`, `test`, `android`, `a11y`, `i18n`.

Ejemplo:
```
a11y(reveal): agregar Semantics en pantalla de revelación

- Botón "Mostrar palabra" ahora tiene label para TalkBack
- Tarjeta de rol con descripción de accesibilidad
```

### 7. Abrí un Pull Request

Subí tu rama y abrí un PR contra `main`. Describí qué cambia, por qué y cómo probarlo.

---

## Estructura del proyecto

```
lib/
├── main.dart                    # Entry point, providers, rutas
├── config/
│   ├── constants.dart           # Claves SharedPreferences, flags
│   └── theme.dart               # AppColors, AppTheme, fuentes
├── providers/
│   ├── game_provider.dart       # Estado global del juego
│   └── language_provider.dart   # Internacionalización
├── screens/                     # 11 pantallas del juego
│   ├── category_screen.dart
│   ├── player_setup_screen.dart
│   ├── config_screen.dart
│   ├── login_screen.dart
│   ├── reveal_screen.dart
│   ├── timer_screen.dart
│   ├── voting_screen.dart
│   ├── result_screen.dart
│   ├── punishments_screen.dart
│   └── create_category_screen.dart
├── widgets/
│   ├── common.dart              # GameBackground, GameCard, GameNavBar
│   └── inputs.dart              # BouncyButton, MinimalInput
├── utils/
│   └── sound_manager.dart       # Singleton de audio
└── lang/                        # Diccionarios ES, EN, PT, DE
```

---

## Reportar problemas de seguridad

Si encontrás una vulnerabilidad de seguridad, **no la reportes en un issue público**. Escribí a los mantenedores del proyecto.

---

## Reconocimiento

Todas las contribuciones significativas se reconocen en el historial de commits y en la página de colaboradores del repositorio.

---

*Impostor MX — Software libre bajo GPLv3.*
