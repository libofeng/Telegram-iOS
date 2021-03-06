/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGCollectionItem.h"

#import "TGUser.h"
#import "ASWatcher.h"

@interface TGUserInfoCollectionItem : TGCollectionItem <ASWatcher>

@property (nonatomic, strong) ASHandle *actionHandle;
@property (nonatomic, strong) ASHandle *interfaceHandle;

@property (nonatomic) bool automaticallyManageUserPresence;
@property (nonatomic) bool useRealName;
@property (nonatomic) bool disableAvatar;
@property (nonatomic) CGFloat additinalHeight;
@property (nonatomic) CGSize avatarOffset;
@property (nonatomic) CGSize nameOffset;

- (void)setUser:(TGUser *)user animated:(bool)animated;
- (void)setEditing:(bool)editing animated:(bool)animated;

- (void)setUpdatingFirstName:(NSString *)updatingFirstName updatingLastName:(NSString *)updatingLastName;

- (void)setUpdatingAvatar:(UIImage *)updatingAvatar hasUpdatingAvatar:(bool)hasUpdatingAvatar;
- (bool)hasUpdatingAvatar;

- (void)updateTimestamp;

- (id)visibleAvatarView;
- (void)makeNameFieldFirstResponder;
- (void)copyUpdatingAvatarToCacheWithUri:(NSString *)uri;
- (NSString *)editingFirstName;
- (NSString *)editingLastName;

@end
