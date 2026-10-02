/**
 * Seed script: populates bedtime_categories and bedtime_stories in Firestore.
 *
 * Usage:
 *   npx ts-node functions/scripts/seed_bedtime.ts --confirm
 *
 * Requires GOOGLE_APPLICATION_CREDENTIALS or firebase-admin default credentials.
 */
import * as admin from 'firebase-admin';
import * as fs from 'fs';
import * as path from 'path';

const args = process.argv.slice(2);
if (!args.includes('--confirm')) {
  console.error('Pass --confirm to run the seed. This OVERWRITES existing docs.');
  process.exit(1);
}

admin.initializeApp();
const db = admin.firestore();

interface SeedCategory {
  id: string;
  name: string;
  slug: string;
  iconKey: string;
  sortOrder: number;
  isActive: boolean;
}

interface SeedParagraph {
  index: number;
  text: string;
  audioPath?: string | null;
  durationMs?: number | null;
  textHash?: string | null;
}

interface SeedStory {
  id: string;
  title: string;
  slug: string;
  summary: string;
  categoryId: string;
  ageGroups: string[];
  tags: string[];
  coverPath: string | null;
  durationSec: number;
  paragraphCount: number;
  isPremium: boolean;
  status: string;
  version: number;
  voiceId: string | null;
  ttsProvider: string | null;
  charCount: number;
  sortOrder: number;
  publishedAt: string | null;
  createdAt: string;
  updatedAt: string;
  updatedBy: string | null;
  content: {
    paragraphs: SeedParagraph[];
    fullAudioPath: string | null;
  };
}

interface SeedData {
  categories: SeedCategory[];
  stories: SeedStory[];
}

async function seed(): Promise<void> {
  const dataPath = path.resolve(__dirname, '../../seed/bedtime_seed.json');
  const raw = fs.readFileSync(dataPath, 'utf-8');
  const data: SeedData = JSON.parse(raw);

  const batch = db.batch();

  for (const cat of data.categories) {
    const { id, ...fields } = cat;
    batch.set(db.collection('bedtime_categories').doc(id), fields);
  }

  await batch.commit();
  console.log(`Seeded ${data.categories.length} categories.`);

  for (const story of data.stories) {
    const { id, content, ...storyFields } = story;
    const storyRef = db.collection('bedtime_stories').doc(id);

    const storyData = {
      ...storyFields,
      publishedAt: story.publishedAt ? admin.firestore.Timestamp.fromDate(new Date(story.publishedAt)) : null,
      createdAt: admin.firestore.Timestamp.fromDate(new Date(story.createdAt)),
      updatedAt: admin.firestore.Timestamp.fromDate(new Date(story.updatedAt)),
    };

    await storyRef.set(storyData);
    await storyRef.collection('content').doc('body').set({
      paragraphs: content.paragraphs,
      fullAudioPath: content.fullAudioPath,
    });
    console.log(`  Seeded story: ${story.title}`);
  }

  console.log(`Done. Seeded ${data.stories.length} stories.`);
}

seed().catch((err) => {
  console.error(err);
  process.exit(1);
});
