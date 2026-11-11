const dotenv = require("dotenv");
dotenv.config();

const {setGlobalOptions} = require("firebase-functions");
const {defineSecret} = require("firebase-functions/params");
const {onCall, onRequest, HttpsError} = require("firebase-functions/v2/https");
const {
  onDocumentCreated,
  onDocumentUpdated,
  onDocumentWritten,
  onDocumentDeleted,
} = require("firebase-functions/v2/firestore");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");
const {google} = require("googleapis");
const Stripe = require("stripe");

setGlobalOptions({
  maxInstances: 10,
  region: "us-central1",
});

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();
const FIRESTORE_TRIGGER_REGION = "southamerica-west1";

const stripeSecretKey = process.env.STRIPE_SECRET_KEY;

if (!stripeSecretKey) {
  throw new Error(
    "Falta STRIPE_SECRET_KEY. Verifica functions/.env y su contenido."
  );
}

const stripe = new Stripe(stripeSecretKey);

const googleCalendarId = process.env.GOOGLE_CALENDAR_ID;
const GOOGLE_CLIENT_ID = defineSecret("GOOGLE_CLIENT_ID");
const GOOGLE_CLIENT_SECRET = defineSecret("GOOGLE_CLIENT_SECRET");
const GOOGLE_REFRESH_TOKEN = defineSecret("GOOGLE_REFRESH_TOKEN");

const googleCalendarSecrets = [
  GOOGLE_CLIENT_ID,
  GOOGLE_CLIENT_SECRET,
  GOOGLE_REFRESH_TOKEN,
];
function cleanText(value, fallback = "") {
  const raw = String(value || fallback || "").trim();
  if (!/[\u00c3\u00c2\u00e2\ufffd?]/.test(raw)) return raw;

  const fixed = raw
    .replace(/aprobaci./g, "aprobación")
    .replace(/validaci./g, "validación")
    .replace(/revisi./g, "revisión")
    .replace(/Notificaci./g, "Notificación")
    .replace(/notificaci./g, "notificación")
    .replace(/sesi.n/g, "sesión")
    .replace(/env.a/g, "envía")
    .replace(/envi./g, "envió")
    .replace(/est(?:\ufffd|\u00c3\u00a1|\?)/g, "est\u00e1")
    .replace(/inv.lidos/g, "inválidos")
    .replace(/.xito/g, "éxito")
    .replace(/devolvi./g, "devolvió")
    .replace(/actualizaci./g, "actualización")
    .replace(/reenv.o/g, "reenvío")
    .replace(/int.ntalo/g, "inténtalo");

  return fixed.trim();
}
function verificationNotificationData(type, entrepreneurId, status = "") {
  return {
    type,
    entrepreneurId: String(entrepreneurId || ""),
    verificationStatus: String(status),
  };
}

const ADMIN_ROLE_ALIASES = [
  "admin",
  "adm",
  "administrador",
  "administrator",
  "ADMIN",
  "ADM",
  "Administrador",
  "Administrator",
];

const NUTRITIONIST_ROLE_ALIASES = [
  "nutricionista",
  "nutritionist",
  "Nutricionista",
  "Nutritionist",
];

function addFcmToken(tokens, value) {
  if (typeof value === "string" && value.trim()) {
    tokens.add(value.trim());
  }
}

function collectUserFcmTokens(tokens, data = {}) {
  addFcmToken(tokens, data.fcmToken);

  if (Array.isArray(data.fcmTokens)) {
    for (const token of data.fcmTokens) addFcmToken(tokens, token);
    return;
  }

  if (data.fcmTokens && typeof data.fcmTokens === "object") {
    for (const token of Object.values(data.fcmTokens)) {
      addFcmToken(tokens, token);
    }
  }
}

function isInvalidFcmTokenError(error) {
  const code = error?.code || "";
  return code === "messaging/registration-token-not-registered" ||
    code === "messaging/invalid-registration-token" ||
    code === "messaging/invalid-argument";
}

function failedFcmTokens(tokens, response) {
  const invalidTokens = [];

  response.responses.forEach((item, index) => {
    if (!item.success && isInvalidFcmTokenError(item.error)) {
      invalidTokens.push(tokens[index]);
    }
  });

  return invalidTokens;
}

