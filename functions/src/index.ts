import * as admin from 'firebase-admin';
admin.initializeApp();

export { aiChat, deleteChatConversation } from './aiChat';
export {
  adminGrantPremium,
  adminRevokePremium,
  adminSetRole,
  adminGetUser,
  adminGetStats,
  adminUpdateConfig,
} from './adminFunctions';
