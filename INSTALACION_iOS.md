# Instalación en iOS (iPhone/iPad)

## Importante: Aplicación sin firmar

El archivo `.ipa` proporcionado **NO está firmado** con un certificado de Apple Developer, por lo que no se puede instalar directamente desde Safari o iTunes. Sin embargo, puedes instalarlo usando herramientas de "sideloading" con tu Apple ID gratuito.

---

## Métodos de instalación

### Opción 1: Sideloadly (Recomendado) ⭐

**Compatible con:** Windows y macOS

1. **Descarga Sideloadly:** https://sideloadly.io/
2. **Conecta tu iPhone/iPad** a tu computadora por USB
3. **Abre Sideloadly** y arrastra el archivo `.ipa`
4. **Ingresa tu Apple ID** cuando te lo solicite
5. **Haz clic en "Start"** y espera a que se instale
6. En tu iPhone: **Ajustes → General → VPN y gestión de dispositivos → Confiar en tu desarrollador**

### Opción 2: AltStore

**Compatible con:** Windows y macOS

1. **Descarga e instala AltServer:** https://altstore.io/
2. **Instala AltStore en tu dispositivo:**
   - Ejecuta AltServer en tu PC
   - Conecta tu iPhone/iPad por USB
   - En la bandeja del sistema, click en AltServer → Install AltStore → [tu dispositivo]
   - Ingresa tu Apple ID
3. **Instala la aplicación:**
   - Abre **AltStore** en tu iPhone/iPad
   - Toca el icono **"+"** en la esquina superior
   - Selecciona el archivo `.ipa` (puedes transferirlo por AirDrop, Files, etc.)
   - Espera a que se instale

### Opción 3: iOS App Signer + Xcode (Solo macOS)

Si tienes una Mac:

1. **Descarga iOS App Signer:** https://dantheman827.github.io/ios-app-signer/
2. **Abre Xcode** y agrega tu Apple ID en Preferences → Accounts
3. **En iOS App Signer:**
   - Selecciona el archivo `.ipa`
   - Elige tu certificado de desarrollo
   - Firma la aplicación
4. **Instala con Xcode:**
   - Xcode → Window → Devices and Simulators
   - Conecta tu iPhone/iPad
   - Arrastra el IPA firmado a tu dispositivo

---

## Renovación automática (7 días)

Las aplicaciones instaladas con Apple ID gratuito **caducan cada 7 días**. Para mantenerla funcionando:

### Con AltStore:
- Asegúrate de que **AltServer** esté ejecutándose en tu PC
- Mantén tu iPhone/iPad en la **misma red WiFi** que tu PC
- AltStore **renovará automáticamente** la aplicación antes de que caduque

### Con Sideloadly:
- Necesitas **reconectar** tu dispositivo cada 7 días
- Vuelve a instalar usando Sideloadly
- Tus datos de la app se mantendrán intactos

---

## Requisitos

- ✅ Apple ID gratuito (no necesitas pagar $99/año)
- ✅ iPhone/iPad con iOS 12.2 o superior
- ✅ Cable USB para conectar a tu computadora
- ✅ Windows 10/11 o macOS 10.14.4+

---

## ❓ Preguntas frecuentes

### ¿Es seguro usar mi Apple ID?
Sí, **Sideloadly** y **AltStore** son herramientas de código abierto ampliamente usadas por la comunidad. Solo utilizan tu Apple ID para generar certificados de desarrollo legítimos de Apple. **Nunca compartas tu contraseña con otras personas.**

### ¿Por qué caduca cada 7 días?
Apple limita los certificados de desarrollo gratuitos a 7 días. Si pagas $99/año por Apple Developer Program, los certificados duran 1 año.

### ¿Puedo instalar la app sin computadora?
No directamente. Necesitas una computadora (Windows o Mac) al menos para la instalación inicial. Con AltStore, las renovaciones pueden ser automáticas por WiFi.

### ¿Mis datos se borran al renovar?
No, al renovar la firma solo se actualiza el certificado. Tus datos, partidas guardadas y configuraciones se mantienen intactos.

### ¿Funciona en iPad?
Sí, el proceso es idéntico para iPhone y iPad.

### ¿Puedo tener múltiples apps instaladas así?
Sí, pero con Apple ID gratuito el límite es **3 aplicaciones simultáneas**.

---

## Solución de problemas

### "No se puede verificar la aplicación"
- Ve a **Ajustes → General → VPN y gestión de dispositivos**
- Toca tu Apple ID y selecciona **"Confiar"**

### "No se pudo instalar la aplicación"
- Verifica que tu Apple ID no tenga autenticación de dos factores bloqueando el proceso
- Genera una **contraseña específica para apps** en appleid.apple.com si usas 2FA
- Asegúrate de tener espacio suficiente en tu dispositivo

### "El certificado ha caducado"
- Reinstala la aplicación usando Sideloadly o AltStore
- Para evitarlo, configura renovación automática con AltStore

---

## Recursos adicionales

- **Sideloadly:** https://sideloadly.io/
- **AltStore:** https://altstore.io/
- **iOS App Signer:** https://dantheman827.github.io/ios-app-signer/
- **Guía completa de AltStore:** https://faq.altstore.io/

---

## Nota para desarrolladores

Si deseas distribuir esta aplicación de forma oficial en el App Store, necesitarás:
- Cuenta de Apple Developer ($99/año)
- Firmar la aplicación con certificados de distribución
- Cumplir con las políticas de revisión de Apple y mantener el codigo GPLv3 de este proyecto.

Para desarrollo y testing personal, los métodos anteriores son completamente legítimos y están dentro de los términos de uso de Apple.

---

**¿Tienes problemas?** Abre un issue en este repositorio describiendo el error que experimentas.
