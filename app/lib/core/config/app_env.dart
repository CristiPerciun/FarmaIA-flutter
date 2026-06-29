/// Application environment (dev uses emulators, prod uses live Firebase).
enum AppEnv {
  dev,
  prod;

  static AppEnv fromDartDefine() {
    const env = String.fromEnvironment('ENV', defaultValue: 'dev');
    return env == 'prod' ? AppEnv.prod : AppEnv.dev;
  }

  bool get isDev => this == AppEnv.dev;
  bool get isProd => this == AppEnv.prod;
}
