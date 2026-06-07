# Impostor MX

<div align="center">

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![License: GPLv3](https://img.shields.io/badge/License-GPLv3-blue.svg?style=for-the-badge)](https://www.gnu.org/licenses/gpl-3.0)
[![Release](https://img.shields.io/github/v/release/Retired64/ImpostorMX?style=for-the-badge&label=Última%20versión)](https://github.com/Retired64/ImpostorMX/releases)
[![Descargas](https://img.shields.io/github/downloads/Retired64/ImpostorMX/total?style=for-the-badge&label=Descargas)](https://github.com/Retired64/ImpostorMX/releases)
[![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)](#instalación)

<img width="1080" height="505" alt="Impostor MX — Juego de fiesta offline, libre y gratuito" src="https://github.com/user-attachments/assets/f1e78ab6-79df-42ac-9c68-a85320593278" />

**El juego de fiesta offline definitivo. Sin anuncios, sin internet, 100 % gratuito y open source.**

</div>

---

## Contenido

- [¿Qué es Impostor MX?](#-qué-es-impostor-mx)
- [Cómo se juega](#-cómo-se-juega)
- [Instalación](#-instalación)
  - [Android](#android)
  - [Requisitos del sistema](#requisitos-del-sistema)
- [Desarrollo](#-desarrollo)
  - [Tecnologías y arquitectura](#tecnologías-y-arquitectura)
  - [Compilar desde el código fuente](#compilar-desde-el-código-fuente)
- [Seguridad y privacidad](#-seguridad-y-privacidad)
- [Contribuir](#-contribuir)
- [Comunidad](#-comunidad)
- [Apoyar el proyecto](#-apoyar-el-proyecto)
- [Licencia](#-licencia)

---

## ¿Qué es Impostor MX?

Impostor MX es un **juego de fiesta offline para Android** y la **alternativa open source a los juegos de roles ocultos** — reuní a tus amigos, pasen el teléfono y descubran quién está mintiendo en partidas llenas de risas, deducción y debates estratégicos.

Este proyecto nació de una pregunta simple: *¿por qué pagar suscripciones mensuales o soportar anuncios invasivos por un juego tan sencillo?* La respuesta fue crear una alternativa completamente gratuita, sin compromisos, de código abierto y que no necesita conexión a internet.

### Lo que hace único a Impostor MX

- **Sin anuncios.** Cero interrupciones. Solo diversión.
- **100 % gratuito.** Sin compras dentro de la aplicación ni suscripciones ocultas.
- **Totalmente offline.** Perfecto para viajes, reuniones sin señal o fiestas donde los datos móviles no llegan.
- **Código abierto.** Transparencia total. Revisá, auditá y modificá cada línea de código.
- **Personalizable.** Creá tus propias categorías temáticas y ajustá todas las reglas.
- **Ruleta de castigos.** Una mecánica exclusiva que añade emoción y consecuencias al final de cada partida.
- **Multilingüe.** Disponible en español, inglés, portugués y alemán.
- **Accesible.** Compatible con TalkBack en Android para que nadie se quede fuera.

---

## Cómo se juega

### Paso 1 — Elegí la categoría
Seleccioná una categoría temática para la partida. Podés usar las categorías incluidas o crear las tuyas desde el menú de Ajustes (⚙️).

### Paso 2 — Configurá la partida
Pasá el teléfono entre todos los jugadores para que cada uno configure su nombre y PIN personal. Después definí cuántos impostores habrá, el tiempo límite de debate y personalizá los castigos de la ruleta si querés.

### Paso 3 — Descubrí tu rol
Cada jugador ingresa su PIN en privado para revelar su palabra secreta. Todos ven una palabra relacionada con la categoría… **excepto el impostor**, que no ve nada y debe improvisar.

### Paso 4 — El debate
Comienza la discusión. Hagan preguntas estratégicas y describan sus palabras sin ser demasiado obvios. Los civiles intentan identificar al impostor mientras este trata de pasar desapercibido y deducir cuál es la palabra secreta.

### Paso 5 — Votación y castigo
Cuando el tiempo termine, voten por quién creen que es el impostor. Si lo atrapan, ganan los civiles. Si el impostor sobrevive, gana él. La persona perdedora gira la **ruleta de castigos**. ¡Que la suerte esté de tu lado!

---

## Instalación

### Android

| Fuente | Instrucciones |
|--------|--------------|
| [<img src="docs/badges/fdroid.webp" alt="F-Droid" width="140">](https://f-droid.org/es/packages/com.impostormx.org/) | Instalá desde la tienda libre F-Droid. Actualizaciones automáticas. |
| [<img src="docs/badges/github.webp" alt="GitHub Releases" width="140">](https://github.com/Retired64/impostorMX/releases) | Descargá el APK de la última *release*. Abrí el archivo y aceptá la instalación. |

### Requisitos del sistema

| Requisito | Valor |
|-----------|-------|
| Versión de Android | 7.0 (API 24) o superior |
| Espacio de almacenamiento | ~25 MB |
| Permisos | Solo vibración ([`VIBRATE`](https://github.com/retired64/ImpostorMX/blob/main/android/app/src/main/AndroidManifest.xml#L2)) |

---

## Desarrollo

### Tecnologías y arquitectura

Impostor MX está construido con **Flutter 3.x** y **Dart 3.x**, siguiendo una arquitectura modular con separación clara de responsabilidades.

| Capa | Responsabilidad | Archivos clave |
|------|----------------|----------------|
| `config/` | Constantes, tema visual, helpers responsive | `theme.dart`, `constants.dart` |
| `providers/` | Estado global con Provider | `game_provider.dart`, `language_provider.dart` |
| `screens/` | Pantallas del juego (11 módulos) | `category_screen.dart`, `reveal_screen.dart`, `result_screen.dart` |
| `widgets/` | Componentes reutilizables | `common.dart` (GameCard, GameBackground), `inputs.dart` (BouncyButton) |
| `utils/` | Servicios singleton | `sound_manager.dart` |
| `lang/` | Diccionarios de internacionalización | `es.dart`, `en.dart`, `pt.dart`, `de.dart` |

**Dependencias principales:** `provider ^6.0.5`, `vibration ^3.1.5`, `audioplayers ^6.5.1`, `shared_preferences ^2.5.4`, `flutter_fortune_wheel ^1.3.2`, `confetti ^0.8.0`, `url_launcher ^6.3.2`.


### Compilar desde el código fuente

**Opción A — Compilar en la nube con GitHub Actions (sin instalar nada)**

Hacé un fork del repositorio, ejecutá el workflow *«Build ImpostorMX Android»* desde la pestaña Actions y en 3–5 minutos tendrás tu APK listo para descargar. Guía paso a paso: [COMPILAR_CON_GITHUB_ACTIONS.md](COMPILAR_CON_GITHUB_ACTIONS.md)

**Opción B — Compilación local**

```bash
# Requisitos previos: Flutter SDK 3.10+, Android SDK, Git
git clone https://github.com/Retired64/ImpostorMX.git
cd ImpostorMX
flutter pub get
flutter run                # Modo debug conectado a un dispositivo
flutter build apk --release  # APK de producción
```

---

## Seguridad y privacidad

Impostor MX está diseñado con privacidad desde el primer día. No recolecta, no transmite y no almacena ningún dato fuera de tu dispositivo.

- **Sin conexión a internet.** La aplicación no usa red en absoluto. Cero telemetría, cero analíticas, cero anuncios.
- **Permisos mínimos.** Solo solicita acceso a la vibración del dispositivo ([`VIBRATE`](https://developer.android.com/reference/android/Manifest.permission#VIBRATE)). Sin cámara, sin micrófono, sin contactos, sin ubicación, sin almacenamiento.
- **Código auditable.** Todo el código fuente está disponible públicamente. Podés revisar el [AndroidManifest.xml](android/app/src/main/AndroidManifest.xml) para verificar los permisos solicitados.
- **Sin recolección de datos.** No hay cuentas, no hay inicio de sesión remoto, no hay analíticas de terceros.

---

## Contribuir

Las contribuciones son bienvenidas. Ya sea que quieras reportar un bug, proponer una funcionalidad, traducir a un nuevo idioma o enviar código, este proyecto vive gracias a su comunidad.

**Flujo de contribución:**

1. Hacé un fork del repositorio
2. Creá una rama: `git checkout -b feat/tu-funcionalidad`
3. Realizá tus cambios y confirmá: `git commit -m 'feat: descripción breve'`
4. Subí la rama: `git push origin feat/tu-funcionalidad`
5. Abrí un Pull Request

Guía completa de contribución: [CONTRIBUTING.md](CONTRIBUTING.md)
 ## Contribuidores

<a href="https://github.com/retired64/ImpostorMX/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=retired64/ImpostorMX" />
</a>

---

## 💬 Comunidad

¿Tenés ideas, preguntas o querés conversar sobre el juego? Participá en los [Debates de GitHub](https://github.com/retired64/ImpostorMX/discussions).

---

## Apoyar el proyecto

Impostor MX es y siempre será completamente gratuito. Si disfrutás el juego y querés apoyar su desarrollo, mantenimiento y publicación en tiendas oficiales:

[![Ko-fi](https://img.shields.io/badge/Apoyame_en_Ko--fi-FF5E5B?style=for-the-badge&logo=ko-fi&logoColor=white)](https://ko-fi.com/impostormx)

Tu apoyo ayuda a cubrir los costos de infraestructura y a seguir desarrollando nuevas funcionalidades.

---

## Licencia

Impostor MX es software libre bajo la [Licencia Pública General GNU v3.0](https://www.gnu.org/licenses/gpl-3.0.html) (GPLv3).

Esto significa:

- ✅ **Puedes** usar, estudiar, modificar y distribuir el código libremente, incluso con fines comerciales.
- ✅ **Debes** publicar el código fuente si distribuís versiones modificadas, mantener la misma licencia GPLv3 y dar crédito al proyecto original.
- ❌ **No pueds** crear versiones de código cerrado sin liberar el fuente, cambiar la licencia a una no compatible con GPL, ni reclamar la autoría del código sin reconocimiento.

El texto completo de la licencia está disponible en el archivo [LICENSE](LICENSE).

**Copyright © 2026 Retired64**

---

<div align="center">

**Impostor MX — Software libre para la comunidad gamer.**

</div>