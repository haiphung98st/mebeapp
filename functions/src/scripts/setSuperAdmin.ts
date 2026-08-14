import * as admin from 'firebase-admin';

async function setSuperAdmin(uid: string): Promise<void> {
  admin.initializeApp();
  await admin.auth().setCustomUserClaims(uid, {
    role: 'superadmin',
    isAdmin: true,
  });
  const user = await admin.auth().getUser(uid);
  console.log(`✅ Superadmin claims set for: ${user.email} (${uid})`);
  process.exit(0);
}

const uid = process.argv[2];
if (!uid) {
  console.error('Usage: ts-node setSuperAdmin.ts <uid>');
  process.exit(1);
}

setSuperAdmin(uid).catch((e) => {
  console.error('❌ Error:', e);
  process.exit(1);
});
