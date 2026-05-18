import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ca.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ca'),
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ca, this message translates to:
  /// **'Healthy Way'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In ca, this message translates to:
  /// **'Troba el teu camí cap al benestar'**
  String get appTagline;

  /// No description provided for @welcomeBackLong.
  ///
  /// In ca, this message translates to:
  /// **'Benvingut/da de nou!'**
  String get welcomeBackLong;

  /// No description provided for @enterCredentials.
  ///
  /// In ca, this message translates to:
  /// **'Introdueix les teves credencials per continuar.'**
  String get enterCredentials;

  /// No description provided for @usernameOrEmail.
  ///
  /// In ca, this message translates to:
  /// **'Username o Correu electrònic'**
  String get usernameOrEmail;

  /// No description provided for @usernameOrEmailHint.
  ///
  /// In ca, this message translates to:
  /// **'Introdueix el teu usuari o email'**
  String get usernameOrEmailHint;

  /// No description provided for @password.
  ///
  /// In ca, this message translates to:
  /// **'Contrasenya'**
  String get password;

  /// No description provided for @passwordHint.
  ///
  /// In ca, this message translates to:
  /// **'La teva contrasenya'**
  String get passwordHint;

  /// No description provided for @forgotPassword.
  ///
  /// In ca, this message translates to:
  /// **'Has oblidat la contrasenya?'**
  String get forgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In ca, this message translates to:
  /// **'Entrar'**
  String get loginButton;

  /// No description provided for @invalidCredentials.
  ///
  /// In ca, this message translates to:
  /// **'El correu/usuari o la contrasenya són incorrectes'**
  String get invalidCredentials;

  /// No description provided for @noAccount.
  ///
  /// In ca, this message translates to:
  /// **'No tens compte\nencara?'**
  String get noAccount;

  /// No description provided for @registerLink.
  ///
  /// In ca, this message translates to:
  /// **'Registra\'t'**
  String get registerLink;

  /// No description provided for @connectWith.
  ///
  /// In ca, this message translates to:
  /// **'O CONNECTA AMB'**
  String get connectWith;

  /// No description provided for @loginSuccess.
  ///
  /// In ca, this message translates to:
  /// **'Inici de sessió correcte!'**
  String get loginSuccess;

  /// No description provided for @loginError.
  ///
  /// In ca, this message translates to:
  /// **'Username o contrasenya incorrectes. Torna-ho a provar.'**
  String get loginError;

  /// No description provided for @googleLoginSuccess.
  ///
  /// In ca, this message translates to:
  /// **'Inici de sessió amb Google correcte!'**
  String get googleLoginSuccess;

  /// No description provided for @googleLoginError.
  ///
  /// In ca, this message translates to:
  /// **'Error en iniciar sessió amb Google. Torna-ho a provar.'**
  String get googleLoginError;

  /// No description provided for @requiredField.
  ///
  /// In ca, this message translates to:
  /// **'Aquest camp és obligatori'**
  String get requiredField;

  /// No description provided for @userAlreadyExists.
  ///
  /// In ca, this message translates to:
  /// **'Aquest correu o nom d\'usuari ja està registrat'**
  String get userAlreadyExists;

  /// No description provided for @createAccount.
  ///
  /// In ca, this message translates to:
  /// **'Crea un compte'**
  String get createAccount;

  /// No description provided for @joinToday.
  ///
  /// In ca, this message translates to:
  /// **'Uneix-te a Healthy Way avui mateix!'**
  String get joinToday;

  /// No description provided for @name.
  ///
  /// In ca, this message translates to:
  /// **'Nom'**
  String get name;

  /// No description provided for @nameHint.
  ///
  /// In ca, this message translates to:
  /// **'El teu nom complet'**
  String get nameHint;

  /// No description provided for @username.
  ///
  /// In ca, this message translates to:
  /// **'Nom d\'usuari'**
  String get username;

  /// No description provided for @usernameHint.
  ///
  /// In ca, this message translates to:
  /// **'El nom que vols que es mostri a Healthy Way'**
  String get usernameHint;

  /// No description provided for @emailLabel.
  ///
  /// In ca, this message translates to:
  /// **'Correu electrònic'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In ca, this message translates to:
  /// **'exemple@correu.com'**
  String get emailHint;

  /// No description provided for @passwordHintSecure.
  ///
  /// In ca, this message translates to:
  /// **'La teva contrasenya segura'**
  String get passwordHintSecure;

  /// No description provided for @repeatPassword.
  ///
  /// In ca, this message translates to:
  /// **'Repeteix la contrasenya'**
  String get repeatPassword;

  /// No description provided for @repeatPasswordHint.
  ///
  /// In ca, this message translates to:
  /// **'Torna a escriure la contrasenya'**
  String get repeatPasswordHint;

  /// No description provided for @passwordRequirements.
  ///
  /// In ca, this message translates to:
  /// **'La contrasenya ha de contenir:'**
  String get passwordRequirements;

  /// No description provided for @passwordMinLength.
  ///
  /// In ca, this message translates to:
  /// **'Mínim 8 caràcters'**
  String get passwordMinLength;

  /// No description provided for @passwordUppercase.
  ///
  /// In ca, this message translates to:
  /// **'Una lletra majúscula'**
  String get passwordUppercase;

  /// No description provided for @passwordLowercase.
  ///
  /// In ca, this message translates to:
  /// **'Una lletra minúscula'**
  String get passwordLowercase;

  /// No description provided for @passwordNumber.
  ///
  /// In ca, this message translates to:
  /// **'Un número'**
  String get passwordNumber;

  /// No description provided for @passwordSpecialChar.
  ///
  /// In ca, this message translates to:
  /// **'Un caràcter especial (!@#\$&*)'**
  String get passwordSpecialChar;

  /// No description provided for @registerSubmit.
  ///
  /// In ca, this message translates to:
  /// **'Registrar-se'**
  String get registerSubmit;

  /// No description provided for @registerWith.
  ///
  /// In ca, this message translates to:
  /// **'O REGISTRA\'T AMB'**
  String get registerWith;

  /// No description provided for @alreadyAccount.
  ///
  /// In ca, this message translates to:
  /// **'Ja tens un compte?'**
  String get alreadyAccount;

  /// No description provided for @signIn.
  ///
  /// In ca, this message translates to:
  /// **'Inicia sessió'**
  String get signIn;

  /// No description provided for @registerSuccess.
  ///
  /// In ca, this message translates to:
  /// **'Registre correcte!'**
  String get registerSuccess;

  /// No description provided for @registerAfterLoginError.
  ///
  /// In ca, this message translates to:
  /// **'Error en iniciar sessió després del registre.'**
  String get registerAfterLoginError;

  /// No description provided for @invalidEmail.
  ///
  /// In ca, this message translates to:
  /// **'Introdueix un correu electrònic vàlid'**
  String get invalidEmail;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In ca, this message translates to:
  /// **'Les contrasenyes no coincideixen'**
  String get passwordsDontMatch;

  /// No description provided for @activities.
  ///
  /// In ca, this message translates to:
  /// **'Activitats'**
  String get activities;

  /// No description provided for @myActivities.
  ///
  /// In ca, this message translates to:
  /// **'Les meves activitats'**
  String get myActivities;

  /// No description provided for @myRoutes.
  ///
  /// In ca, this message translates to:
  /// **'Les meves rutes'**
  String get myRoutes;

  /// No description provided for @connectStrava.
  ///
  /// In ca, this message translates to:
  /// **'Connectar amb Strava'**
  String get connectStrava;

  /// No description provided for @logoutLabel.
  ///
  /// In ca, this message translates to:
  /// **'Tancar Sessió'**
  String get logoutLabel;

  /// No description provided for @deleteAccountLabel.
  ///
  /// In ca, this message translates to:
  /// **'Eliminar Compte'**
  String get deleteAccountLabel;

  /// No description provided for @confirmDeleteRoute.
  ///
  /// In ca, this message translates to:
  /// **'Estàs segur que vols eliminar aquesta ruta?'**
  String get confirmDeleteRoute;

  /// No description provided for @deleteRouteTitle.
  ///
  /// In ca, this message translates to:
  /// **'Eliminar Ruta'**
  String get deleteRouteTitle;

  /// No description provided for @confirmDeleteAccount.
  ///
  /// In ca, this message translates to:
  /// **'Estàs segur que vols eliminar el teu compte? Aquesta acció no es pot desfer i perdràs totes les teves dades i rutes.'**
  String get confirmDeleteAccount;

  /// No description provided for @cancel.
  ///
  /// In ca, this message translates to:
  /// **'Cancel·lar'**
  String get cancel;

  /// No description provided for @deleteLabel.
  ///
  /// In ca, this message translates to:
  /// **'Eliminar'**
  String get deleteLabel;

  /// No description provided for @routeDeletedSuccess.
  ///
  /// In ca, this message translates to:
  /// **'Ruta eliminada correctament'**
  String get routeDeletedSuccess;

  /// No description provided for @privateRoute.
  ///
  /// In ca, this message translates to:
  /// **'Ruta Privada'**
  String get privateRoute;

  /// No description provided for @publicRoute.
  ///
  /// In ca, this message translates to:
  /// **'Ruta Pública'**
  String get publicRoute;

  /// No description provided for @noTeam.
  ///
  /// In ca, this message translates to:
  /// **'Sense Equip'**
  String get noTeam;

  /// No description provided for @defaultActivity.
  ///
  /// In ca, this message translates to:
  /// **'Activitat Predeterminada'**
  String get defaultActivity;

  /// No description provided for @noNameDefined.
  ///
  /// In ca, this message translates to:
  /// **'Sense nom definit'**
  String get noNameDefined;

  /// No description provided for @noLocationDefined.
  ///
  /// In ca, this message translates to:
  /// **'Sense ubicació definida'**
  String get noLocationDefined;

  /// No description provided for @errorLoadingLocation.
  ///
  /// In ca, this message translates to:
  /// **'Error carregant ubicació'**
  String get errorLoadingLocation;

  /// No description provided for @errorLoadingName.
  ///
  /// In ca, this message translates to:
  /// **'Error carregant el nom'**
  String get errorLoadingName;

  /// No description provided for @unknownFeminine.
  ///
  /// In ca, this message translates to:
  /// **'Desconeguda'**
  String get unknownFeminine;

  /// No description provided for @distanceStat.
  ///
  /// In ca, this message translates to:
  /// **'Distància'**
  String get distanceStat;

  /// No description provided for @timeStat.
  ///
  /// In ca, this message translates to:
  /// **'Temps'**
  String get timeStat;

  /// No description provided for @paceStat.
  ///
  /// In ca, this message translates to:
  /// **'Ritme'**
  String get paceStat;

  /// No description provided for @noActivitiesYet.
  ///
  /// In ca, this message translates to:
  /// **'Encara no has fet cap activitat. Anima\'t!'**
  String get noActivitiesYet;

  /// No description provided for @noRoutesYet.
  ///
  /// In ca, this message translates to:
  /// **'Encara no has creat cap ruta.'**
  String get noRoutesYet;

  /// No description provided for @errorLoadingActivities.
  ///
  /// In ca, this message translates to:
  /// **'Error al carregar activitats'**
  String get errorLoadingActivities;

  /// No description provided for @errorLoadingRoutes.
  ///
  /// In ca, this message translates to:
  /// **'Error al carregar rutes'**
  String get errorLoadingRoutes;

  /// No description provided for @welcomeBackShort.
  ///
  /// In ca, this message translates to:
  /// **'Benvingut de nou,'**
  String get welcomeBackShort;

  /// No description provided for @airQualityLong.
  ///
  /// In ca, this message translates to:
  /// **'QUALITAT DE L\'AIRE'**
  String get airQualityLong;

  /// No description provided for @noDataParens.
  ///
  /// In ca, this message translates to:
  /// **'(Sense dades)'**
  String get noDataParens;

  /// No description provided for @recommendedRoutes.
  ///
  /// In ca, this message translates to:
  /// **'Rutes Recomanades'**
  String get recommendedRoutes;

  /// No description provided for @errorLoadingRecommended.
  ///
  /// In ca, this message translates to:
  /// **'Error al carregar les rutes recomanades'**
  String get errorLoadingRecommended;

  /// No description provided for @noRecommendedRoutes.
  ///
  /// In ca, this message translates to:
  /// **'No hi ha rutes recomanades disponibles'**
  String get noRecommendedRoutes;

  /// No description provided for @routeInProgress.
  ///
  /// In ca, this message translates to:
  /// **'RUTA EN MARXA'**
  String get routeInProgress;

  /// No description provided for @recording.
  ///
  /// In ca, this message translates to:
  /// **'ENREGISTRANT'**
  String get recording;

  /// No description provided for @pausedLabel.
  ///
  /// In ca, this message translates to:
  /// **'PAUSAT'**
  String get pausedLabel;

  /// No description provided for @customRoute.
  ///
  /// In ca, this message translates to:
  /// **'RUTA PERSONALITZADA'**
  String get customRoute;

  /// No description provided for @totalTime.
  ///
  /// In ca, this message translates to:
  /// **'TEMPS TOTAL'**
  String get totalTime;

  /// No description provided for @finish.
  ///
  /// In ca, this message translates to:
  /// **'FINALITZAR'**
  String get finish;

  /// No description provided for @mapLabel.
  ///
  /// In ca, this message translates to:
  /// **'MAPA'**
  String get mapLabel;

  /// No description provided for @routeLabel.
  ///
  /// In ca, this message translates to:
  /// **'RUTA'**
  String get routeLabel;

  /// No description provided for @saveRouteTitle.
  ///
  /// In ca, this message translates to:
  /// **'Guardar ruta'**
  String get saveRouteTitle;

  /// No description provided for @routeNameLabel.
  ///
  /// In ca, this message translates to:
  /// **'Nom de la ruta'**
  String get routeNameLabel;

  /// No description provided for @enterName.
  ///
  /// In ca, this message translates to:
  /// **'Introdueix un nom'**
  String get enterName;

  /// No description provided for @visibilityLabel.
  ///
  /// In ca, this message translates to:
  /// **'Visibilitat:'**
  String get visibilityLabel;

  /// No description provided for @publicVisibility.
  ///
  /// In ca, this message translates to:
  /// **'Pública'**
  String get publicVisibility;

  /// No description provided for @privateVisibility.
  ///
  /// In ca, this message translates to:
  /// **'Privada'**
  String get privateVisibility;

  /// No description provided for @noRouteToSave.
  ///
  /// In ca, this message translates to:
  /// **'No hi ha cap ruta per guardar'**
  String get noRouteToSave;

  /// No description provided for @resultsTitle.
  ///
  /// In ca, this message translates to:
  /// **'Resultats'**
  String get resultsTitle;

  /// No description provided for @elevationGainLabel.
  ///
  /// In ca, this message translates to:
  /// **'DESNIVELL'**
  String get elevationGainLabel;

  /// No description provided for @exitWithoutSaving.
  ///
  /// In ca, this message translates to:
  /// **'Sortir sense guardar'**
  String get exitWithoutSaving;

  /// No description provided for @routeSaved.
  ///
  /// In ca, this message translates to:
  /// **'Ruta guardada'**
  String get routeSaved;

  /// No description provided for @kcal.
  ///
  /// In ca, this message translates to:
  /// **'KCAL'**
  String get kcal;

  /// No description provided for @routesTab.
  ///
  /// In ca, this message translates to:
  /// **'Rutes'**
  String get routesTab;

  /// No description provided for @exploreRoutes.
  ///
  /// In ca, this message translates to:
  /// **'Explorar Rutes'**
  String get exploreRoutes;

  /// No description provided for @searchRoutesByName.
  ///
  /// In ca, this message translates to:
  /// **'Cerca rutes pel seu nom'**
  String get searchRoutesByName;

  /// No description provided for @publicRoutes.
  ///
  /// In ca, this message translates to:
  /// **'RUTES PÚBLIQUES'**
  String get publicRoutes;

  /// No description provided for @results.
  ///
  /// In ca, this message translates to:
  /// **'{count} resultats'**
  String results(int count);

  /// No description provided for @noRoutesFound.
  ///
  /// In ca, this message translates to:
  /// **'No s\'han trobat rutes. Prova a ajustar els filtres o la cerca.'**
  String get noRoutesFound;

  /// No description provided for @filterRoutes.
  ///
  /// In ca, this message translates to:
  /// **'Filtrar Rutes'**
  String get filterRoutes;

  /// No description provided for @creator.
  ///
  /// In ca, this message translates to:
  /// **'Creador'**
  String get creator;

  /// No description provided for @location.
  ///
  /// In ca, this message translates to:
  /// **'Localització'**
  String get location;

  /// No description provided for @minDist.
  ///
  /// In ca, this message translates to:
  /// **'Dist. Min (km)'**
  String get minDist;

  /// No description provided for @maxDist.
  ///
  /// In ca, this message translates to:
  /// **'Dist. Max (km)'**
  String get maxDist;

  /// No description provided for @reset.
  ///
  /// In ca, this message translates to:
  /// **'Restablir'**
  String get reset;

  /// No description provided for @apply.
  ///
  /// In ca, this message translates to:
  /// **'Aplicar'**
  String get apply;

  /// No description provided for @easy.
  ///
  /// In ca, this message translates to:
  /// **'Fàcil'**
  String get easy;

  /// No description provided for @moderate.
  ///
  /// In ca, this message translates to:
  /// **'Moderada'**
  String get moderate;

  /// No description provided for @hard.
  ///
  /// In ca, this message translates to:
  /// **'Difícil'**
  String get hard;

  /// No description provided for @veryHard.
  ///
  /// In ca, this message translates to:
  /// **'Molt difícil'**
  String get veryHard;

  /// No description provided for @distance.
  ///
  /// In ca, this message translates to:
  /// **'DISTÀNCIA'**
  String get distance;

  /// No description provided for @altitude.
  ///
  /// In ca, this message translates to:
  /// **'ALTITUD'**
  String get altitude;

  /// No description provided for @createdBy.
  ///
  /// In ca, this message translates to:
  /// **'CREADOR'**
  String get createdBy;

  /// No description provided for @selectRoute.
  ///
  /// In ca, this message translates to:
  /// **'Seleccionar Ruta'**
  String get selectRoute;

  /// No description provided for @loading.
  ///
  /// In ca, this message translates to:
  /// **'Carregant...'**
  String get loading;

  /// No description provided for @unknown.
  ///
  /// In ca, this message translates to:
  /// **'Desconegut'**
  String get unknown;

  /// No description provided for @searchRoutes.
  ///
  /// In ca, this message translates to:
  /// **'Cercar rutes'**
  String get searchRoutes;

  /// No description provided for @capturedZones.
  ///
  /// In ca, this message translates to:
  /// **'Zones Capturades'**
  String get capturedZones;

  /// No description provided for @searchTeam.
  ///
  /// In ca, this message translates to:
  /// **'Buscar equip...'**
  String get searchTeam;

  /// No description provided for @unknownLocation.
  ///
  /// In ca, this message translates to:
  /// **'Ubicació desconeguda'**
  String get unknownLocation;

  /// No description provided for @trainingInProgress.
  ///
  /// In ca, this message translates to:
  /// **'Entrenament en curs'**
  String get trainingInProgress;

  /// No description provided for @routeBeingRecorded.
  ///
  /// In ca, this message translates to:
  /// **'La teva ruta s\'està gravant...'**
  String get routeBeingRecorded;

  /// No description provided for @running.
  ///
  /// In ca, this message translates to:
  /// **'Running'**
  String get running;

  /// No description provided for @cycling.
  ///
  /// In ca, this message translates to:
  /// **'Ciclisme'**
  String get cycling;

  /// No description provided for @kmRunning.
  ///
  /// In ca, this message translates to:
  /// **'KM CORRENT'**
  String get kmRunning;

  /// No description provided for @kmCycling.
  ///
  /// In ca, this message translates to:
  /// **'KM EN BICI'**
  String get kmCycling;

  /// No description provided for @totalPoints.
  ///
  /// In ca, this message translates to:
  /// **'PUNTS TOTALS'**
  String get totalPoints;

  /// No description provided for @airQuality.
  ///
  /// In ca, this message translates to:
  /// **'QUALITAT AIRE'**
  String get airQuality;

  /// No description provided for @healthIndex.
  ///
  /// In ca, this message translates to:
  /// **'ÍNDEX DE SALUT'**
  String get healthIndex;

  /// No description provided for @excellent.
  ///
  /// In ca, this message translates to:
  /// **'Excel·lent'**
  String get excellent;

  /// No description provided for @good.
  ///
  /// In ca, this message translates to:
  /// **'Bona'**
  String get good;

  /// No description provided for @moderate_air.
  ///
  /// In ca, this message translates to:
  /// **'Moderada'**
  String get moderate_air;

  /// No description provided for @bad.
  ///
  /// In ca, this message translates to:
  /// **'Dolenta'**
  String get bad;

  /// No description provided for @noData.
  ///
  /// In ca, this message translates to:
  /// **'Sense dades'**
  String get noData;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ca', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ca':
      return AppLocalizationsCa();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
