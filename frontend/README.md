# NutriGo — aplicación Flutter

Frontend móvil del proyecto académico NutriGo, orientado a conectar clientes,
emprendedores de alimentación saludable y profesionales de nutrición.

Incluye autenticación por perfiles, catálogo, pedidos, citas, promociones,
estadísticas e integraciones con Firebase, Google Calendar y Stripe en modo de
pruebas.

## Configuración

Las credenciales y los archivos de configuración reales no forman parte del
repositorio. Consulta el [`README.md`](../README.md) principal para preparar
Firebase, Google Maps, Stripe y las Cloud Functions antes de ejecutar:

```bash
flutter pub get
flutter run --dart-define=STRIPE_PUBLISHABLE_KEY=tu_clave_de_pruebas
```

El nombre interno del paquete Dart se conserva como `emprendedor` para no
romper las importaciones existentes del proyecto.
