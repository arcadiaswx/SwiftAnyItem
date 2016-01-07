enum PAPTabBarControllerViewControllerIndex: Int {
    case HomeTabBarItemIndex = 0, EmptyTabBarItemIndex, ActivityTabBarItemIndex
}

// Ilya     400680
// James    403902
// David    1225726
// Bryan    4806789
// Thomas   6409809
// Ashley   12800553
// Héctor   121800083
// Kevin    500011038
// Chris    558159381
// Matt     723748661

let kPAPParseEmployeeAccounts = ["400680", "403902", "1225726", "4806789", "6409809", "12800553", "121800083", "500011038", "558159381", "723748661"]

let kPAPUserDefaultsActivityFeedViewControllerLastRefreshKey = "com.teklabsco.SwiftAnyItem.userDefaults.activityFeedViewController.lastRefresh"
let kPAPUserDefaultsCacheFacebookFriendsKey = "com.teklabsco.SwiftAnyItem.userDefaults.cache.facebookFriends"

// MARK:- Launch URLs

let kPAPLaunchURLHostTakePicture = "camera"

// MARK:- NSNotification

let PAPAppDelegateApplicationDidReceiveRemoteNotification           = "com.teklabsco.SwiftAnyItem.appDelegate.applicationDidReceiveRemoteNotification"
let PAPUtilityUserFollowingChangedNotification                      = "com.teklabsco.SwiftAnyItem.utility.userFollowingChanged"
let PAPUtilityUserLikedUnlikedPhotoCallbackFinishedNotification     = "com.teklabsco.SwiftAnyItem.utility.userLikedUnlikedPhotoCallbackFinished"
let PAPUtilityUserLikedUnlikedItemCallbackFinishedNotification     = "com.teklabsco.SwiftAnyItem.utility.userLikedUnlikedItemCallbackFinished"
let PAPUtilityDidFinishProcessingProfilePictureNotification         = "com.teklabsco.SwiftAnyItem.utility.didFinishProcessingProfilePictureNotification"

let PAPTabBarControllerDidFinishEditingPhotoNotification            = "com.teklabsco.SwiftAnyItem.tabBarController.didFinishEditingPhoto"
let PAPTabBarControllerDidFinishImageFileUploadNotification         = "com.teklabsco.SwiftAnyItem.tabBarController.didFinishImageFileUploadNotification"

let PAPPhotoDetailsViewControllerUserDeletedPhotoNotification       = "com.teklabsco.SwiftAnyItem.photoDetailsViewController.userDeletedPhoto"
let PAPItemDetailsViewControllerUserDeletedItemNotification       = "com.teklabsco.SwiftAnyItem.itemDetailsViewController.userDeletedItem"

let PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotification  = "com.teklabsco.SwiftAnyItem.photoDetailsViewController.userLikedUnlikedPhotoInDetailsViewNotification"
let PAPPhotoDetailsViewControllerUserCommentedOnPhotoNotification   = "com.teklabsco.SwiftAnyItem.photoDetailsViewController.userCommentedOnPhotoInDetailsViewNotification"

let PAPItemDetailsViewControllerUserCommentedOnItemNotification   = "com.teklabsco.SwiftAnyItem.itemDetailsViewController.userCommentedOnItemInDetailsViewNotification"
let PAPItemDetailsViewControllerUserLikedUnlikedItemNotification  = "com.teklabsco.SwiftAnyItem.itemDetailsViewController.userLikedUnlikedItemInDetailsViewNotification"

// MARK:- User Info Keys
let PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey = "liked"
let PAPItemDetailsViewControllerUserLikedUnlikedItemNotificationUserInfoLikedKey = "liked"
let kPAPEditPhotoViewControllerUserInfoCommentKey = "comment"

// MARK:- Installation Class

// Field keys
let kPAPInstallationUserKey = "user"

// MARK:- Activity Class
// Class key
let kPAPActivityClassKey = "Activity"

