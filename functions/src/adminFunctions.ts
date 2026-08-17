import * as functions from 'firebase-functions/v1';
import * as admin from 'firebase-admin';

const db = admin.firestore();
const region = functions.region('asia-southeast1');

function requireAdmin(context: functions.https.CallableContext): void {
  if (!context.auth?.token?.isAdmin) {
    throw new functions.https.HttpsError('permission-denied', 'Admin access required');
  }
}

function requireSuperAdmin(context: functions.https.CallableContext): void {
  if (context.auth?.token?.role !== 'superadmin') {
    throw new functions.https.HttpsError('permission-denied', 'Superadmin access required');
  }
}

async function writeAuditLog(
  context: functions.https.CallableContext,
  action: string,
  details: Record<string, unknown>,
  targetUid?: string,
  targetEmail?: string,
): Promise<void> {
  await db.collection('adminLogs').add({
    action,
    adminUid: context.auth!.uid,
    adminEmail: context.auth!.token.email ?? '',
    targetUid: targetUid ?? null,
    targetEmail: targetEmail ?? null,
    details: JSON.parse(JSON.stringify(details)),
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  });
}

// ── Grant Premium ────────────────────────────────────────────────────────────

export const adminGrantPremium = region.https.onCall(async (data, context) => {
  requireAdmin(context);

  const { uid, durationDays, reason, note } = data as {
    uid: string;
    durationDays: number;
    reason: string;
    note?: string;
  };

  if (!uid || !durationDays || !reason) {
    throw new functions.https.HttpsError('invalid-argument', 'uid, durationDays, reason required');
  }

  let targetEmail = '';
  try {
    const user = await admin.auth().getUser(uid);
    targetEmail = user.email ?? '';
  } catch {
    throw new functions.https.HttpsError('not-found', `User ${uid} not found`);
  }

  const now = new Date();
  const expiresAt = new Date(now.getTime() + durationDays * 86400 * 1000);

  // Same doc + schema the app's real IAP flow writes to (iap_service.dart
  // _persistSubscription), so an admin grant is indistinguishable from a
  // real purchase to the client's premium gate.
  const subscriptionRef = db.doc(`users/${uid}/meta/subscription`);
  await subscriptionRef.set({
    isPremium: true,
    productId: 'admin_grant',
    purchaseDate: now.toISOString(),
    expiryDate: expiresAt.toISOString(),
    platform: 'admin',
    grantedBy: context.auth!.uid,
    grantReason: reason,
    isManualGrant: true,
    note: note ?? null,
    cancelledAt: null,
  });

  await writeAuditLog(context, 'grant_premium', { durationDays, reason, note, expiresAt: expiresAt.toISOString() }, uid, targetEmail);

  return { success: true, expiresAt: expiresAt.toISOString() };
});

// ── Revoke Premium ───────────────────────────────────────────────────────────

export const adminRevokePremium = region.https.onCall(async (data, context) => {
  requireAdmin(context);

  const { uid, note } = data as { uid: string; note?: string };

  if (!uid) {
    throw new functions.https.HttpsError('invalid-argument', 'uid required');
  }

  let targetEmail = '';
  try {
    const user = await admin.auth().getUser(uid);
    targetEmail = user.email ?? '';
  } catch {
    throw new functions.https.HttpsError('not-found', `User ${uid} not found`);
  }

  const subscriptionRef = db.doc(`users/${uid}/meta/subscription`);
  await subscriptionRef.set(
    {
      isPremium: false,
      cancelledAt: admin.firestore.FieldValue.serverTimestamp(),
      note: note ?? null,
    },
    { merge: true },
  );

  await writeAuditLog(context, 'revoke_premium', { note }, uid, targetEmail);

  return { success: true };
});

// ── Set Role ─────────────────────────────────────────────────────────────────

