import 'westside_backend.dart';
import 'utility/html_template.dart';
import 'model/user.dart';

class WestsideBackendSink extends RequestSink {
  static const String ConfigurationValuesKey = "ConfigurationValuesKey";

  HTMLRenderer htmlRenderer = new HTMLRenderer();
  ManagedContext context;
  AuthServer authServer;

  WestsideBackendSink(ApplicationConfiguration appConfig) : super(appConfig) {
    logger.onRecord.listen((rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));

    var options = new WestSideBackendConfiguration(appConfig.configurationFilePath);

    ManagedContext.defaultContext = contextWithConnectionInfo(options.database);

    var authStorage = new ManagedAuthStorage<User>(ManagedContext.defaultContext);
    authServer = new AuthServer(authStorage);
  }

  static Future initializeApplication(ApplicationConfiguration config) async {
    if (config.configurationFilePath == null) {
      throw new ApplicationStartupException(
          "No configuration file found. See README.md.");
    }

    var configFileValues = new WestSideBackendConfiguration(config.configurationFilePath);
    config.options[ConfigurationValuesKey] = configFileValues;
  }

  @override
  void setupRouter(Router router) {
    router
        .route("/health")
        .generate(() => new HealthController());

    router
        .route("/auth/token")
        .generate(() => new AuthController(authServer));

    router
        .route("/auth/code")
        .generate(() => new AuthCodeController(authServer, renderAuthorizationPageHTML: renderLoginPage));

    router
        .route("/register")
        .pipe(new Authorizer.basic(authServer))
        .generate(() => new RegisterController(authServer));

    router
        .route("/me")
        .pipe(new Authorizer.bearer(authServer))
        .generate(() => new IdentityController());

    router
        .route("/users/[:id]")
        .pipe(new Authorizer.bearer(authServer))
        .generate(() => new UserController(authServer));

    router
        .route("/events/[:id]")
        .pipe(new Authorizer.basic(authServer))
        .generate(() => new EventController());

    router
        .route("/admin/events/[:id]")
        .pipe(new Authorizer.bearer(authServer))
        .generate(() => new AdminEventController());

    router
        .route("/groups/[:id]")
        .pipe(new Authorizer.basic(authServer))
        .generate(() => new GroupController());

    router
        .route("/admin/groups/[:id]")
        .pipe(new Authorizer.bearer(authServer))
        .generate(() => new AdminGroupController());

    router
        .route("/schedule/[:id]")
        .pipe(new Authorizer.bearer(authServer))
        .generate(() => new ScheduleController());

    router
        .route("/ministries/[:id]")
        .pipe(new Authorizer.bearer(authServer))
        .generate(() => new MinistryController());

    router
        .route("/announcements/[:id]")
        .pipe(new Authorizer.basic(authServer))
        .generate(() => new AnnouncementController());

    router
        .route("/announcements/group/[:id]")
        .pipe(new Authorizer.basic(authServer))
        .generate(() => new AnnouncementGroupController());

    router
        .route("/admin/announcements/[:id]")
        .pipe(new Authorizer.bearer(authServer))
        .generate(() => new AdminAnnouncementController());

    router
        .route("/prayers/[:id]")
        .pipe(new Authorizer.basic(authServer))
        .generate(() => new PrayerController());

    router
        .route("/admin/prayers/[:id]")
        .pipe(new Authorizer.bearer(authServer))
        .generate(() => new AdminPrayerController());
  }

  @override
  Future willOpen() async {}

  ManagedContext contextWithConnectionInfo(
      DatabaseConnectionConfiguration connectionInfo) {
    var dataModel = new ManagedDataModel.fromCurrentMirrorSystem();
    var psc = new PostgreSQLPersistentStore.fromConnectionInfo(
        connectionInfo.username,
        connectionInfo.password,
        connectionInfo.host,
        connectionInfo.port,
        connectionInfo.databaseName);

    return new ManagedContext(dataModel, psc);
  }

  Future<String> renderLoginPage(AuthCodeController controller, Uri requestURI, Map<String, String> queryParameters) async {
    var path = requestURI.path;
    var map = new Map<String, String>.from(queryParameters);
    map["path"] = path;

    return htmlRenderer.renderHTML("web/login.html", map);
  }

  @override
  Map<String, APISecurityScheme> documentSecuritySchemes(PackagePathResolver resolver) {
    return authServer.documentSecuritySchemes(resolver);
  }
}

class WestSideBackendConfiguration extends ConfigurationItem {
  WestSideBackendConfiguration(String fileName) : super.fromFile(fileName);

  DatabaseConnectionConfiguration database;
}