async function pruneInvalidFcmTokens(userRefs, invalidTokens) {
  if (!invalidTokens.length || !userRefs.length) return;

  const uniqueTokens = [...new Set(invalidTokens)];
  const batch = db.batch();

  for (const ref of userRefs) {
    const snap = await ref.get();
    const data = snap.data() || {};
    const update = {
      fcmTokens: admin.firestore.FieldValue.arrayRemove(...uniqueTokens),
      fcmTokenUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    if (uniqueTokens.includes(data.fcmToken)) {
      update.fcmToken = admin.firestore.FieldValue.delete();
    }

    batch.set(ref, update, {merge: true});
  }

  await batch.commit();
  logger.info("Tokens FCM inválidos eliminados.", {
    tokenCount: uniqueTokens.length,
    userCount: userRefs.length,
  });
}

async function adminFcmTokens() {
  const roleQueries = ADMIN_ROLE_ALIASES.map((role) =>
    db.collection("users").where("role", "==", role).get()
  );

  const snapshots = await Promise.all([
    ...roleQueries,
    db.collection("users").where("isAdmin", "==", true).get(),
    db.collection("users").where("admin", "==", true).get(),
  ]);

  const tokens = new Set();
  const adminUserIds = new Set();
  const adminUserRefs = [];

  for (const snapshot of snapshots) {
    for (const userDoc of snapshot.docs) {
      adminUserIds.add(userDoc.id);
      adminUserRefs.push(userDoc.ref);
      collectUserFcmTokens(tokens, userDoc.data());
    }
  }

  logger.info("Tokens FCM de administradores resueltos.", {
    adminCount: adminUserIds.size,
    tokenCount: tokens.size,
  });

  return {
    tokens: [...tokens],
    userRefs: adminUserRefs,
  };
}

async function nutritionistFcmTokens() {
  const roleQueries = NUTRITIONIST_ROLE_ALIASES.map((role) =>
    db.collection("users").where("role", "==", role).get()
  );

  const snapshots = await Promise.all(roleQueries);
  const tokens = new Set();
  const nutritionistUserIds = new Set();
  const nutritionistUserRefs = [];

  for (const snapshot of snapshots) {
    for (const userDoc of snapshot.docs) {
      const data = userDoc.data() || {};

      if (data.isVerified !== true) continue;

      nutritionistUserIds.add(userDoc.id);
      nutritionistUserRefs.push(userDoc.ref);
      collectUserFcmTokens(tokens, data);
    }
  }

  logger.info("Tokens FCM de nutricionistas resueltos.", {
    nutritionistCount: nutritionistUserIds.size,
    tokenCount: tokens.size,
  });

  return {
    tokens: [...tokens],
    userRefs: nutritionistUserRefs,
  };
}

async function notifyAdminsAboutVerificationRequest({
  entrepreneurId,
  businessName,
}) {
  const {tokens, userRefs} = await adminFcmTokens();

  if (tokens.length === 0) {
    logger.warn("No hay administradores con token FCM registrado.", {
      entrepreneurId,
    });
    return;
  }

  const response = await messaging.sendEachForMulticast({
    tokens,
    notification: {
      title: "Nueva solicitud de aprobación",
      body: `${cleanText(businessName, "Un emprendimiento")} envía una solicitud para revisión.`,
    },
    data: verificationNotificationData(
      "entrepreneur_verification_submitted",
      entrepreneurId
    ),
    android: {
      priority: "high",
      notification: {
        channelId: "admin_channel",
        sound: "default",
      },
    },
  });

  logger.info("Notificación de solicitud enviada a administradores.", {
    entrepreneurId,
    successCount: response.successCount,
    failureCount: response.failureCount,
  });

  await pruneInvalidFcmTokens(userRefs, failedFcmTokens(tokens, response));
}

function productNotificationData(
  type,
  productId,
  entrepreneurId,
  status = "",
  targetUserId = ""
) {
  return {
    type,
    productId: String(productId || ""),
    entrepreneurId: String(entrepreneurId || ""),
    targetUserId: String(targetUserId || ""),
    validationStatus: String(status || ""),
  };
}

exports.saveFcmTokenFromRequest = onCall(
  {region: FIRESTORE_TRIGGER_REGION},
  async (request) => {
    const uid = request.auth?.uid;
    const token = String(request.data?.token || "").trim();

    if (!uid) {
      throw new HttpsError("unauthenticated", "Debes iniciar sesión.");
    }

    if (!token) {
      throw new HttpsError("invalid-argument", "Token FCM requerido.");
    }

    const userRef = db.collection("users").doc(uid);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      logger.info("FCM omitido: usuario sin perfil registrado.", {uid});
      return {saved: false, reason: "missing-user-profile"};
    }

    const role = String(userDoc.data()?.role || "").trim();
    if (!role) {
      logger.info("FCM omitido: usuario sin rol registrado.", {uid});
      return {saved: false, reason: "missing-role"};
    }

    const refsToClean = new Map();
    const arrayMatches = await db.collection("users")
      .where("fcmTokens", "array-contains", token)
      .get();
    const singleMatches = await db.collection("users")
      .where("fcmToken", "==", token)
      .get();

    for (const doc of [...arrayMatches.docs, ...singleMatches.docs]) {
      if (doc.id !== uid) refsToClean.set(doc.id, doc.ref);
    }

    const batch = db.batch();
    for (const ref of refsToClean.values()) {
      batch.update(ref, {
        fcmToken: admin.firestore.FieldValue.delete(),
        fcmTokens: admin.firestore.FieldValue.arrayRemove(token),
        fcmTokenUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    batch.update(userRef, {
      fcmToken: token,
      fcmTokens: [token],
      fcmTokenUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    await batch.commit();

    logger.info("Token FCM sincronizado para usuario activo.", {
      uid,
      cleanedUsers: refsToClean.size,
    });

    return {saved: true, cleanedUsers: refsToClean.size};
  }
);

exports.removeFcmTokenFromRequest = onCall(
  {region: FIRESTORE_TRIGGER_REGION},
  async (request) => {
    const uid = request.auth?.uid;
    const token = String(request.data?.token || "").trim();

    if (!uid) {
      throw new HttpsError("unauthenticated", "Debes iniciar sesión.");
    }

    if (!token) {
      throw new HttpsError("invalid-argument", "Token FCM requerido.");
    }

    const refsToClean = new Map();
    const arrayMatches = await db.collection("users")
      .where("fcmTokens", "array-contains", token)
      .get();
    const singleMatches = await db.collection("users")
      .where("fcmToken", "==", token)
      .get();

    for (const doc of [...arrayMatches.docs, ...singleMatches.docs]) {
      refsToClean.set(doc.id, doc.ref);
    }

    if (refsToClean.size === 0) {
      logger.info("Token FCM no estaba registrado al cerrar sesión.", {uid});
      return {removed: true, cleanedUsers: 0};
    }

    const batch = db.batch();
    for (const ref of refsToClean.values()) {
      batch.update(ref, {
        fcmToken: admin.firestore.FieldValue.delete(),
        fcmTokens: admin.firestore.FieldValue.arrayRemove(token),
        fcmTokenUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();

    logger.info("Token FCM removido al cerrar sesión.", {
      uid,
      cleanedUsers: refsToClean.size,
    });

    return {removed: true, cleanedUsers: refsToClean.size};
  }
);
async function userFcmTokens(userId) {
  if (!userId) return {tokens: [], userRef: null};

  const userDoc = await db.collection("users").doc(userId).get();
  const tokens = new Set();
  collectUserFcmTokens(tokens, userDoc.data() || {});

  return {
    tokens: [...tokens],
    userRef: userDoc.ref,
  };
}

async function notifyNutritionistsAboutProductSubmitted({
  productId,
  productName,
  entrepreneurId,
}) {
  const {tokens, userRefs} = await nutritionistFcmTokens();
  const {tokens: entrepreneurTokens} = await userFcmTokens(entrepreneurId);
  const excludedTokens = new Set(entrepreneurTokens);
  const targetTokens = tokens.filter((token) => !excludedTokens.has(token));

  if (targetTokens.length === 0) {
    logger.warn("No hay nutricionistas con token FCM disponible para este producto.", {
      productId,
      entrepreneurId,
      excludedTokenCount: excludedTokens.size,
    });
    return;
  }

  const response = await messaging.sendEachForMulticast({
    tokens: targetTokens,
    notification: {
      title: "Producto pendiente de validación",
      body: `${cleanText(productName, "Un producto")} fue enviado para revisión nutricional.`,
    },
    data: productNotificationData(
      "product_validation_submitted",
      productId,
      entrepreneurId,
      "pending",
      "nutritionists"
    ),
    android: {
      priority: "high",
      notification: {
        channelId: "orders_channel",
        sound: "default",
      },
    },
  });

  logger.info("Notificación de producto pendiente enviada a nutricionistas.", {
    productId,
    successCount: response.successCount,
    failureCount: response.failureCount,
    excludedTokenCount: excludedTokens.size,
  });

  await pruneInvalidFcmTokens(userRefs, failedFcmTokens(targetTokens, response));
}

async function notifyEntrepreneurAboutProductValidationResult({
  productId,
  productName,
  entrepreneurId,
  status,
  comment = "",
}) {
  const userDoc = await db.collection("users").doc(entrepreneurId).get();
  const tokens = new Set();
  collectUserFcmTokens(tokens, userDoc.data() || {});

  if (tokens.size === 0) {
    logger.warn("Emprendedor sin token FCM para resultado de producto.", {
      productId,
      entrepreneurId,
      status,
    });
    return;
  }

  const isApproved = status === "approved";
  const cleanComment = cleanText(comment);

  const response = await messaging.sendEachForMulticast({
    tokens: [...tokens],
    notification: {
      title: isApproved
        ? "Producto aprobado"
        : "Producto rechazado",
      body: isApproved
        ? `${cleanText(productName, "Tu producto")} ya está disponible para clientes.`
        : cleanComment
          ? `Corrige ${cleanText(productName, "tu producto")}: ${cleanComment}`
          : `${cleanText(productName, "Tu producto")} necesita correcciones.`,
    },
    data: productNotificationData(
      "product_validation_result",
      productId,
      entrepreneurId,
      status,
      entrepreneurId
    ),
    android: {
      priority: "high",
      notification: {
        channelId: "orders_channel",
        sound: "default",
      },
    },
  });

  logger.info("Notificación de resultado de producto enviada al emprendedor.", {
    productId,
    entrepreneurId,
    status,
    successCount: response.successCount,
    failureCount: response.failureCount,
  });

  await pruneInvalidFcmTokens([userDoc.ref], failedFcmTokens([...tokens], response));
}

async function notifyEntrepreneurAboutVerificationResult({
  entrepreneurId,
  status,
  message = "",
}) {
  const userDoc = await db.collection("users").doc(entrepreneurId).get();
  const tokens = new Set();
  collectUserFcmTokens(tokens, userDoc.data() || {});

  if (tokens.size === 0) {
    logger.warn("Emprendedor sin token FCM registrado.", {
      entrepreneurId,
      status,
    });
    return;
  }

  const isApproved = status === "approved";
  const rejectionMessage = cleanText(message);

  const payload = {
    notification: {
      title: isApproved
        ? "Tu negocio fue aprobado"
        : "Tu solicitud fue rechazada",
      body: isApproved
        ? "Ya puedes usar todas las funciones de NutriGo."
        : rejectionMessage
          ? `Debes corregir: ${rejectionMessage}`
          : "Revisa los datos de tu solicitud e inténtalo nuevamente.",
    },
    data: verificationNotificationData(
      "entrepreneur_verification_result",
      entrepreneurId,
      status
    ),
    android: {
      priority: "high",
      notification: {
        channelId: "orders_channel",
        sound: "default",
      },
    },
  };

  const response = await messaging.sendEachForMulticast({
    tokens: [...tokens],
    ...payload,
  });

  logger.info("Notificación de verificación enviada al emprendedor.", {
    entrepreneurId,
    status,
    successCount: response.successCount,
    failureCount: response.failureCount,
  });
}


function nutritionistVerificationNotificationData(
  type,
  nutritionistId,
  status = ""
) {
  return {
    type,
    nutritionistId: String(nutritionistId || ""),
    targetUserId: String(nutritionistId || ""),
    verificationRole: "nutritionist",
    verificationStatus: String(status),
  };
}

async function notifyAdminsAboutNutritionistVerificationRequest({
  nutritionistId,
  nutritionistName,
  specialty,
}) {
  const {tokens, userRefs} = await adminFcmTokens();

  if (tokens.length === 0) {
    logger.warn("No hay administradores con token FCM registrado.", {
      nutritionistId,
    });
    return;
  }

  const displayName = cleanText(nutritionistName, "Un nutricionista");
  const specialtyText = cleanText(specialty) ? ` Especialidad: ${cleanText(specialty)}.` : "";

  const response = await messaging.sendEachForMulticast({
    tokens,
    notification: {
      title: "Nueva solicitud de nutricionista",
      body: `${displayName} envió una solicitud para revisión.${specialtyText}`,
    },
    data: nutritionistVerificationNotificationData(
      "nutritionist_verification_submitted",
      nutritionistId,
      "pending"
    ),
    android: {
      priority: "high",
      notification: {
        channelId: "admin_channel",
        sound: "default",
      },
    },
  });

  logger.info("Notificación de solicitud de nutricionista enviada a administradores.", {
    nutritionistId,
    successCount: response.successCount,
    failureCount: response.failureCount,
  });

  await pruneInvalidFcmTokens(userRefs, failedFcmTokens(tokens, response));
}

async function notifyNutritionistAboutVerificationResult({
  nutritionistId,
  status,
  message = "",
}) {
  const userDoc = await db.collection("users").doc(nutritionistId).get();
  const tokens = new Set();
  collectUserFcmTokens(tokens, userDoc.data() || {});

  if (tokens.size === 0) {
    logger.warn("Nutricionista sin token FCM registrado.", {
      nutritionistId,
      status,
    });
    return;
  }

  const isApproved = status === "approved";
  const rejectionMessage = cleanText(message);

  const payload = {
    notification: {
      title: isApproved
        ? "Tu perfil profesional fue aprobado"
        : "Tu solicitud profesional fue rechazada",
      body: isApproved
        ? "Ya puedes recibir citas y atender pacientes en NutriGo."
        : rejectionMessage
          ? `Debes corregir: ${rejectionMessage}`
          : "Revisa los datos de tu perfil profesional e inténtalo nuevamente.",
    },
    data: nutritionistVerificationNotificationData(
      "nutritionist_verification_result",
      nutritionistId,
      status
    ),
    android: {
      priority: "high",
      notification: {
        channelId: "orders_channel",
        sound: "default",
      },
    },
  };

  const response = await messaging.sendEachForMulticast({
    tokens: [...tokens],
    ...payload,
  });

  logger.info("Notificación de verificación enviada al nutricionista.", {
    nutritionistId,
    status,
    successCount: response.successCount,
    failureCount: response.failureCount,
  });
}

function appointmentTimestampToDate(value) {
  if (value && typeof value.toDate === "function") {
    return value.toDate();
  }

  const parsed = new Date(value);
  if (!Number.isNaN(parsed.getTime())) return parsed;

  return new Date();
}

function addMinutes(date, minutes) {
  return new Date(date.getTime() + minutes * 60 * 1000);
}

function appointmentDateParts(value) {
  const date = appointmentTimestampToDate(value);
  const formatter = new Intl.DateTimeFormat("en-CA", {
    timeZone: "America/Guayaquil",
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
    hour12: false,
    hourCycle: "h23",
  });
  const parts = formatter.formatToParts(date).reduce((result, part) => {
    if (part.type !== "literal") result[part.type] = part.value;
    return result;
  }, {});

  return {
    year: Number(parts.year),
    month: Number(parts.month),
    day: Number(parts.day),
    hour: Number(parts.hour),
    minute: Number(parts.minute),
  };
}

function appointmentCalendarDateTime(value, minutesToAdd = 0) {
  const date = addMinutes(appointmentTimestampToDate(value), minutesToAdd);
  const parts = appointmentDateParts(date);
  const pad = (input) => String(input).padStart(2, "0");

  return `${parts.year}-${pad(parts.month)}-${pad(parts.day)}T` +
    `${pad(parts.hour)}:${pad(parts.minute)}:00-05:00`;
}

function meetingEntryPoint(eventData) {
  const entryPoints = eventData.conferenceData?.entryPoints || [];
  const videoEntry = entryPoints.find((entry) => entry.entryPointType === "video");
  return eventData.hangoutLink || videoEntry?.uri || "";
}

async function createGoogleMeetEvent(appointmentId, data) {
  const configuredCalendarId = String(googleCalendarId || "").trim();
  const clientId = GOOGLE_CLIENT_ID.value();
  const clientSecret = GOOGLE_CLIENT_SECRET.value();
  const refreshToken = GOOGLE_REFRESH_TOKEN.value();

  if (!clientId || !clientSecret || !refreshToken) {
    throw new Error(
      "Faltan secretos de Google Calendar para generar Meet."
    );
  }

  const calendar = googleCalendarClient();
  const startDateTime = appointmentCalendarDateTime(data.appointmentDate);
  const endDateTime = appointmentCalendarDateTime(data.appointmentDate, 60);

  const requestBody = {
    summary: `Cita NutriGo - ${data.clientName || "Cliente"}`,
    description:
      `Cita virtual con ${data.nutritionistName || "nutricionista"}.\n` +
      `ID de cita: ${appointmentId}`,
    start: {
      dateTime: startDateTime,
      timeZone: "America/Guayaquil",
    },
    end: {
      dateTime: endDateTime,
      timeZone: "America/Guayaquil",
    },
    conferenceData: {
      createRequest: {
        requestId: `nutrigo-${appointmentId}`,
        conferenceSolutionKey: {
          type: "hangoutsMeet",
        },
      },
    },
  };

  if (!configuredCalendarId) {
    throw new Error(
      "Falta GOOGLE_CALENDAR_ID para crear la cita en el calendario correcto."
    );
  }

  const response = await calendar.events.insert({
    calendarId: configuredCalendarId,
    conferenceDataVersion: 1,
    requestBody,
  });
  const usedCalendarId = configuredCalendarId;

  const eventData = response?.data || {};
  const meetLink = meetingEntryPoint(eventData);

  if (!meetLink) {
    throw new Error("Google Calendar no devolvió enlace de Meet.");
  }

  return {
    meetLink,
    eventId: eventData.id || "",
    calendarId: usedCalendarId,
  };
}

function googleCalendarClient() {
  const clientId = GOOGLE_CLIENT_ID.value();
  const clientSecret = GOOGLE_CLIENT_SECRET.value();
  const refreshToken = GOOGLE_REFRESH_TOKEN.value();

  if (!clientId || !clientSecret || !refreshToken) {
    throw new Error("Faltan secretos de Google Calendar.");
  }

  const auth = new google.auth.OAuth2(clientId, clientSecret);
  auth.setCredentials({refresh_token: refreshToken});
  return google.calendar({version: "v3", auth});
}

function appointmentCalendarId(data) {
  return String(data?.googleCalendarId || googleCalendarId || "").trim();
}

function appointmentCalendarEventId(data) {
  return String(data?.googleCalendarEventId || "").trim();
}

function appointmentStatusCalendarLabel(status) {
  switch (String(status || "").trim()) {
    case "pending":
      return "Pendiente";
    case "confirmed":
      return "Confirmada";
    case "completed":
      return "Completada";
    case "cancelled":
      return "Cancelada";
    case "noShow":
      return "No asistió";
    default:
      return "Cita";
  }
}

function appointmentCalendarSummary(appointmentId, data) {
  const clientName = cleanText(data?.clientName, "Cliente");
  const status = String(data?.status || "").trim();
  const statusLabel = appointmentStatusCalendarLabel(status);
  if (status === "cancelled") return `CANCELADA - Cita NutriGo - ${clientName}`;
  if (status === "completed") return `COMPLETADA - Cita NutriGo - ${clientName}`;
  if (status === "confirmed") return `CONFIRMADA - Cita NutriGo - ${clientName}`;
  return `${statusLabel} - Cita NutriGo - ${clientName}`;
}

function appointmentCalendarDescription(appointmentId, data) {
  const clientName = cleanText(data?.clientName, "Cliente");
  const nutritionistName = cleanText(data?.nutritionistName, "nutricionista");
  const statusLabel = appointmentStatusCalendarLabel(data?.status);
  const mode = String(data?.consultationMode || "virtual");
  const notes = cleanText(data?.notes || data?.appointmentInstructions || "");
  const meetingLink = String(data?.meetingLink || "").trim();
  const lines = [
    `Estado: ${statusLabel}`,
    `Cliente: ${clientName}`,
    `Nutricionista: ${nutritionistName}`,
    `Modalidad: ${mode}`,
    `ID de cita: ${appointmentId}`,
  ];

  if (meetingLink) lines.push(`Meet: ${meetingLink}`);
  if (notes) lines.push(`Notas: ${notes}`);
  if (String(data?.status || "") === "cancelled") {
    lines.push("Esta cita fue cancelada en NutriGo.");
  }

  return lines.join("\n");
}

function appointmentCalendarPatchBody(appointmentId, data) {
  return {
    summary: appointmentCalendarSummary(appointmentId, data),
    description: appointmentCalendarDescription(appointmentId, data),
    start: {
      dateTime: appointmentCalendarDateTime(data.appointmentDate),
      timeZone: "America/Guayaquil",
    },
    end: {
      dateTime: appointmentCalendarDateTime(data.appointmentDate, 60),
      timeZone: "America/Guayaquil",
    },
  };
}

async function updateGoogleCalendarAppointmentEvent(appointmentId, data) {
  const calendarId = appointmentCalendarId(data);
  const eventId = appointmentCalendarEventId(data);
  if (!calendarId || !eventId) return false;

  const calendar = googleCalendarClient();
  await calendar.events.patch({
    calendarId,
    eventId,
    requestBody: appointmentCalendarPatchBody(appointmentId, data),
  });
  return true;
}

async function deleteGoogleCalendarAppointmentEvent(appointmentId, data) {
  const calendarId = appointmentCalendarId(data);
  const eventId = appointmentCalendarEventId(data);
  if (!calendarId || !eventId) return false;

  const calendar = googleCalendarClient();
  try {
    await calendar.events.delete({calendarId, eventId});
    return true;
  } catch (error) {
    if (error?.code === 404 || error?.response?.status === 404) return false;
    throw error;
  }
}
function appointmentCalendarFieldsChanged(before, after) {
  const watchedFields = [
    "status",
    "appointmentDate",
    "clientName",
    "nutritionistName",
    "consultationMode",
    "meetingLink",
    "notes",
    "appointmentInstructions",
  ];

  return watchedFields.some((field) => {
    const beforeValue = before?.[field];
    const afterValue = after?.[field];

    if (beforeValue && typeof beforeValue.toMillis === "function" &&
        afterValue && typeof afterValue.toMillis === "function") {
      return beforeValue.toMillis() !== afterValue.toMillis();
    }

    return String(beforeValue ?? "") !== String(afterValue ?? "");
  });
}
async function getNutritionistManualMeetingLink(data) {
  const nutritionistUserId = String(data.nutritionistUserId || "").trim();
  if (!nutritionistUserId) return "";

  const nutritionistDoc = await db
    .collection("nutritionists")
    .doc(nutritionistUserId)
    .get();

  const link = String(nutritionistDoc.data()?.meetingLink || "").trim();
  return link;
}

async function resolveCallableAuth(request) {
  if (request.auth) return request.auth;

  const idToken = String(request.data?.idToken || "").trim();
  if (!idToken) return null;

  try {
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    return {uid: decodedToken.uid, token: decodedToken};
  } catch (error) {
    logger.warn("No se pudo verificar el idToken manual del callable", {
      message: error.message,
    });
    return null;
  }
}

exports.createOrderPaymentIntent = onCall(async (request) => {
  const auth = request.auth;

  if (!auth) {
    throw new HttpsError("unauthenticated", "Usuario no autenticado.");
  }

  const data = request.data || {};
  const amount = Number(data.amount);
  const currency = data.currency || "usd";

  if (isNaN(amount) || amount <= 0) {
    throw new HttpsError("invalid-argument", "El monto debe ser mayor a 0.");
  }

  try {
    const paymentIntent = await stripe.paymentIntents.create({
      amount: amount,
      currency,
      automatic_payment_methods: {enabled: true},
      metadata: {
        clientUserId: auth.uid,
        type: "order",
      },
    });

    logger.info("PaymentIntent de pedido creado con éxito", {
      id: paymentIntent.id,
      amount: amount,
      user: auth.uid,
    });

    return {
      clientSecret: paymentIntent.client_secret,
      paymentIntentId: paymentIntent.id,
    };
  } catch (error) {
    logger.error("Error en Stripe para pedido:", error);

    throw new HttpsError(
      "internal",
      error.message || "Error al procesar el pago del pedido con Stripe."
    );
  }
});

function numericValue(value) {
  if (value && typeof value === "object" && "value" in value) {
    return Number(value.value);
  }
  return Number(value);
}

function resolveAppointmentAmount(data = {}) {
  const rawAmount = data.amount ?? data.amountInCents ?? data.data?.amount ?? data.data?.amountInCents;
  return numericValue(rawAmount);
}

async function createAppointmentPaymentIntentResponse(auth, data = {}) {
  const amount = resolveAppointmentAmount(data);
  const currency = data.currency || data.data?.currency || "usd";
  const nutritionistUserId = String(
    data.nutritionistUserId || data.data?.nutritionistUserId || ""
  ).trim();

  if (isNaN(amount) || amount <= 0) {
    logger.warn("Monto inválido al crear PaymentIntent de cita.", {
      receivedKeys: Object.keys(data || {}),
      amount: data.amount,
      amountInCents: data.amountInCents,
      nestedAmount: data.data?.amount,
      nestedAmountInCents: data.data?.amountInCents,
    });
    throw new HttpsError("invalid-argument", "El monto debe ser mayor a 0.");
  }

  if (!nutritionistUserId) {
    throw new HttpsError(
      "invalid-argument",
      "El nutricionista es requerido para procesar la cita."
    );
  }

  try {
    const paymentIntent = await stripe.paymentIntents.create({
      amount: amount,
      currency,
      automatic_payment_methods: {enabled: true},
      metadata: {
        clientUserId: auth.uid,
        nutritionistUserId,
        type: "appointment",
      },
    });

    logger.info("PaymentIntent de cita creado con éxito", {
      id: paymentIntent.id,
      amount: amount,
      user: auth.uid,
      nutritionistUserId,
    });

    return {
      clientSecret: paymentIntent.client_secret,
      paymentIntentId: paymentIntent.id,
    };
  } catch (error) {
    logger.error("Error en Stripe para cita:", error);

    throw new HttpsError(
      "internal",
      error.message || "Error al procesar el pago de la cita con Stripe."
    );
  }
}

function appointmentHttpStatus(errorCode) {
  switch (errorCode) {
  case "unauthenticated":
    return 401;
  case "invalid-argument":
    return 400;
  default:
    return 500;
  }
}

exports.createAppointmentPaymentIntent = onCall(async (request) => {
  const auth = await resolveCallableAuth(request);

  if (!auth) {
    throw new HttpsError("unauthenticated", "Usuario no autenticado.");
  }

  return createAppointmentPaymentIntentResponse(auth, request.data || {});
});

exports.createAppointmentPaymentIntentHttp = onRequest(
  {cors: true, invoker: "public"},
  async (request, response) => {
    try {
      const data = request.body?.data || request.body || {};
      const auth = await resolveCallableAuth({data});

      if (!auth) {
        throw new HttpsError("unauthenticated", "Usuario no autenticado.");
      }

      const result = await createAppointmentPaymentIntentResponse(auth, data);
      response.status(200).json({result});
    } catch (error) {
      const code = error.code || "internal";
      response.status(appointmentHttpStatus(code)).json({
        error: {
          status: String(code).toUpperCase().replace(/-/g, "_"),
          message: error.message || "Error al procesar el pago de la cita.",
        },
      });
    }
  }
);

function orderNotificationData(type, orderId, orderNumber = "", targetUserId = "", newStatus = "") {
  return {
    type: String(type || ""),
    orderId: String(orderId || ""),
    orderNumber: String(orderNumber || ""),
    targetUserId: String(targetUserId || ""),
    newStatus: String(newStatus || ""),
  };
}

async function resolveBusinessName(businessUserId) {
  if (!businessUserId) return "el emprendimiento";

  try {
    const snapshot = await db.collection("business_profiles")
      .where("userId", "==", businessUserId)
      .limit(1)
      .get();

    if (!snapshot.empty) {
      const name = String(snapshot.docs[0].data().name || "").trim();
      if (name) return cleanText(name, "el emprendimiento");
    }

    const directDoc = await db.collection("business_profiles")
      .doc(businessUserId)
      .get();
    const directName = String(directDoc.data()?.name || "").trim();
    if (directName) return cleanText(directName, "el emprendimiento");
  } catch (error) {
    logger.warn("No se pudo resolver el nombre del negocio para pedido.", {
      businessUserId,
      error: error.message,
    });
  }

  return "el emprendimiento";
}

function orderStatusNotificationPayload({orderLabel, businessName, newStatus}) {
  switch (newStatus) {
  case "confirmed":
    return {
      title: "Pedido confirmado",
      body: `Tu pedido ${orderLabel} fue confirmado por ${businessName}.`,
    };
  case "preparing":
    return {
      title: "Pedido en preparaci\u00f3n",
      body: `${businessName} ya est\u00e1 preparando tu pedido.`,
    };
  case "shipped":
    return {
      title: "Pedido en camino",
      body: `Tu pedido ${orderLabel} ya sali\u00f3 hacia tu ubicaci\u00f3n.`,
    };
  case "delivered":
    return {
      title: "Pedido entregado",
      body: `Tu pedido ${orderLabel} fue entregado. \u00a1Buen provecho!`,
    };
  case "cancelled":
    return {
      title: "Pedido cancelado",
      body: `${businessName} cancel\u00f3 tu pedido ${orderLabel}.`,
    };
  default:
    return {
      title: "Pedido actualizado",
      body: `Tu pedido ${orderLabel} tiene una nueva actualizaci\u00f3n.`,
    };
  }
}

async function sendOrderNotificationToUser({
  userId,
  title,
  body,
  type,
  orderId,
  orderNumber = "",
  newStatus = "",
}) {
  if (!userId) return;

  const userDoc = await db.collection("users").doc(userId).get();
  const tokens = new Set();
  collectUserFcmTokens(tokens, userDoc.data() || {});

  if (tokens.size === 0) {
    logger.warn("Usuario sin token FCM para notificaci\u00f3n de pedido.", {
      userId,
      orderId,
      type,
    });
    return;
  }

  const tokenList = [...tokens];
  const response = await messaging.sendEachForMulticast({
    tokens: tokenList,
    notification: {title, body},
    data: orderNotificationData(type, orderId, orderNumber, userId, newStatus),
    android: {
      priority: "high",
      notification: {
        channelId: "orders_channel",
        sound: "default",
      },
    },
  });

  logger.info("Notificaci\u00f3n de pedido enviada.", {
    userId,
    orderId,
    type,
    successCount: response.successCount,
    failureCount: response.failureCount,
  });

  await pruneInvalidFcmTokens([userDoc.ref], failedFcmTokens(tokenList, response));
}

exports.notifyEntrepreneurOnOrderCreated = onDocumentCreated({document: "orders/{orderId}", region: FIRESTORE_TRIGGER_REGION},
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const orderId = event.params.orderId;
    const orderData = snapshot.data() || {};
    const businessUserId = String(orderData.businessUserId || "").trim();

    if (!businessUserId) {
      logger.warn("Pedido sin businessUserId. No se puede numerar ni notificar.", {orderId});
      return;
    }

    let orderNumber = Number(orderData.orderNumber || 0);

    if (!orderNumber) {
      const counterRef = db.collection("order_counters").doc(businessUserId);
      await db.runTransaction(async (transaction) => {
        const freshOrder = await transaction.get(snapshot.ref);
        const existingNumber = Number(freshOrder.data()?.orderNumber || 0);

        if (existingNumber) {
          orderNumber = existingNumber;
          return;
        }

        const counterSnapshot = await transaction.get(counterRef);
        const currentLastNumber = Number(counterSnapshot.data()?.lastOrderNumber || 0);
        orderNumber = currentLastNumber + 1;

        transaction.set(counterRef, {
          businessUserId,
          lastOrderNumber: orderNumber,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        }, {merge: true});

        transaction.update(snapshot.ref, {
          orderNumber,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      });
    }

    const orderLabel = orderNumber ? `#${String(orderNumber).padStart(4, "0")}` : orderId;
    await sendOrderNotificationToUser({
      userId: businessUserId,
      title: "Nuevo pedido recibido",
      body: `Has recibido un nuevo pedido ${orderLabel}.`,
      type: "new_order",
      orderId,
      orderNumber: orderNumber ? String(orderNumber) : "",
    });
  });

exports.notifyClientOnOrderStatusUpdated = onDocumentUpdated({document: "orders/{orderId}", region: FIRESTORE_TRIGGER_REGION},
  async (event) => {
    const before = event.data?.before?.data() || {};
    const after = event.data?.after?.data() || {};
    const previousStatus = String(before.status || "");
    const newStatus = String(after.status || "");

    if (!newStatus || previousStatus === newStatus) return;

    const orderId = event.params.orderId;
    const clientUserId = String(after.userId || "").trim();
    const businessUserId = String(after.businessUserId || "").trim();
    const orderNumber = after.orderNumber ? String(after.orderNumber) : "";
    const orderLabel = orderNumber ? `#${orderNumber.padStart(4, "0")}` : orderId;
    const businessName = await resolveBusinessName(businessUserId);
    const notification = orderStatusNotificationPayload({
      orderLabel,
      businessName,
      newStatus,
    });

    await sendOrderNotificationToUser({
      userId: clientUserId,
      title: notification.title,
      body: notification.body,
      type: "order_status",
      orderId,
      orderNumber,
      newStatus,
    });
  });
exports.sendNotificationOnRequest = onDocumentCreated({document: "notification_requests/{requestId}", region: FIRESTORE_TRIGGER_REGION},
  async (event) => {
    const snapshot = event.data;

    if (!snapshot) {
      logger.warn("Evento sin snapshot.");
      return;
    }

    const requestId = event.params.requestId;
    const data = snapshot.data();

    const fcmToken = data.fcmToken;
    const title = data.title || "Notificación";
    const body = data.body || "Tienes una nueva actualización.";
    const type = data.type || "general";

    if (!fcmToken) {
      logger.warn("Solicitud sin fcmToken.", {requestId});

      await snapshot.ref.update({
        sent: false,
        error: "Solicitud sin fcmToken.",
        processedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return;
    }

    const message = {
      token: fcmToken,
      notification: {
        title,
        body,
      },
      data: {
        type: String(type),
        orderId: data.orderId ? String(data.orderId) : "",
        orderNumber: data.orderNumber ? String(data.orderNumber) : "",
        newStatus: data.newStatus ? String(data.newStatus) : "",
        targetUserId: data.targetUserId ? String(data.targetUserId) : "",
      },
      android: {
        priority: "high",
        notification: {
          channelId: "orders_channel",
          sound: "default",
        },
      },
    };

    try {
      const response = await messaging.send(message);

      logger.info("Notificación FCM enviada", {
        requestId,
        response,
        targetUserId: data.targetUserId || null,
        type,
      });

      await snapshot.ref.update({
        sent: true,
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
        messageId: response,
        error: null,
      });
    } catch (error) {
      logger.error("Error enviando notificación FCM", {
        requestId,
        error,
      });

      await snapshot.ref.update({
        sent: false,
        error: error.message || "Error desconocido al enviar FCM.",
        processedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
  }
);

exports.notifyAdminsOnEntrepreneurVerificationCreated = onDocumentCreated({document: "entrepreneur_verifications/{requestId}", region: FIRESTORE_TRIGGER_REGION},
  async (event) => {
    const snapshot = event.data;

    if (!snapshot) {
      logger.warn("Evento de solicitud de emprendedor sin snapshot.");
      return;
    }

    const data = snapshot.data() || {};
    const entrepreneurId =
      data.entrepreneurId || data.userId || event.params.requestId;

    try {
      await notifyAdminsAboutVerificationRequest({
        entrepreneurId,
        businessName: data.businessName,
      });
    } catch (error) {
      logger.error("No se pudo notificar la solicitud a administradores.", {
        entrepreneurId,
        error,
      });
    }
  }
);

exports.notifyAdminsOnEntrepreneurVerificationResubmitted = onDocumentUpdated({document: "entrepreneur_verifications/{requestId}", region: FIRESTORE_TRIGGER_REGION},
  async (event) => {
    const before = event.data?.before.data() || {};
    const after = event.data?.after.data() || {};
    const previousStatus = String(before.status || "").trim().toLowerCase();
    const status = String(after.status || "").trim().toLowerCase();

    if (previousStatus === status) return;
    if (status !== "pending") return;
    if (previousStatus !== "rejected") return;

    const entrepreneurId =
      after.entrepreneurId || after.userId || event.params.requestId;

    try {
      await notifyAdminsAboutVerificationRequest({
        entrepreneurId,
        businessName: after.businessName,
      });
    } catch (error) {
      logger.error("No se pudo notificar el reenvío de solicitud a administradores.", {
        entrepreneurId,
        error,
      });
    }
  }
);
exports.notifyEntrepreneurOnVerificationStatusUpdated = onDocumentUpdated({document: "entrepreneur_verifications/{requestId}", region: FIRESTORE_TRIGGER_REGION},
  async (event) => {
    const before = event.data?.before.data() || {};
    const after = event.data?.after.data() || {};
    const previousStatus = String(before.status || "").trim().toLowerCase();
    const status = String(after.status || "").trim().toLowerCase();

    if (previousStatus === status) return;
    if (status !== "approved" && status !== "rejected") return;

    const entrepreneurId =
      after.entrepreneurId || after.userId || event.params.requestId;

    try {
      await notifyEntrepreneurAboutVerificationResult({
        entrepreneurId,
        status,
        message: after.message || after.verificationMessage || "",
      });
    } catch (error) {
      logger.error("No se pudo notificar el resultado al emprendedor.", {
        entrepreneurId,
        status,
        error,
      });
    }
  }
);

exports.notifyAdminsOnNutritionistVerificationCreated = onDocumentCreated({document: "nutritionist_verifications/{requestId}", region: FIRESTORE_TRIGGER_REGION},
  async (event) => {
    const snapshot = event.data;

    if (!snapshot) {
      logger.warn("Evento de solicitud de nutricionista sin snapshot.");
      return;
    }

    const data = snapshot.data() || {};
    const nutritionistId =
      data.nutritionistId || data.userId || event.params.requestId;

    try {
      await notifyAdminsAboutNutritionistVerificationRequest({
        nutritionistId,
        nutritionistName: data.name,
        specialty: data.specialty,
      });
    } catch (error) {
      logger.error("No se pudo notificar la solicitud de nutricionista a administradores.", {
        nutritionistId,
        error,
      });
    }
  }
);

exports.notifyAdminsOnNutritionistVerificationResubmitted = onDocumentUpdated({document: "nutritionist_verifications/{requestId}", region: FIRESTORE_TRIGGER_REGION},
  async (event) => {
    const before = event.data?.before.data() || {};
    const after = event.data?.after.data() || {};
    const previousStatus = String(before.status || "").trim().toLowerCase();
    const status = String(after.status || "").trim().toLowerCase();

    if (previousStatus === status) return;
    if (status !== "pending") return;
    if (previousStatus !== "rejected") return;

    const nutritionistId =
      after.nutritionistId || after.userId || event.params.requestId;

    try {
      await notifyAdminsAboutNutritionistVerificationRequest({
        nutritionistId,
        nutritionistName: after.name,
        specialty: after.specialty,
      });
    } catch (error) {
      logger.error("No se pudo notificar el reenvío de solicitud de nutricionista a administradores.", {
        nutritionistId,
        error,
      });
    }
  }
);
exports.notifyNutritionistOnVerificationStatusUpdated = onDocumentUpdated({document: "nutritionist_verifications/{requestId}", region: FIRESTORE_TRIGGER_REGION},
  async (event) => {
    const before = event.data?.before.data() || {};
    const after = event.data?.after.data() || {};
    const previousStatus = String(before.status || "").trim().toLowerCase();
    const status = String(after.status || "").trim().toLowerCase();

    if (previousStatus === status) return;
    if (status !== "approved" && status !== "rejected") return;

    const nutritionistId =
      after.nutritionistId || after.userId || event.params.requestId;

    try {
      await notifyNutritionistAboutVerificationResult({
        nutritionistId,
        status,
        message: after.message || after.verificationMessage || "",
      });
    } catch (error) {
      logger.error("No se pudo notificar el resultado al nutricionista.", {
        nutritionistId,
        status,
        error,
      });
    }
  }
);

exports.notifyNutritionistsOnProductValidationCreated = onDocumentCreated({document: "products/{productId}", region: FIRESTORE_TRIGGER_REGION},
  async (event) => {
    const snapshot = event.data;

    if (!snapshot) {
      logger.warn("Evento de producto sin snapshot.");
      return;
    }

    const productId = event.params.productId;
    const data = snapshot.data() || {};
    const status = String(data.validationStatus || "").trim().toLowerCase();

    if (status !== "pending") return;

    try {
      await notifyNutritionistsAboutProductSubmitted({
        productId,
        productName: data.name,
        entrepreneurId: data.userId,
      });
    } catch (error) {
      logger.error("No se pudo notificar producto pendiente a nutricionistas.", {
        productId,
        error,
      });
    }
  }
);

exports.notifyNutritionistsOnProductValidationResubmitted = onDocumentUpdated({document: "products/{productId}", region: FIRESTORE_TRIGGER_REGION},
  async (event) => {
    const before = event.data?.before.data() || {};
    const after = event.data?.after.data() || {};
    const productId = event.params.productId;
    const previousStatus = String(before.validationStatus || "")
      .trim()
      .toLowerCase();
    const status = String(after.validationStatus || "").trim().toLowerCase();

    if (previousStatus === status) return;
    if (status !== "pending") return;

    try {
      await notifyNutritionistsAboutProductSubmitted({
        productId,
        productName: after.name,
        entrepreneurId: after.userId,
      });
    } catch (error) {
      logger.error("No se pudo notificar reenvío de producto a nutricionistas.", {
        productId,
        error,
      });
    }
  }
);

exports.notifyEntrepreneurOnProductValidationStatusUpdated = onDocumentUpdated({document: "products/{productId}", region: FIRESTORE_TRIGGER_REGION},
  async (event) => {
    const before = event.data?.before.data() || {};
    const after = event.data?.after.data() || {};
    const productId = event.params.productId;
    const previousStatus = String(before.validationStatus || "")
      .trim()
      .toLowerCase();
    const status = String(after.validationStatus || "").trim().toLowerCase();

    if (previousStatus === status) return;
    if (status !== "approved" && status !== "rejected") return;

    try {
      await notifyEntrepreneurAboutProductValidationResult({
        productId,
        productName: after.name,
        entrepreneurId: after.userId,
        status,
        comment: after.validationComment,
      });
    } catch (error) {
      logger.error("No se pudo notificar resultado de producto al emprendedor.", {
        productId,
        status,
        error,
      });
    }
  }
);

function appointmentNotificationData(
  type,
  appointmentId,
  targetUserId,
  clientUserId = "",
  status = ""
) {
  return {
    type: String(type || ""),
    appointmentId: String(appointmentId || ""),
    targetUserId: String(targetUserId || ""),
    clientUserId: String(clientUserId || ""),
    appointmentStatus: String(status || ""),
  };
}

function formatAppointmentDateLabel(value) {
  const parts = appointmentDateParts(value);
  const months = [
    "ene", "feb", "mar", "abr", "may", "jun",
    "jul", "ago", "sept", "oct", "nov", "dic",
  ];
  const pad = (input) => String(input).padStart(2, "0");

  return `${pad(parts.day)} ${months[parts.month - 1]} ${parts.year}, ` +
    `${pad(parts.hour)}:${pad(parts.minute)}`;
}

async function sendAppointmentNotificationToNutritionist({
  appointmentId,
  appointmentData,
}) {
  const nutritionistUserId = String(
    appointmentData.nutritionistUserId || ""
  ).trim();

  if (!nutritionistUserId) {
    logger.warn("Cita sin nutritionistUserId para notificación.", {
      appointmentId,
    });
    return;
  }

  const userDoc = await db.collection("users").doc(nutritionistUserId).get();
  const tokens = new Set();
  collectUserFcmTokens(tokens, userDoc.data() || {});

  if (tokens.size === 0) {
    logger.warn("Nutricionista sin token FCM para cita.", {
      appointmentId,
      nutritionistUserId,
    });
    return;
  }

  const clientName = cleanText(appointmentData.clientName, "Un cliente");
  const dateLabel = formatAppointmentDateLabel(appointmentData.appointmentDate);
  const tokenList = [...tokens];
  const response = await messaging.sendEachForMulticast({
    tokens: tokenList,
    notification: {
      title: "Nueva cita agendada",
      body: `${clientName} agend\u00f3 una cita para ${dateLabel}.`,
    },
    data: appointmentNotificationData(
      "appointment_created",
      appointmentId,
      nutritionistUserId,
      appointmentData.clientUserId,
      appointmentData.status || "pending"
    ),
    android: {
      priority: "high",
      notification: {
        channelId: "appointments_channel",
        sound: "default",
      },
    },
  });

  logger.info("Notificación de cita enviada al nutricionista.", {
    appointmentId,
    nutritionistUserId,
    successCount: response.successCount,
    failureCount: response.failureCount,
  });

  await pruneInvalidFcmTokens([userDoc.ref], failedFcmTokens(tokenList, response));
}

function appointmentStatusNotificationPayload({
  appointmentData,
  newStatus,
  targetRole,
}) {
  const clientName = cleanText(appointmentData.clientName, "El cliente");
  const nutritionistName = cleanText(
    appointmentData.nutritionistName,
    "El nutricionista"
  );
  const dateLabel = formatAppointmentDateLabel(appointmentData.appointmentDate);

  if (targetRole === "nutritionist" && newStatus === "cancelled") {
    return {
      title: "Cita cancelada",
      body: `${clientName} cancel\u00f3 la cita del ${dateLabel}.`,
    };
  }

  switch (newStatus) {
    case "confirmed":
      return {
        title: "Cita confirmada",
        body: `${nutritionistName} confirm\u00f3 tu cita del ${dateLabel}.`,
      };
    case "cancelled":
      return {
        title: "Cita cancelada",
        body: `${nutritionistName} cancel\u00f3 tu cita del ${dateLabel}.`,
      };
    case "completed":
      return {
        title: "Cita completada",
        body: `${nutritionistName} marc\u00f3 tu cita como completada.`,
      };
    case "noShow":
      return {
        title: "Cita marcada como no asistida",
        body: `${nutritionistName} registr\u00f3 que no asististe a la cita.`,
      };
    default:
      return {
        title: "Cita actualizada",
        body: `Tu cita del ${dateLabel} tiene una nueva actualizaci\u00f3n.`,
      };
  }
}

async function sendAppointmentNotificationToUser({
  userId,
  title,
  body,
  type,
  appointmentId,
  appointmentData,
  status = "",
}) {
  if (!userId) return;

  const userDoc = await db.collection("users").doc(userId).get();
  const tokens = new Set();
  collectUserFcmTokens(tokens, userDoc.data() || {});

  if (tokens.size === 0) {
    logger.warn("Usuario sin token FCM para notificación de cita.", {
      userId,
      appointmentId,
      type,
    });
    return;
  }

  const tokenList = [...tokens];
  const response = await messaging.sendEachForMulticast({
    tokens: tokenList,
    notification: {title, body},
    data: appointmentNotificationData(
      type,
      appointmentId,
      userId,
      appointmentData.clientUserId,
      status
    ),
    android: {
      priority: "high",
      notification: {
        channelId: "appointments_channel",
        sound: "default",
      },
    },
  });

  logger.info("Notificación de cita enviada.", {
    userId,
    appointmentId,
    type,
    status,
    successCount: response.successCount,
    failureCount: response.failureCount,
  });

  await pruneInvalidFcmTokens([userDoc.ref], failedFcmTokens(tokenList, response));
}

exports.notifyNutritionistOnAppointmentCreated = onDocumentCreated({document: "appointments/{appointmentId}", region: FIRESTORE_TRIGGER_REGION},
  async (event) => {
    const snapshot = event.data;

    if (!snapshot) {
      logger.warn("Evento de cita sin snapshot para notificación.");
      return;
    }

    const appointmentId = event.params.appointmentId;
    const appointmentData = snapshot.data() || {};

    try {
      await sendAppointmentNotificationToNutritionist({
        appointmentId,
        appointmentData,
      });
    } catch (error) {
      logger.error("No se pudo notificar la cita al nutricionista.", {
        appointmentId,
        error,
      });
    }
  }
);

exports.notifyAppointmentStatusUpdated = onDocumentUpdated({document: "appointments/{appointmentId}", region: FIRESTORE_TRIGGER_REGION},
  async (event) => {
    const before = event.data?.before?.data() || {};
    const after = event.data?.after?.data() || {};
    const previousStatus = String(before.status || "");
    const newStatus = String(after.status || "");

    if (!newStatus || previousStatus === newStatus) return;

    const appointmentId = event.params.appointmentId;
    const actor = String(after.statusUpdatedBy || "").trim();
    const clientUserId = String(after.clientUserId || "").trim();
    const nutritionistUserId = String(after.nutritionistUserId || "").trim();

    const targetRole = actor === "client" ? "nutritionist" : "client";
    const targetUserId = targetRole === "nutritionist"
      ? nutritionistUserId
      : clientUserId;

    if (!targetUserId) {
      logger.warn("Cita sin destinatario para notificación de estado.", {
        appointmentId,
        actor,
        newStatus,
      });
      return;
    }

    const notification = appointmentStatusNotificationPayload({
      appointmentData: after,
      newStatus,
      targetRole,
    });

    try {
      await sendAppointmentNotificationToUser({
        userId: targetUserId,
        title: notification.title,
        body: notification.body,
        type: "appointment_status_updated",
        appointmentId,
        appointmentData: after,
        status: newStatus,
      });
    } catch (error) {
      logger.error("No se pudo notificar cambio de estado de cita.", {
        appointmentId,
        targetUserId,
        newStatus,
        error,
      });
    }
  }
);

exports.generateMeetForVirtualAppointment = onDocumentWritten({
  document: "appointments/{appointmentId}",
  region: FIRESTORE_TRIGGER_REGION,
  secrets: googleCalendarSecrets,
}, async (event) => {
  const before = event.data?.before?.data() || null;
  const afterSnapshot = event.data?.after;
  const after = afterSnapshot?.data() || null;
  const appointmentId = event.params.appointmentId;

  if (!after || after.consultationMode !== "virtual") return;
  if (after.meetingLink || after.meetingLinkStatus === "ready") return;

  const previousStatus = String(before?.status || "");
  const newStatus = String(after.status || "");
  const wasCreated = !before;
  const wasConfirmed =
    newStatus === "confirmed" && previousStatus !== "confirmed";
  const isPaid = String(after.paymentStatus || "") === "paid";

  // Para citas nuevas: generar Meet apenas la cita virtual queda pagada.
  // Para citas antiguas: conservar soporte al confirmar la cita.
  if (!((wasCreated && isPaid) || wasConfirmed)) return;

  const appointmentRef = afterSnapshot.ref;

  await appointmentRef.update({
    meetingLinkStatus: "generating",
    meetingLinkError: null,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  try {
    const {meetLink, eventId, calendarId} = await createGoogleMeetEvent(
      appointmentId,
      after
    );

    const updateData = {
      meetingLink: meetLink,
      meetingLinkStatus: "ready",
      meetingLinkSource: "google_calendar",
      googleCalendarEventId: eventId,
      googleCalendarId: calendarId,
      meetingLinkError: null,
      meetingLinkGeneratedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    await appointmentRef.update(updateData);

    await sendAppointmentNotificationToUser({
      userId: String(after.clientUserId || ""),
      title: "Enlace de Meet listo",
      body: "Tu enlace de videollamada ya está disponible para la cita agendada.",
      type: "appointment_meet_ready",
      appointmentId,
      appointmentData: {...after, ...updateData},
      status: newStatus,
    });

    logger.info("Enlace Meet generado para cita virtual agendada.", {
      appointmentId,
      eventId,
    });
  } catch (error) {
    logger.error("No se pudo generar enlace Meet.", {
      appointmentId,
      error,
    });

    const manualMeetingLink = await getNutritionistManualMeetingLink(after);

    if (manualMeetingLink) {
      const updateData = {
        meetingLink: manualMeetingLink,
        meetingLinkStatus: "ready",
        meetingLinkSource: "nutritionist_profile",
        meetingLinkError: null,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      await appointmentRef.update(updateData);

      await sendAppointmentNotificationToUser({
        userId: String(after.clientUserId || ""),
        title: "Enlace de videollamada listo",
        body: "El enlace de atención virtual ya está disponible para tu cita agendada.",
        type: "appointment_meet_ready",
        appointmentId,
        appointmentData: {...after, ...updateData},
        status: newStatus,
      });

      logger.info("Se usó enlace manual del perfil del nutricionista.", {
        appointmentId,
      });
      return;
    }

    await appointmentRef.update({
      meetingLinkStatus: "manual_required",
      meetingLinkError:
        error.message || "No se pudo generar el enlace de Meet.",
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }
});
exports.syncAppointmentCalendarEventOnUpdate = onDocumentUpdated({
  document: "appointments/{appointmentId}",
  region: FIRESTORE_TRIGGER_REGION,
  secrets: googleCalendarSecrets,
}, async (event) => {
  const before = event.data?.before?.data() || {};
  const after = event.data?.after?.data() || {};
  const appointmentId = event.params.appointmentId;

  if (!appointmentCalendarEventId(after)) return;
  if (!appointmentCalendarFieldsChanged(before, after)) return;

  try {
    const updated = await updateGoogleCalendarAppointmentEvent(
      appointmentId,
      after
    );

    if (updated) {
      logger.info("Evento de Google Calendar actualizado para cita.", {
        appointmentId,
        status: after.status || "",
      });
    }
  } catch (error) {
    logger.error("No se pudo actualizar evento de Google Calendar.", {
      appointmentId,
      error,
    });
  }
});

exports.deleteAppointmentCalendarEventOnDelete = onDocumentDeleted({
  document: "appointments/{appointmentId}",
  region: FIRESTORE_TRIGGER_REGION,
  secrets: googleCalendarSecrets,
}, async (event) => {
  const data = event.data?.data() || {};
  const appointmentId = event.params.appointmentId;

  try {
    const deleted = await deleteGoogleCalendarAppointmentEvent(
      appointmentId,
      data
    );

    if (deleted) {
      logger.info("Evento de Google Calendar eliminado para cita borrada.", {
        appointmentId,
      });
    }
  } catch (error) {
    logger.error("No se pudo eliminar evento de Google Calendar.", {
      appointmentId,
      error,
    });
  }
});