export const adminSetRole = region.https.onCall(async (data, context) => {
  requireSuperAdmin(context);

  const { uid, role } = data as { uid: string; role: string };

  const validRoles = ['user', 'support', 'admin', 'superadmin'];
  if (!uid || !validRoles.includes(role)) {
    throw new functions.https.HttpsError('invalid-argument', 'uid and valid role required');
  }

  if (uid === context.auth!.uid) {
    throw new functions.https.HttpsError('invalid-argument', 'Cannot change your own role');
  }

  let targetEmail = '';
  try {
    const user = await admin.auth().getUser(uid);
    targetEmail = user.email ?? '';
  } catch {
    throw new functions.https.HttpsError('not-found', `User ${uid} not found`);
  }

  const claims = role === 'user'
    ? { role: 'user', isAdmin: false }
    : { role, isAdmin: true };

  await admin.auth().setCustomUserClaims(uid, claims);

  await writeAuditLog(context, 'set_role', { role }, uid, targetEmail);

  return { success: true };
});

// ── Get User ─────────────────────────────────────────────────────────────────

export const adminGetUser = region.https.onCall(async (data, context) => {
  requireAdmin(context);

  const { uid, email } = data as { uid?: string; email?: string };

  if (!uid && !email) {
    throw new functions.https.HttpsError('invalid-argument', 'uid or email required');
  }

  let authUser: admin.auth.UserRecord;
  try {
    authUser = uid
      ? await admin.auth().getUser(uid)
      : await admin.auth().getUserByEmail(email!);
  } catch {
    throw new functions.https.HttpsError('not-found', 'User not found');
  }

  const subscriptionSnap = await db.doc(`users/${authUser.uid}/meta/subscription`).get();
  const sub = subscriptionSnap.data();

  const serializeTimestamp = (ts: admin.firestore.Timestamp | undefined) =>
    ts ? ts.toDate().toISOString() : null;

  return {
    uid: authUser.uid,
    email: authUser.email ?? '',
    displayName: authUser.displayName ?? '',
    photoURL: authUser.photoURL ?? '',
    createdAt: authUser.metadata.creationTime ?? '',
    lastSignIn: authUser.metadata.lastSignInTime ?? '',
    role: authUser.customClaims?.['role'] ?? 'user',
    isAdmin: authUser.customClaims?.['isAdmin'] ?? false,
    subscription: sub
      ? {
          isActive: sub['isPremium'] ?? false,
          productId: sub['productId'] ?? '',
          expiresAt: sub['expiryDate'] ?? null,
          startedAt: sub['purchaseDate'] ?? null,
          isManualGrant: sub['isManualGrant'] ?? false,
          grantReason: sub['grantReason'] ?? null,
          grantedBy: sub['grantedBy'] ?? null,
          note: sub['note'] ?? null,
          cancelledAt: serializeTimestamp(sub['cancelledAt']),
        }
      : null,
  };
});

// ── Get Stats ────────────────────────────────────────────────────────────────

export const adminGetStats = region.https.onCall(async (_data, context) => {
  requireAdmin(context);

  const [totalUsersSnap, premiumSnap, auditSnap] = await Promise.all([
    db.collection('users').count().get(),
    db.collectionGroup('meta').where('isPremium', '==', true).count().get(),
    db.collection('adminLogs').orderBy('timestamp', 'desc').limit(1).get(),
  ]);

  const totalUsers = totalUsersSnap.data().count;
  const premiumUsers = premiumSnap.data().count;

  const lastAction = auditSnap.empty
    ? null
    : {
        action: auditSnap.docs[0].data()['action'],
        timestamp: (auditSnap.docs[0].data()['timestamp'] as admin.firestore.Timestamp)
          .toDate()
          .toISOString(),
      };

  return {
    totalUsers,
    premiumUsers,
    freeUsers: totalUsers - premiumUsers,
    lastAction,
  };
});

// ── Update Config ─────────────────────────────────────────────────────────────

export const adminUpdateConfig = region.https.onCall(async (data, context) => {
  requireAdmin(context);

  const allowed = [
    'maintenanceMode',
    'maintenanceModeMessage',
    'forceUpdateVersion',
    'announcementBanner',
    'aiEnabled',
    'aiMonthlyBudgetUsd',
  ];

  const update: Record<string, unknown> = {};
  for (const key of allowed) {
    if (key in (data as Record<string, unknown>)) {
      update[key] = (data as Record<string, unknown>)[key];
    }
  }

  if (Object.keys(update).length === 0) {
    throw new functions.https.HttpsError('invalid-argument', 'No valid config fields provided');
  }

  await db.doc('appConfig/global').set(update, { merge: true });

  await writeAuditLog(context, 'update_config', update);

  return { success: true };
});