// Field keys
let kPAPActivityTypeKey        = "type"
let kPAPActivityFromUserKey    = "fromUser"
let kPAPActivityToUserKey      = "toUser"
let kPAPActivityContentKey     = "content"
let kPAPActivityPhotoKey       = "photo"
let kPAPActivityItemKey        = "item"

// Type values
let kPAPActivityTypeLike       = "like"
let kPAPActivityTypeFollow     = "follow"
let kPAPActivityTypeComment    = "comment"
let kPAPActivityTypeJoined     = "joined"

// MARK:- User Class
// Field keys
let kPAPUserDisplayNameKey                          = "displayName"
let kPAPUserFacebookIDKey                           = "facebookId"
let kPAPUserPhotoIDKey                              = "photoId"
let kPAPUserProfilePicSmallKey                      = "profilePictureSmall"
let kPAPUserProfilePicMediumKey                     = "profilePictureMedium"
let kPAPUserFacebookFriendsKey                      = "facebookFriends"
let kPAPUserAlreadyAutoFollowedFacebookFriendsKey   = "userAlreadyAutoFollowedFacebookFriends"
let kPAPUserEmailKey                                = "email"
let kPAPUserAutoFollowKey                           = "autoFollow"

// MARK:- Photo Class

// Class key
let kPAPPhotoClassKey = "Photo"

// Field keys
let kPAPPhotoPictureKey         = "image"
let kPAPPhotoThumbnailKey       = "thumbnail"
let kPAPPhotoUserKey            = "user"
let kPAPPhotoOpenGraphIDKey     = "fbOpenGraphID"

// Class key
let kPAPItemClassKey = "Item"

// Field keys
let kPAPItemPictureKey         = "image"
let kPAPItemThumbnailKey       = "thumbnail"
let kPAPItemUserKey            = "user"
let kPAPItemOpenGraphIDKey     = "fbOpenGraphID"


// MARK:- Cached Photo Attributes
// keys
let kPAPPhotoAttributesIsLikedByCurrentUserKey = "isLikedByCurrentUser";
let kPAPPhotoAttributesLikeCountKey            = "likeCount"
let kPAPPhotoAttributesLikersKey               = "likers"
let kPAPPhotoAttributesCommentCountKey         = "commentCount"
let kPAPPhotoAttributesCommentersKey           = "commenters"

// MARK:- Cached Item Attributes
// keys
let kPAPItemAttributesIsLikedByCurrentUserKey = "isLikedByCurrentUser";
let kPAPItemAttributesLikeCountKey            = "likeCount"
let kPAPItemAttributesLikersKey               = "likers"
let kPAPItemAttributesCommentCountKey         = "commentCount"
let kPAPItemAttributesCommentersKey           = "commenters"


// MARK:- Cached User Attributes
// keys
let kPAPUserAttributesPhotoCountKey                 = "photoCount"
let kPAPUserAttributesItemCountKey                  = "itemCount"
let kPAPUserAttributesIsFollowedByCurrentUserKey    = "isFollowedByCurrentUser"

// MARK:- Push Notification Payload Keys

let kAPNSAlertKey = "alert"
let kAPNSBadgeKey = "badge"
let kAPNSSoundKey = "sound"

// the following keys are intentionally kept short, APNS has a maximum payload limit
let kPAPPushPayloadPayloadTypeKey          = "p"
let kPAPPushPayloadPayloadTypeActivityKey  = "a"

let kPAPPushPayloadActivityTypeKey     = "t"
let kPAPPushPayloadActivityLikeKey     = "l"
let kPAPPushPayloadActivityCommentKey  = "c"
let kPAPPushPayloadActivityFollowKey   = "f"

let kPAPPushPayloadFromUserObjectIdKey = "fu"
let kPAPPushPayloadToUserObjectIdKey   = "tu"
let kPAPPushPayloadPhotoObjectIdKey = "pid"
