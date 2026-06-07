# Impostor MX

<img width="1080" height="505" alt="Impostor MX - El juego de fiesta definitivo" src="https://github.com/user-attachments/assets/f1e78ab6-79df-42ac-9c68-a85320593278" />

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white) ![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white) ![License](https://img.shields.io/badge/License-GPLv3-blue.svg?style=for-the-badge)

## Sobre el Proyecto

Impostor MX es la versión digital del clásico juego de fiesta que todos aman. Reúne a tus amigos, pasen el teléfono y descubran quién está mintiendo en partidas llenas de risas y debates estratégicos.

Este proyecto nació de una simple pregunta: ¿Por qué pagar suscripciones mensuales o soportar anuncios invasivos por un juego tan sencillo? La respuesta fue crear una alternativa completamente gratuita, sin compromisos y de código abierto.

### ¿Qué hace especial a Impostor MX?

- **Sin Anuncios:** Cero interrupciones. Solo diversión pura.
- **100% Gratuito:** No hay compras dentro de la app ni suscripciones ocultas.
- **Totalmente Offline:** Perfecta para viajes, reuniones sin internet o fiestas sin preocuparte por los datos.
- **Código Abierto:** Transparencia total. Puedes revisar cada línea de código y modificarlo a tu gusto.
- **Personalizable:** Crea tus propias categorías temáticas y ajusta las reglas del juego.
- **Ruleta de Castigos:** Una mecánica exclusiva que añade más emoción al final de cada partida.

## Cómo Se Juega

### Paso 1: Elige tu Categoría
Selecciona una categoría temática para la partida. Puedes usar las incluidas o crear tus propias categorías personalizadas desde el menú de Ajustes (⚙️).

### Paso 2: Configura la Partida
Pasa el celular entre todos los jugadores para que cada uno configure su nombre y PIN personal. Una vez completado, define cuántos Impostores habrá en la partida, establece el tiempo de debate y personaliza los castigos de la ruleta si lo deseas.

### Paso 3: Descubre tu Rol
Cada jugador ingresa su PIN de manera privada para revelar su palabra secreta. Todos verán una palabra relacionada con la categoría elegida... excepto el Impostor, quien no verá nada y deberá fingir que sí.

### Paso 4: El Debate
Comienza la discusión. Hagan preguntas estratégicas y describan sus palabras sin ser demasiado obvios. Los civiles intentan identificar al Impostor mientras este trata de pasar desapercibido y deducir cuál es la palabra secreta.

### Paso 5: Votación y Castigo
Cuando el tiempo termine, voten por quien crean que es el Impostor. Si atrapan al impostor, ganan los civiles. Si el Impostor sobrevive, gana él. El perdedor de la partida deberá girar la ruleta de castigos... ¡Que la suerte esté de tu lado!

## Descarga e Instalación

**Opciones de descarga:**

[<img src="docs/badges/fdroid.webp" alt="F-Droid" width="160">](https://f-droid.org/es/packages/com.impostormx.org/)
[<img src="docs/badges/github.webp" alt="github releases" width="160">](https://github.com/Retired64/impostorMX/releases)

Para instalar desde GitHub, simplemente descarga el archivo .APK de la última release e instálalo en tu dispositivo Android.

## Tecnologías Utilizadas

- **Flutter:** Framework multiplataforma para una experiencia fluida
- **Dart:** Lenguaje de programación eficiente y moderno
- **Arquitectura modular:** Código limpio y organizado para facilitar el mantenimiento

# Compilar con GitHub Actions

¿Quieres compilar ImpostorMX Desde el Código fuente, sin instalar nada en tu computadora? ¡Usa GitHub Actions!

## Pasos Rápidos:

1. **Haz Fork** a este repositorio (botón "Fork" arriba a la derecha)
2. Ve a tu fork → pestaña **"Actions"**
3. Selecciona **"Build ImpostorMX Android"** en el panel izquierdo
4. Haz clic en **"Run workflow"** → selecciona branch `main` → **"Run workflow"**
5. Espera 3-5 minutos ⏱️
6. Cuando termine (marca verde), ve a **"Artifacts"** y descarga **"impostormx-android-apk"**
7. Descomprime el ZIP e instala el APK en tu Android 📱

**Platforms disponibles:**
- 🤖 Android (APK + AAB)
- 🍎 iOS (IPA sin firmar)
- 🖥️ Windows
- 🐧 Linux  
- 🍎 macOS

**Los artifacts se guardan por 30 días.** Después puedes volver a compilar cuando quieras.

---

## O Descarga Directo desde Releases

Si solo quieres probar el juego rápido:
- Ve a [Releases](https://github.com/retired64/ImpostorMX/releases) y descarga la última APK

---

## Seguridad

Esta app es 100% segura:
- **Sin internet** - Completamente offline
- **Sin permisos invasivos** - Solo vibración
- **Código abierto** - Revisa tú mismo el código
- **Sin recolección de datos** - Cero tracking

Verifica los permisos: [AndroidManifest.xml](https://github.com/retired64/ImpostorMX/blob/main/android/app/src/main/AndroidManifest.xml)

---

**[Ver Guía Detallada de Compilación](COMPILAR_CON_GITHUB_ACTIONS.md)**

# Instalación iOS

## Descarga

Descarga el archivo `.ipa` desde la sección [Releases](https://github.com/Retired64/impostorMX/releases).

##  Aplicación sin firmar

El archivo IPA no está firmado con un certificado de Apple Developer. Para instalarlo necesitas usar herramientas de sideloading:

### Método 1: Sideloadly (Recomendado)
1. Descarga [Sideloadly](https://sideloadly.io/)
2. Conecta tu iPhone por USB
3. Arrastra el archivo `.ipa` a Sideloadly
4. Ingresa tu Apple ID y haz clic en "Start"
5. En tu iPhone: Ajustes → General → VPN y gestión de dispositivos → Confiar

### Método 2: AltStore
1. Instala [AltStore](https://altstore.io/) en tu PC y iPhone
2. Abre AltStore en tu iPhone
3. Toca "+" y selecciona el archivo `.ipa`

**Nota:** Las apps instaladas así caducan cada 7 días y necesitan renovarse. AltStore puede hacerlo automáticamente por WiFi.

**[Guía detallada de instalación iOS →](INSTALACION_iOS.md)**

---

## Requisitos
- Apple ID gratuito (no necesitas pagar)
- iOS 12.2 o superior
- Cable USB
- Windows 10+ o macOS 10.14.4+


## Contribuir al Proyecto

¡Las contribuciones son más que bienvenidas! Si quieres mejorar Impostor MX, sigue estos pasos:

1. Haz un fork del repositorio
2. Crea una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. Realiza tus cambios y haz commit (`git commit -m 'Agrega nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

El proyecto sigue una estructura modular limpia, así que navegar por el código debería ser intuitivo.

## Apoya el Proyecto

Impostor MX es completamente gratuito y sin anuncios. Si disfrutas el juego y quieres apoyar su desarrollo y publicación en la Play Store, puedes invitarme un café:

[☕ Apóyame en Ko-fi](https://ko-fi.com/impostormx)

Tu apoyo ayuda a mantener el proyecto vivo y a seguir desarrollando nuevas funcionalidades.

## Licencia y Cumplimiento

Este proyecto está bajo [GPLv3](https://www.gnu.org/licenses/gpl-3.0.html)
Esto significa:

**Puedes:**
- Usar el código libremente
- Modificarlo como quieras
- Distribuirlo (gratis o comercialmente)

**DEBES:**
- Publicar tu código fuente si distribuyes versiones modificadas
- Mantener la licencia GPLv3
- Dar crédito al proyecto original

❌ **NO puedes:**
- Crear versiones cerradas sin liberar el código
- Cambiar la licencia a una no-GPL
- Reclamar el código como tuyo sin reconocimiento

**Copyright © 2026 Retired64**

Para más detalles, consulta el archivo [LICENSE](./LICENSE).

**Violaciones de licencia:** Si detectas uso indebido de este código, 
repórtalo, abre un [issue](https://github.com/retired64/ImpostorMX/issues). La comunidad de código abierto
protege estos derechos activamente Discutamos del tema en: [Discusiones de Github](https://github.com/retired64/ImpostorMX/discussions).

---

**Hecho con ❤️ para la comunidad del gaming libre.**

