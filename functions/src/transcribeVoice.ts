import * as admin from 'firebase-admin';
import { onObjectFinalized } from 'firebase-functions/v2/storage';
import { defineSecret } from 'firebase-functions/params';
import OpenAI from 'openai';
import * as os from 'os';
import * as path from 'path';
import * as fs from 'fs';

const openAiKey = defineSecret('OPENAI_API_KEY');
const db = admin.firestore();

export const transcribeVoice = onObjectFinalized(
  { secrets: [openAiKey] },
  async (event) => {
    const filePath = event.data.name ?? '';

    // Only process files under voiceJournal/
    if (!filePath.startsWith('voiceJournal/')) return;

    // Expected: voiceJournal/{userId}/{babyId}/{id}.m4a
    const parts = filePath.split('/');
    if (parts.length !== 4) return;
    const [, userId, babyId, filename] = parts;
    const id = path.basename(filename, path.extname(filename));

    const bucket = admin.storage().bucket(event.data.bucket);
    const tempPath = path.join(os.tmpdir(), filename);

    await bucket.file(filePath).download({ destination: tempPath });

    try {
      const openai = new OpenAI({ apiKey: openAiKey.value() });

      const transcription = await openai.audio.transcriptions.create({
        file: fs.createReadStream(tempPath) as unknown as File,
        model: 'whisper-1',
        language: 'vi',
      });

      await db
        .doc(`users/${userId}/babies/${babyId}/voiceEntries/${id}`)
        .update({
          transcriptText: transcription.text,
          transcriptPending: false,
        });
    } finally {
      if (fs.existsSync(tempPath)) {
        fs.unlinkSync(tempPath);
      }
    }
  },
);
