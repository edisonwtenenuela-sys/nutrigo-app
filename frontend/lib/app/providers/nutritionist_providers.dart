import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:emprendedor/features/nutritionist/controllers/index.dart';

class NutritionistProviders {
  static List<SingleChildWidget> providers = [
    ChangeNotifierProvider(create: (_) => NutritionistProfileController()),
    ChangeNotifierProvider(create: (_) => NutritionistAvailabilityController()),
    ChangeNotifierProvider(create: (_) => NutritionistPatientsController()),
    ChangeNotifierProvider(create: (_) => NutritionistAppointmentsController()),
  ];
}








