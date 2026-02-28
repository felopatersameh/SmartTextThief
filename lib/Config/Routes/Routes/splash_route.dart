import 'package:go_router/go_router.dart';
import 'package:smart_text_thief/Config/Routes/name_routes.dart';
import 'package:smart_text_thief/Features/Splash/splash_screen.dart';

class SplashRoute {
  static GoRoute get route => GoRoute(
        name: NameRoutes.splash,
        path: NameRoutes.splash.ensureWithSlash(),
        builder: (context, state) => const SplashScreen(),
      );
}
