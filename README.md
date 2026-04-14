# Healthy Way Frontend

Este repositorio contiene el frontend de la aplicación Healthy Way (Flutter).

## Requisitos previos

- Instalar Flutter (descárgalo desde https://flutter.dev) y añade el binario de Flutter a tu PATH.
- Instalar Visual Studio Code (opcional, pero recomendado) y las siguientes extensiones:
	- Extension "Dart"
	- Extension "Flutter"
- Si quieres ejecutar la aplicación en un dispositivo Android (móvil/emulador):
	- Instala Android Studio y configura el Android SDK y un emulador AVD, o conecta un dispositivo físico con la depuración USB habilitada.
	- (Opcional) Instala la extensión de Android en tu editor si deseas utilidades adicionales.

## Ejecutar la aplicación por primera vez

1. Clona el repositorio y abre la carpeta del proyecto en tu editor:

	 git clone <repo-url>
	 cd healthy_way_frontend

2. Comprueba que Flutter está instalado y configurado:

	 flutter --version
	 flutter doctor

	 - Si vas a usar Android, ejecuta también:

		 flutter doctor --android-licenses

3. Obtén las dependencias del proyecto:

	 flutter pub get

4. Ejecuta la aplicación:

	 - Para ejecutar en el emulador o en un dispositivo conectado:

		 flutter run

	 - Desde Visual Studio Code: selecciona un dispositivo en la barra de estado y usa la acción "Run" o "Debug".

## Notas y soluciones comunes

- Si `flutter doctor` muestra advertencias o errores, sigue las indicaciones que muestra para instalar componentes faltantes.
- En Windows asegúrate de que las rutas a Java/Android/Flutter estén correctamente configuradas en las variables de entorno.
- Si tienes problemas al ejecutar en Android, comprueba que el emulador está creado y corriendo, o que el dispositivo físico está autorizado para depuración USB.

Si quieres que añada instrucciones más detalladas (por ejemplo: configuración paso a paso de Android Studio, variables de entorno en Windows, o cómo ejecutar pruebas), dímelo y lo añado.