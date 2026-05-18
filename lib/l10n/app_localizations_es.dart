// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Healthy Way';

  @override
  String get appTagline => 'Encuentra tu camino hacia el bienestar';

  @override
  String get welcomeBackLong => '¡Bienvenido/a de nuevo!';

  @override
  String get enterCredentials => 'Introduce tus credenciales para continuar.';

  @override
  String get usernameOrEmail => 'Username o Correo electrónico';

  @override
  String get usernameOrEmailHint => 'Introduce tu usuario o email';

  @override
  String get password => 'Contraseña';

  @override
  String get passwordHint => 'Tu contraseña';

  @override
  String get forgotPassword => '¿Has olvidado la contraseña?';

  @override
  String get loginButton => 'Entrar';

  @override
  String get invalidCredentials =>
      'El correo/usuario o la contraseña son incorrectos';

  @override
  String get noAccount => '¿No tienes cuenta\ntodavía?';

  @override
  String get registerLink => 'Regístrate';

  @override
  String get connectWith => 'O CONECTA CON';

  @override
  String get loginSuccess => '¡Inicio de sesión correcto!';

  @override
  String get loginError =>
      'Usuario o contraseña incorrectos. Inténtalo de nuevo.';

  @override
  String get googleLoginSuccess => '¡Inicio de sesión con Google correcto!';

  @override
  String get googleLoginError =>
      'Error al iniciar sesión con Google. Inténtalo de nuevo.';

  @override
  String get requiredField => 'Este campo es obligatorio';

  @override
  String get userAlreadyExists =>
      'Este correo o nombre de usuario ya está registrado';

  @override
  String get createAccount => 'Crea una cuenta';

  @override
  String get joinToday => '¡Únete a Healthy Way hoy mismo!';

  @override
  String get name => 'Nombre';

  @override
  String get nameHint => 'Tu nombre completo';

  @override
  String get username => 'Nombre de usuario';

  @override
  String get usernameHint => 'El nombre que quieres mostrar en Healthy Way';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get emailHint => 'ejemplo@correo.com';

  @override
  String get passwordHintSecure => 'Tu contraseña segura';

  @override
  String get repeatPassword => 'Repite la contraseña';

  @override
  String get repeatPasswordHint => 'Vuelve a escribir la contraseña';

  @override
  String get passwordRequirements => 'La contraseña debe contener:';

  @override
  String get passwordMinLength => 'Mínimo 8 caracteres';

  @override
  String get passwordUppercase => 'Una letra mayúscula';

  @override
  String get passwordLowercase => 'Una letra minúscula';

  @override
  String get passwordNumber => 'Un número';

  @override
  String get passwordSpecialChar => 'Un carácter especial (!@#\$&*)';

  @override
  String get registerSubmit => 'Registrarse';

  @override
  String get registerWith => 'O REGÍSTRATE CON';

  @override
  String get alreadyAccount => '¿Ya tienes una cuenta?';

  @override
  String get signIn => 'Inicia sesión';

  @override
  String get registerSuccess => '¡Registro correcto!';

  @override
  String get registerAfterLoginError =>
      'Error al iniciar sesión después del registro.';

  @override
  String get invalidEmail => 'Introduce un correo electrónico válido';

  @override
  String get passwordsDontMatch => 'Las contraseñas no coinciden';

  @override
  String get activities => 'Actividades';

  @override
  String get myActivities => 'Mis actividades';

  @override
  String get myRoutes => 'Mis rutas';

  @override
  String get connectStrava => 'Conectar con Strava';

  @override
  String get logoutLabel => 'Cerrar Sesión';

  @override
  String get deleteAccountLabel => 'Eliminar Cuenta';

  @override
  String get confirmDeleteRoute =>
      '¿Estás seguro de que quieres eliminar esta ruta?';

  @override
  String get deleteRouteTitle => 'Eliminar Ruta';

  @override
  String get confirmDeleteAccount =>
      '¿Estás seguro de que quieres eliminar tu cuenta? Esta acción no se puede deshacer y perderás todos tus datos y rutas.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get deleteLabel => 'Eliminar';

  @override
  String get routeDeletedSuccess => 'Ruta eliminada correctamente';

  @override
  String get privateRoute => 'Ruta Privada';

  @override
  String get publicRoute => 'Ruta Pública';

  @override
  String get noTeam => 'Sin Equipo';

  @override
  String get defaultActivity => 'Actividad Predeterminada';

  @override
  String get noNameDefined => 'Sin nombre definido';

  @override
  String get noLocationDefined => 'Sin ubicación definida';

  @override
  String get errorLoadingLocation => 'Error cargando ubicación';

  @override
  String get errorLoadingName => 'Error cargando el nombre';

  @override
  String get unknownFeminine => 'Desconocida';

  @override
  String get distanceStat => 'Distancia';

  @override
  String get timeStat => 'Tiempo';

  @override
  String get paceStat => 'Ritmo';

  @override
  String get noActivitiesYet =>
      'Todavía no has hecho ninguna actividad. ¡Anímate!';

  @override
  String get noRoutesYet => 'Todavía no has creado ninguna ruta.';

  @override
  String get errorLoadingActivities => 'Error al cargar actividades';

  @override
  String get errorLoadingRoutes => 'Error al cargar rutas';

  @override
  String get welcomeBackShort => 'Bienvenido de nuevo,';

  @override
  String get airQualityLong => 'CALIDAD DEL AIRE';

  @override
  String get noDataParens => '(Sin datos)';

  @override
  String get recommendedRoutes => 'Rutas Recomendadas';

  @override
  String get errorLoadingRecommended =>
      'Error al cargar las rutas recomendadas';

  @override
  String get noRecommendedRoutes => 'No hay rutas recomendadas disponibles';

  @override
  String get routeInProgress => 'RUTA EN MARCHA';

  @override
  String get recording => 'GRABANDO';

  @override
  String get pausedLabel => 'PAUSADO';

  @override
  String get customRoute => 'RUTA PERSONALIZADA';

  @override
  String get totalTime => 'TIEMPO TOTAL';

  @override
  String get finish => 'FINALIZAR';

  @override
  String get mapLabel => 'MAPA';

  @override
  String get routeLabel => 'RUTA';

  @override
  String get saveRouteTitle => 'Guardar ruta';

  @override
  String get routeNameLabel => 'Nombre de la ruta';

  @override
  String get enterName => 'Introduce un nombre';

  @override
  String get visibilityLabel => 'Visibilidad:';

  @override
  String get publicVisibility => 'Pública';

  @override
  String get privateVisibility => 'Privada';

  @override
  String get noRouteToSave => 'No hay ninguna ruta para guardar';

  @override
  String get resultsTitle => 'Resultados';

  @override
  String get elevationGainLabel => 'DESNIVEL';

  @override
  String get exitWithoutSaving => 'Salir sin guardar';

  @override
  String get routeSaved => 'Ruta guardada';

  @override
  String get kcal => 'KCAL';

  @override
  String get routesTab => 'Rutas';

  @override
  String get exploreRoutes => 'Explorar Rutas';

  @override
  String get searchRoutesByName => 'Busca rutas por su nombre';

  @override
  String get publicRoutes => 'RUTAS PÚBLICAS';

  @override
  String results(int count) {
    return '$count resultados';
  }

  @override
  String get noRoutesFound =>
      'No se han encontrado rutas. Prueba a ajustar los filtros o la búsqueda.';

  @override
  String get filterRoutes => 'Filtrar Rutas';

  @override
  String get creator => 'Creador';

  @override
  String get location => 'Localización';

  @override
  String get minDist => 'Dist. Min (km)';

  @override
  String get maxDist => 'Dist. Max (km)';

  @override
  String get reset => 'Restablecer';

  @override
  String get apply => 'Aplicar';

  @override
  String get easy => 'Fácil';

  @override
  String get moderate => 'Moderada';

  @override
  String get hard => 'Difícil';

  @override
  String get veryHard => 'Muy difícil';

  @override
  String get distance => 'DISTANCIA';

  @override
  String get altitude => 'ALTITUD';

  @override
  String get createdBy => 'CREADOR';

  @override
  String get selectRoute => 'Seleccionar Ruta';

  @override
  String get loading => 'Cargando...';

  @override
  String get unknown => 'Desconocido';

  @override
  String get searchRoutes => 'Buscar rutas';

  @override
  String get capturedZones => 'Zonas Capturadas';

  @override
  String get searchTeam => 'Buscar equipo...';

  @override
  String get unknownLocation => 'Ubicación desconocida';

  @override
  String get trainingInProgress => 'Entrenamiento en curso';

  @override
  String get routeBeingRecorded => 'Tu ruta se está grabando...';

  @override
  String get running => 'Running';

  @override
  String get cycling => 'Ciclismo';

  @override
  String get kmRunning => 'KM CORRIENDO';

  @override
  String get kmCycling => 'KM EN BICI';

  @override
  String get totalPoints => 'PUNTOS TOTALES';

  @override
  String get airQuality => 'CALIDAD AIRE';

  @override
  String get healthIndex => 'ÍNDICE DE SALUD';

  @override
  String get excellent => 'Excelente';

  @override
  String get good => 'Buena';

  @override
  String get moderate_air => 'Moderada';

  @override
  String get bad => 'Mala';

  @override
  String get noData => 'Sin datos';
}
