#!/bin/bash

# 1. Extraer la versión limpia del pubspec.yaml (ej. 2.1.0)
# Busca la línea 'version:', toma el valor y corta lo que está antes del '+'
VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}' | cut -d '+' -f 1)

echo "Versión detectada: $VERSION"

# Ruta donde están las APKs
APK_DIR="build/app/outputs/flutter-apk"

# 2. Verificar que la carpeta existe
if [ ! -d "$APK_DIR" ]; then
  echo "Error: No se encontró el directorio $APK_DIR"
  exit 1
fi

echo "Renombrando archivos..."

# 3. Recorrer las APKs y renombrarlas
for file in "$APK_DIR"/app-*-release.apk; do
  # Ignorar si el glob falla y no hay archivos
  [ -e "$file" ] || continue

  # Extraer el nombre original (ej. app-arm64-v8a-release.apk)
  filename=$(basename "$file")

  # Extraer solo la arquitectura quitando 'app-' y '-release.apk'
  arch=${filename#app-}
  arch=${arch%-release.apk}

  # Construir el nuevo nombre
  new_name="impostorMX-${VERSION}-${arch}.apk"

  # Renombrar el APK
  mv "$file" "$APK_DIR/$new_name"
  echo "$filename  ->  $new_name"

  # Si existe el archivo de firma (.sha1), renombrarlo también
  if [ -f "${file}.sha1" ]; then
    mv "${file}.sha1" "$APK_DIR/${new_name}.sha1"
    echo "${filename}.sha1  ->  ${new_name}.sha1"
  fi
done

echo "¡Listo! Todos los archivos fueron renombrados."
