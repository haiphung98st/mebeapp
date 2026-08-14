import * as admin from 'firebase-admin';
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import Anthropic from '@anthropic-ai/sdk';
import { mebeSystemPrompt } from './mebeSystemPrompt';

const db = admin.firestore();

interface SendMessageRequest {
  message: string;
  conversationId?: string;
}

interface BabyContext {
  babyName: string;
  ageWeeks: number;
  recentFeedings: number;
  recentSleepHours: number;
}

async function getBabyContext(userId: string): Promise<BabyContext | null> {
  const babiesSnap = await db.collection(`users/${userId}/babies`).limit(1).get();
  if (babiesSnap.empty) return null;

  const baby = babiesSnap.docs[0].data();
  const babyId = babiesSnap.docs[0].id;
  const babyName = (baby['name'] as string | undefined) ?? 'Bé';
  const birthDate = (baby['birthDate'] as admin.firestore.Timestamp | undefined)?.toDate() ?? new Date();
  const ageWeeks = Math.floor((Date.now() - birthDate.getTime()) / (1000 * 60 * 60 * 24 * 7));

  const sevenDaysAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
  const [feedingsSnap, sleepsSnap] = await Promise.all([
    db
      .collection(`users/${userId}/babies/${babyId}/feedings`)
      .where('startTime', '>=', admin.firestore.Timestamp.fromDate(sevenDaysAgo))
      .get(),
    db
      .collection(`users/${userId}/babies/${babyId}/sleeps`)
      .where('startTime', '>=', admin.firestore.Timestamp.fromDate(sevenDaysAgo))
      .get(),
  ]);

  const recentFeedings = feedingsSnap.size;
  const recentSleepHours = sleepsSnap.docs.reduce((sum, doc) => {
    return sum + ((doc.data()['durationMinutes'] as number | undefined) ?? 0) / 60;
  }, 0);

  return { babyName, ageWeeks, recentFeedings, recentSleepHours };
}

export const aiChat = onCall(
  { secrets: ['ANTHROPIC_API_KEY'], region: 'asia-southeast1' },
  async (request) => {
    const { auth, data } = request;

    if (!auth) {
      throw new HttpsError('unauthenticated', 'LOGIN_REQUIRED');
    }

    const userId = auth.uid;
    const { message, conversationId } = data as SendMessageRequest;

    if (!message || typeof message !== 'string' || message.trim().length === 0) {
      throw new HttpsError('invalid-argument', 'Message cannot be empty');
    }
    if (message.length > 2000) {
      throw new HttpsError('invalid-argument', 'Message too long');
    }

    // Server-side premium check
    const subDoc = await db.doc(`users/${userId}/subscription/status`).get();
    const isPremium = subDoc.exists && (subDoc.data() as Record<string, unknown>)['isPremium'] === true;
    if (!isPremium) {
      throw new HttpsError('permission-denied', 'PREMIUM_REQUIRED');
    }

    const babyCtx = await getBabyContext(userId);
    let contextPrompt = mebeSystemPrompt;
    if (babyCtx) {
      contextPrompt +=
        `\n\nDỮ LIỆU BÉ HIỆN TẠI:\n` +
        `- Tên bé: ${babyCtx.babyName}\n` +
        `- Tuổi: ${babyCtx.ageWeeks} tuần\n` +
        `- 7 ngày qua: ${babyCtx.recentFeedings} cữ bú, ngủ tổng ${babyCtx.recentSleepHours.toFixed(1)} giờ`;
    }

    // Build or fetch conversation reference
    let convRef: admin.firestore.DocumentReference;
    if (conversationId) {
      convRef = db.doc(`users/${userId}/aiChats/${conversationId}`);
    } else {
      convRef = db.collection(`users/${userId}/aiChats`).doc();
    }

    // Load last 10 messages for context
    const messagesSnap = await convRef.collection('messages').orderBy('timestamp', 'desc').limit(10).get();
    const history: Anthropic.MessageParam[] = messagesSnap.docs.reverse().map((doc) => ({
      role: (doc.data() as Record<string, unknown>)['role'] as 'user' | 'assistant',
      content: (doc.data() as Record<string, unknown>)['content'] as string,
    }));

    const anthropic = new Anthropic({ apiKey: process.env['ANTHROPIC_API_KEY'] });
    const response = await anthropic.messages.create({
      model: 'claude-haiku-4-5-20251001',
      max_tokens: 1024,
      system: contextPrompt,
      messages: [...history, { role: 'user', content: message }],
    });
    const reply = (response.content[0] as Anthropic.TextBlock).text;

    const now = admin.firestore.FieldValue.serverTimestamp();
    const batch = db.batch();

    const userMsgRef = convRef.collection('messages').doc();
    batch.set(userMsgRef, { role: 'user', content: message, timestamp: now });

    const aiMsgRef = convRef.collection('messages').doc();
    batch.set(aiMsgRef, { role: 'assistant', content: reply, timestamp: now });

    const truncate = (s: string) => (s.length > 120 ? s.substring(0, 120) + '…' : s);
    batch.set(
      convRef,
      {
        lastMessage: truncate(message),
        lastReply: truncate(reply),
        updatedAt: now,
        messageCount: admin.firestore.FieldValue.increment(2),
      },
      { merge: true },
    );

    await batch.commit();
    return { reply, conversationId: convRef.id };
  },
);

export const deleteChatConversation = onCall(
  { region: 'asia-southeast1' },
  async (request) => {
    const { auth, data } = request;
    if (!auth) throw new HttpsError('unauthenticated', 'LOGIN_REQUIRED');

    const { conversationId } = data as { conversationId: string };
    const userId = auth.uid;

    const convRef = db.doc(`users/${userId}/aiChats/${conversationId}`);
    const msgsSnap = await convRef.collection('messages').get();
    const batch = db.batch();
    msgsSnap.docs.forEach((doc) => batch.delete(doc.ref));
    batch.delete(convRef);
    await batch.commit();

    return { success: true };
  },
);
