import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:emprendedor/features/entrepreneur/controllers/index.dart';

class EntrepreneurProviders {
  static List<SingleChildWidget> providers = [
    ChangeNotifierProvider(create: (_) => ProductController()),
    ChangeNotifierProvider(create: (_) => OrderController()),
    ChangeNotifierProvider(create: (_) => StatsController()),
    ChangeNotifierProvider(create: (_) => PromotionController()),
    ChangeNotifierProvider(create: (_) => ProfileController()),
    ChangeNotifierProvider(create: (_) => SocialMediaController()),
    ChangeNotifierProvider(create: (_) => PaymentMethodController()),
  ];
}








