/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGMessage.h"

#import "TL/TLMetaScheme.h"

#import "SecretLayer1.h"
#import "SecretLayer17.h"
#import "SecretLayer20.h"

#import "TGStoredIncomingMessageFileInfo.h"

@interface TGMessage (Telegraph)

- (id)initWithTelegraphMessageDesc:(TLMessage *)desc;

- (instancetype)initWithDecryptedMessageDesc1:(Secret1_DecryptedMessage *)desc encryptedFile:(TGStoredIncomingMessageFileInfo *)encryptedFile conversationId:(int64_t)conversationId fromUid:(int)fromUid date:(int)date;
- (instancetype)initWithDecryptedMessageDesc17:(Secret17_DecryptedMessage *)desc encryptedFile:(TGStoredIncomingMessageFileInfo *)encryptedFile conversationId:(int64_t)conversationId fromUid:(int)fromUid date:(int)date;
- (instancetype)initWithDecryptedMessageDesc18:(Secret20_DecryptedMessage *)desc encryptedFile:(TGStoredIncomingMessageFileInfo *)encryptedFile conversationId:(int64_t)conversationId fromUid:(int)fromUid date:(int)date;

@end
