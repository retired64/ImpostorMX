#!/bin/bash

# 1. Extraer la versión del pubspec.yaml (ej. 2.1.0)
VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}' | cut -d '+' -f 1)
echo "Preparando Release para la versión: v$VERSION"
echo "------------------------------------------------"

# 2. Pedir el título de la actualización
read -p "Ingresa el nombre de esta actualización (ej. Multilingual Update): " TITULO_RELEASE

# 3. Detectar automáticamente el changelog más alto
DIR_CHANGELOGS="fastlane/metadata/android/en-US/changelogs"

# Busca todos los .txt, extrae solo el nombre, quita el .txt, los ordena numéricamente y toma el último
CHANGELOG_AUTO=$(find "$DIR_CHANGELOGS" -name "*.txt" -exec basename {} .txt \; | sort -n | tail -1)

echo "Se detectó automáticamente el changelog: $CHANGELOG_AUTO.txt"
read -p "¿Quieres usar este archivo? (Presiona Enter para confirmar, o escribe otro número): " CHANGELOG_ELEGIDO

# Si el usuario presiona Enter sin escribir nada, usamos el detectado automáticamente
CHANGELOG_ELEGIDO=${CHANGELOG_ELEGIDO:-$CHANGELOG_AUTO}
ARCHIVO_NOTAS="$DIR_CHANGELOGS/${CHANGELOG_ELEGIDO}.txt"

# Verificar que el archivo realmente exista
if [ ! -f "$ARCHIVO_NOTAS" ]; then
  echo "Error: No se encontró el archivo $ARCHIVO_NOTAS"
  exit 1
fi

echo "------------------------------------------------"
echo "RESUMEN DEL LANZAMIENTO:"
echo "   - Versión: v$VERSION"
echo "   - Título: $TITULO_RELEASE"
echo "   - Notas: $ARCHIVO_NOTAS"
echo "------------------------------------------------"
read -p "¿Todo es correcto? Presiona Enter para iniciar la subida o Ctrl+C para cancelar..."

# 4. Ejecutar comandos de Git
echo "Subiendo código a GitHub..."
git add .
git commit -m "feat: versión $VERSION - $TITULO_RELEASE"
git push origin main

echo "Creando y subiendo el Tag v$VERSION..."
git tag -a "v$VERSION" -m "Versión $VERSION - $TITULO_RELEASE"
git push origin "v$VERSION"

# 5. Ejecutar comando de GitHub CLI para el Release
echo "Creando el Release en GitHub y subiendo APKs..."
gh release create "v$VERSION" \
  build/app/outputs/flutter-apk/*.apk \
  --title "Impostor MX v$VERSION - $TITULO_RELEASE" \
  --notes-file "$ARCHIVO_NOTAS"

echo "¡Lanzamiento v$VERSION completado con éxito!"
