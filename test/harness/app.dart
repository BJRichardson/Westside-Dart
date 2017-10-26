import 'package:westside_backend/westside_backend.dart';
import 'package:aqueduct/test.dart';

export 'package:westside_backend/westside_backend.dart';
export 'package:aqueduct/test.dart';
export 'package:test/test.dart';
export 'package:aqueduct/aqueduct.dart';

class TestApplication {
  static const DefaultClientID = "com.westside.backend";
  static const DefaultClientSecret = "fellowship1953";

  TestApplication() {
    configuration = new WestSideBackendConfiguration("config.src.yaml");
    configuration.database.isTemporary = true;
  }

  Application<WestsideBackendSink> application;
  WestsideBackendSink get sink => application.mainIsolateSink;
  TestClient client;
  WestSideBackendConfiguration configuration;

  Future start() async {
    RequestController.letUncaughtExceptionsEscape = true;
    application = new Application<WestsideBackendSink>();
    application.configuration.port = 0;
    application.configuration.configurationFilePath = "config.src.yaml";

    await application.start(runOnMainIsolate: true);

    await createDatabaseSchema(ManagedContext.defaultContext, sink.logger);
    await addClientRecord();

    client = new TestClient(application)
      ..clientID = DefaultClientID
      ..clientSecret = DefaultClientSecret;
  }

  Future stop() async {
    await application?.stop();
  }

  static Future<ManagedClient> addClientRecord(
      {String clientID: DefaultClientID,
        String clientSecret: DefaultClientSecret}) async {
    var salt = AuthUtility.generateRandomSalt();
    var hashedPassword = AuthUtility.generatePasswordHash(clientSecret, salt);

    var clientQ = new Query<ManagedClient>()
      ..values.id = clientID
      ..values.salt = salt
      ..values.hashedSecret = hashedPassword;
    return clientQ.insert();
  }

  static Future createDatabaseSchema(
      ManagedContext context, Logger logger) async {
    var builder = new SchemaBuilder.toSchema(
        context.persistentStore, new Schema.fromDataModel(context.dataModel),
        isTemporary: true);

    for (var cmd in builder.commands) {
      logger?.info("$cmd");
      await context.persistentStore.execute(cmd);
    }
  }
}
