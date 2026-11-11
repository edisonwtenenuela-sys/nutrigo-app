import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:emprendedor/features/client/controllers/index.dart';

class ClientProviders {
  static List<SingleChildWidget> providers = [
    ChangeNotifierProvider(create: (_) => ClientProfileController()),
    ChangeNotifierProvider(create: (_) => CartController()),
    ChangeNotifierProvider(create: (_) => ClientOrderController()),
    ChangeNotifierProvider(create: (_) => AppointmentController()),
  ];
}








