// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Healthy Way';

  @override
  String get appTagline => 'Find your path to wellness';

  @override
  String get welcomeBackLong => 'Welcome back!';

  @override
  String get enterCredentials => 'Enter your credentials to continue.';

  @override
  String get usernameOrEmail => 'Username or Email';

  @override
  String get usernameOrEmailHint => 'Enter your username or email';

  @override
  String get password => 'Password';

  @override
  String get passwordHint => 'Your password';

  @override
  String get forgotPassword => 'Forgot your password?';

  @override
  String get loginButton => 'Sign In';

  @override
  String get invalidCredentials =>
      'The email/username or password is incorrect';

  @override
  String get noAccount => 'Don\'t have an account\nyet?';

  @override
  String get registerLink => 'Sign Up';

  @override
  String get connectWith => 'OR CONNECT WITH';

  @override
  String get loginSuccess => 'Login successful!';

  @override
  String get loginError => 'Incorrect username or password. Please try again.';

  @override
  String get googleLoginSuccess => 'Google sign-in successful!';

  @override
  String get googleLoginError =>
      'Error signing in with Google. Please try again.';

  @override
  String get requiredField => 'This field is required';

  @override
  String get userAlreadyExists =>
      'This email or username is already registered';

  @override
  String get createAccount => 'Create an account';

  @override
  String get joinToday => 'Join Healthy Way today!';

  @override
  String get name => 'Name';

  @override
  String get nameHint => 'Your full name';

  @override
  String get username => 'Username';

  @override
  String get usernameHint => 'The name you want to display on Healthy Way';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'example@mail.com';

  @override
  String get passwordHintSecure => 'Your secure password';

  @override
  String get repeatPassword => 'Repeat password';

  @override
  String get repeatPasswordHint => 'Re-enter your password';

  @override
  String get passwordRequirements => 'Password must contain:';

  @override
  String get passwordMinLength => 'At least 8 characters';

  @override
  String get passwordUppercase => 'One uppercase letter';

  @override
  String get passwordLowercase => 'One lowercase letter';

  @override
  String get passwordNumber => 'One number';

  @override
  String get passwordSpecialChar => 'One special character (!@#\$&*)';

  @override
  String get registerSubmit => 'Sign Up';

  @override
  String get registerWith => 'OR SIGN UP WITH';

  @override
  String get alreadyAccount => 'Already have an account?';

  @override
  String get signIn => 'Sign in';

  @override
  String get registerSuccess => 'Registration successful!';

  @override
  String get registerAfterLoginError => 'Error signing in after registration.';

  @override
  String get invalidEmail => 'Enter a valid email address';

  @override
  String get passwordsDontMatch => 'Passwords do not match';

  @override
  String get activities => 'Activities';

  @override
  String get myActivities => 'My activities';

  @override
  String get myRoutes => 'My routes';

  @override
  String get connectStrava => 'Connect with Strava';

  @override
  String get logoutLabel => 'Log Out';

  @override
  String get deleteAccountLabel => 'Delete Account';

  @override
  String get confirmDeleteRoute =>
      'Are you sure you want to delete this route?';

  @override
  String get deleteRouteTitle => 'Delete Route';

  @override
  String get confirmDeleteAccount =>
      'Are you sure you want to delete your account? This action cannot be undone and you will lose all your data and routes.';

  @override
  String get cancel => 'Cancel';

  @override
  String get deleteLabel => 'Delete';

  @override
  String get routeDeletedSuccess => 'Route deleted successfully';

  @override
  String get privateRoute => 'Private Route';

  @override
  String get publicRoute => 'Public Route';

  @override
  String get noTeam => 'No Team';

  @override
  String get defaultActivity => 'Default Activity';

  @override
  String get noNameDefined => 'No name defined';

  @override
  String get noLocationDefined => 'No location defined';

  @override
  String get errorLoadingLocation => 'Error loading location';

  @override
  String get errorLoadingName => 'Error loading name';

  @override
  String get unknownFeminine => 'Unknown';

  @override
  String get distanceStat => 'Distance';

  @override
  String get timeStat => 'Time';

  @override
  String get paceStat => 'Pace';

  @override
  String get noActivitiesYet =>
      'You haven\'t done any activity yet. Go for it!';

  @override
  String get noRoutesYet => 'You haven\'t created any routes yet.';

  @override
  String get errorLoadingActivities => 'Error loading activities';

  @override
  String get errorLoadingRoutes => 'Error loading routes';

  @override
  String get welcomeBackShort => 'Welcome back,';

  @override
  String get airQualityLong => 'AIR QUALITY';

  @override
  String get noDataParens => '(No data)';

  @override
  String get recommendedRoutes => 'Recommended Routes';

  @override
  String get errorLoadingRecommended => 'Error loading recommended routes';

  @override
  String get noRecommendedRoutes => 'No recommended routes available';

  @override
  String get routeInProgress => 'ROUTE IN PROGRESS';

  @override
  String get recording => 'RECORDING';

  @override
  String get pausedLabel => 'PAUSED';

  @override
  String get customRoute => 'CUSTOM ROUTE';

  @override
  String get totalTime => 'TOTAL TIME';

  @override
  String get finish => 'FINISH';

  @override
  String get mapLabel => 'MAP';

  @override
  String get routeLabel => 'ROUTE';

  @override
  String get saveRouteTitle => 'Save route';

  @override
  String get routeNameLabel => 'Route name';

  @override
  String get enterName => 'Enter a name';

  @override
  String get visibilityLabel => 'Visibility:';

  @override
  String get publicVisibility => 'Public';

  @override
  String get privateVisibility => 'Private';

  @override
  String get noRouteToSave => 'There is no route to save';

  @override
  String get resultsTitle => 'Results';

  @override
  String get elevationGainLabel => 'ELEVATION';

  @override
  String get exitWithoutSaving => 'Exit without saving';

  @override
  String get routeSaved => 'Route saved';

  @override
  String get kcal => 'KCAL';

  @override
  String get routesTab => 'Routes';

  @override
  String get exploreRoutes => 'Explore Routes';

  @override
  String get searchRoutesByName => 'Search routes by name';

  @override
  String get publicRoutes => 'PUBLIC ROUTES';

  @override
  String results(int count) {
    return '$count results';
  }

  @override
  String get noRoutesFound =>
      'No routes found. Try adjusting the filters or search.';

  @override
  String get filterRoutes => 'Filter Routes';

  @override
  String get creator => 'Creator';

  @override
  String get location => 'Location';

  @override
  String get minDist => 'Min dist. (km)';

  @override
  String get maxDist => 'Max dist. (km)';

  @override
  String get reset => 'Reset';

  @override
  String get apply => 'Apply';

  @override
  String get easy => 'Easy';

  @override
  String get moderate => 'Moderate';

  @override
  String get hard => 'Hard';

  @override
  String get veryHard => 'Very hard';

  @override
  String get distance => 'DISTANCE';

  @override
  String get altitude => 'ALTITUDE';

  @override
  String get createdBy => 'CREATOR';

  @override
  String get selectRoute => 'Select Route';

  @override
  String get loading => 'Loading...';

  @override
  String get unknown => 'Unknown';

  @override
  String get searchRoutes => 'Search routes';

  @override
  String get capturedZones => 'Captured Zones';

  @override
  String get searchTeam => 'Search team...';

  @override
  String get unknownLocation => 'Unknown location';

  @override
  String get trainingInProgress => 'Training in progress';

  @override
  String get routeBeingRecorded => 'Your route is being recorded...';

  @override
  String get running => 'Running';

  @override
  String get cycling => 'Cycling';

  @override
  String get kmRunning => 'KM RUNNING';

  @override
  String get kmCycling => 'KM CYCLING';

  @override
  String get totalPoints => 'TOTAL POINTS';

  @override
  String get airQuality => 'AIR QUALITY';

  @override
  String get healthIndex => 'HEALTH INDEX';

  @override
  String get excellent => 'Excellent';

  @override
  String get good => 'Good';

  @override
  String get moderate_air => 'Moderate';

  @override
  String get bad => 'Poor';

  @override
  String get noData => 'No data';

  @override
  String get improveExperience => 'Improve your experience';

  @override
  String get backgroundLocationMessage =>
      'To record routes without interruptions with the screen off, go to Settings and select \"Allow all the time\".';

  @override
  String get later => 'Later';

  @override
  String get goToSettings => 'Go to Settings';
}
