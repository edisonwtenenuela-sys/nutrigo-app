# NutriGo

NutriGo es una aplicación móvil académica orientada a un ecosistema de alimentación saludable. Integra tres perfiles principales: cliente, emprendedor y profesional de nutrición.

Este repositorio reúne el frontend desarrollado con Flutter y las Cloud Functions utilizadas como backend. La versión pública no contiene credenciales, claves privadas ni identificadores del proyecto Firebase original.

## Funcionalidades principales

- Registro, autenticación y perfiles diferenciados por rol
- Catálogo de productos y validación nutricional
- Carrito, pedidos, promociones y reseñas
- Agenda de citas con profesionales de nutrición
- Pagos de prueba mediante Stripe
- Notificaciones con Firebase Cloud Messaging
- Estadísticas, reportes y gestión de inventario
- Integración con Firebase Authentication, Firestore y Storage

## Tecnologías

- Flutter y Dart
- Firebase Authentication, Firestore, Storage, App Check y Cloud Messaging
- Firebase Cloud Functions con Node.js
- Stripe
- Google Maps y Google Calendar
- Git y GitHub

## Estructura

```text
NutriGo/
|-- frontend/              Aplicación Flutter
|-- functions/             Cloud Functions de Firebase
|-- firestore.rules        Reglas de seguridad de Firestore
|-- firestore.indexes.json Índices de Firestore
|-- storage.rules          Reglas de Firebase Storage
|-- firebase.json          Configuración local de Firebase
`-- README.md
```

## Configuración local

### 1. Frontend

Instala Flutter y ejecuta:

```bash
cd frontend
flutter pub get
flutterfire configure
```

`flutterfire configure` debe generar `lib/firebase_options.dart` y la configuración nativa de Firebase. Estos archivos están excluidos del repositorio.

Configura Google Maps en `frontend/android/local.properties`:

```properties
MAPS_API_KEY=tu_clave_restringida_de_google_maps
```

Ejecuta la aplicación proporcionando la clave pública de prueba de Stripe:

```bash
flutter run --dart-define=STRIPE_PUBLISHABLE_KEY=replace_with_test_publishable_key
```

### 2. Cloud Functions

```bash
cd functions
npm install
```

Copia `.env.example` como `.env` únicamente para desarrollo local y completa las variables requeridas. No subas el archivo `.env`.

Para despliegues reales, configura los secretos mediante Firebase y revisa las reglas de Firestore y Storage antes de habilitar usuarios externos.

## Seguridad

- El repositorio no incluye secretos de Stripe, Google ni Firebase.
- Las claves de cliente deben restringirse por aplicación, paquete, firma y API habilitada.
- Las reglas incluidas corresponden a un proyecto académico y deben someterse a pruebas de seguridad antes de un uso productivo.
- No utilices datos personales reales durante las demostraciones.

## Participación y uso de inteligencia artificial

El proyecto fue realizado como trabajo de titulación. Edison Wilson Tenenuela Mejia definió requerimientos, reglas y funcionalidades; configuró servicios, ejecutó pruebas funcionales, documentó incidencias y verificó correcciones. El código fue generado y adaptado con asistencia de herramientas de inteligencia artificial a partir de sus instrucciones e ideas.

## Estado

Proyecto académico y de portafolio. No es un servicio productivo ni procesa pagos reales.

