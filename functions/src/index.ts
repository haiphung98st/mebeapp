import * as admin from 'firebase-admin';
admin.initializeApp();

export { aiChat, deleteChatConversation } from './aiChat';
