import Foundation

final class PAPCache {
    private var cache: NSCache

    // MARK:- Initialization
    
    static let sharedCache = PAPCache()

    private init() {
        self.cache = NSCache()
    }

    // MARK:- PAPCache

    func clear() {
        cache.removeAllObjects()
    }

    func setAttributesForPhoto(photo: PFObject, likers: [PFUser], commenters: [PFUser], likedByCurrentUser: Bool) {
        let attributes = [
            kPAPPhotoAttributesIsLikedByCurrentUserKey: likedByCurrentUser,
            kPAPPhotoAttributesLikeCountKey: likers.count,
            kPAPPhotoAttributesLikersKey: likers,
            kPAPPhotoAttributesCommentCountKey: commenters.count,
            kPAPPhotoAttributesCommentersKey: commenters
        ]
        setAttributes(attributes as! [String : AnyObject], forPhoto: photo)
    }

    func setAttributesForItem(item: PFObject, likers: [PFUser], commenters: [PFUser], likedByCurrentUser: Bool) {
        let attributes = [
            kPAPItemAttributesIsLikedByCurrentUserKey: likedByCurrentUser,
            kPAPItemAttributesLikeCountKey: likers.count,
            kPAPItemAttributesLikersKey: likers,
            kPAPItemAttributesCommentCountKey: commenters.count,
            kPAPItemAttributesCommentersKey: commenters
        ]
        setAttributes(attributes as! [String : AnyObject], forItem: item)
    }
    
    func attributesForPhoto(photo: PFObject) -> [String:AnyObject]? {
        let key: String = self.keyForPhoto(photo)
        return cache.objectForKey(key) as? [String:AnyObject]
    }

    func attributesForItem(item: PFObject) -> [String:AnyObject]? {
        let key: String = self.keyForItem(item)
        return cache.objectForKey(key) as? [String:AnyObject]
    }
    
    func likeCountForPhoto(photo: PFObject) -> Int {
        let attributes: [NSObject:AnyObject]? = self.attributesForPhoto(photo)
        if attributes != nil {
            return attributes![kPAPPhotoAttributesLikeCountKey] as! Int
        }

        return 0
    }

    func likeCountForItem(item: PFObject) -> Int {
        let attributes: [NSObject:AnyObject]? = self.attributesForItem(item)
        if attributes != nil {
            return attributes![kPAPItemAttributesLikeCountKey] as! Int
        }
        
        return 0
    }
    
    func commentCountForPhoto(photo: PFObject) -> Int {
        let attributes = attributesForPhoto(photo)
        if attributes != nil {
            return attributes![kPAPPhotoAttributesCommentCountKey] as! Int
        }
        
        return 0
    }

    func commentCountForItem(item: PFObject) -> Int {
        let attributes = attributesForItem(item)
        if attributes != nil {
            return attributes![kPAPItemAttributesCommentCountKey] as! Int
        }
        
        return 0
    }
    
    
    func likersForPhoto(photo: PFObject) -> [PFUser] {
        let attributes = attributesForPhoto(photo)
        if attributes != nil {
            return attributes![kPAPPhotoAttributesLikersKey] as! [PFUser]
        }
        
        return [PFUser]()
    }
    
    func likersForItem(item: PFObject) -> [PFUser] {
        let attributes = attributesForItem(item)
        if attributes != nil {
            return attributes![kPAPItemAttributesLikersKey] as! [PFUser]
        }
        
        return [PFUser]()
    }
    
    func commentersForPhoto(photo: PFObject) -> [PFUser] {
        let attributes = attributesForPhoto(photo)
        if attributes != nil {
            return attributes![kPAPPhotoAttributesCommentersKey] as! [PFUser]
        }
        
        return [PFUser]()
    }

    func setPhotoIsLikedByCurrentUser(photo: PFObject, liked: Bool) {
        var attributes = attributesForPhoto(photo)
        attributes![kPAPPhotoAttributesIsLikedByCurrentUserKey] = liked
        setAttributes(attributes!, forPhoto: photo)
    }

    func isPhotoLikedByCurrentUser(photo: PFObject) -> Bool {
        let attributes = attributesForPhoto(photo)
        if attributes != nil {
            return attributes![kPAPPhotoAttributesIsLikedByCurrentUserKey] as! Bool
        }
        
        return false
    }

    func setItemIsLikedByCurrentUser(item: PFObject, liked: Bool) {
        var attributes = attributesForItem(item)
        attributes![kPAPItemAttributesIsLikedByCurrentUserKey] = liked
        setAttributes(attributes!, forItem: item)
    }
    
    
    func isItemLikedByCurrentUser(item: PFObject) -> Bool {
        let attributes = attributesForItem(item)
        if attributes != nil {
            return attributes![kPAPItemAttributesIsLikedByCurrentUserKey] as! Bool
        }
        
        return false
    }
    
    func incrementLikerCountForPhoto(photo: PFObject) {
        let likerCount = likeCountForPhoto(photo) + 1
        var attributes = attributesForPhoto(photo)
        attributes![kPAPPhotoAttributesLikeCountKey] = likerCount
        setAttributes(attributes!, forPhoto: photo)
    }

    func decrementLikerCountForPhoto(photo: PFObject) {
        let likerCount = likeCountForPhoto(photo) - 1
        if likerCount < 0 {
            return
        }
        var attributes = attributesForPhoto(photo)
        attributes![kPAPPhotoAttributesLikeCountKey] = likerCount
        setAttributes(attributes!, forPhoto: photo)
    }

    
    func incrementLikerCountForItem(item: PFObject) {
        let likerCount = likeCountForItem(item) + 1
        var attributes = attributesForItem(item)
        attributes![kPAPItemAttributesLikeCountKey] = likerCount
        setAttributes(attributes!, forItem: item)
    }
    
    func decrementLikerCountForItem(item: PFObject) {
        let likerCount = likeCountForItem(item) - 1
        if likerCount < 0 {
            return
        }
        var attributes = attributesForItem(item)
        attributes![kPAPItemAttributesLikeCountKey] = likerCount
        setAttributes(attributes!, forItem: item)
    }
    
    func incrementCommentCountForPhoto(photo: PFObject) {
        let commentCount = commentCountForPhoto(photo) + 1
        var attributes = attributesForPhoto(photo)
        attributes![kPAPPhotoAttributesCommentCountKey] = commentCount
        setAttributes(attributes!, forPhoto: photo)
    }

    func decrementCommentCountForPhoto(photo: PFObject) {
        let commentCount = commentCountForPhoto(photo) - 1
        if commentCount < 0 {
            return
        }
        var attributes = attributesForPhoto(photo)
        attributes![kPAPPhotoAttributesCommentCountKey] = commentCount
        setAttributes(attributes!, forPhoto: photo)
    }

    
    func incrementCommentCountForItem(item: PFObject) {
        let commentCount = commentCountForItem(item) + 1
        var attributes = attributesForItem(item)
        attributes![kPAPItemAttributesCommentCountKey] = commentCount
        setAttributes(attributes!, forItem: item)
    }
    
    func decrementCommentCountForItem(item: PFObject) {
        let commentCount = commentCountForItem(item) - 1
        if commentCount < 0 {
            return
        }
        var attributes = attributesForItem(item)
        attributes![kPAPItemAttributesCommentCountKey] = commentCount
        setAttributes(attributes!, forItem: item)
    }

    
    func setAttributesForUser(user: PFUser, photoCount count: Int, followedByCurrentUser following: Bool) {
        let attributes = [
            kPAPUserAttributesPhotoCountKey: count,
            kPAPUserAttributesIsFollowedByCurrentUserKey: following
        ]

        setAttributes(attributes as! [String : AnyObject], forUser: user)
    }

    func setAttributesForUser(user: PFUser, itemCount count: Int, followedByCurrentUser following: Bool) {
        let attributes = [
            kPAPUserAttributesItemCountKey: count,
            kPAPUserAttributesIsFollowedByCurrentUserKey: following
        ]
        
        setAttributes(attributes as! [String : AnyObject], forUser: user)
    }
    
    func attributesForUser(user: PFUser) -> [String:AnyObject]? {
        let key = keyForUser(user)
        return cache.objectForKey(key) as? [String:AnyObject]
    }

    func photoCountForUser(user: PFUser) -> Int {
        if let attributes = attributesForUser(user) {
            if let photoCount = attributes[kPAPUserAttributesPhotoCountKey] as? Int {
                return photoCount
            }
        }
        
        return 0
    }

    func followStatusForUser(user: PFUser) -> Bool {
        if let attributes = attributesForUser(user) {
            if let followStatus = attributes[kPAPUserAttributesIsFollowedByCurrentUserKey] as? Bool {
                return followStatus
            }
        }

        return false
    }

    func setPhotoCount(count: Int,  user: PFUser) {
        if var attributes = attributesForUser(user) {
            attributes[kPAPUserAttributesPhotoCountKey] = count
            setAttributes(attributes, forUser: user)
        }
    }

    func setFollowStatus(following: Bool, user: PFUser) {
        if var attributes = attributesForUser(user) {
            attributes[kPAPUserAttributesIsFollowedByCurrentUserKey] = following
            setAttributes(attributes, forUser: user)
        }
    }

    func setFacebookFriends(friends: NSArray) {
        let key: String = kPAPUserDefaultsCacheFacebookFriendsKey
        self.cache.setObject(friends, forKey: key)
        NSUserDefaults.standardUserDefaults().setObject(friends, forKey: key)
        NSUserDefaults.standardUserDefaults().synchronize()
    }

    func facebookFriends() -> [PFUser] {
        let key = kPAPUserDefaultsCacheFacebookFriendsKey
        if cache.objectForKey(key) != nil {
            return cache.objectForKey(key) as! [PFUser]
        }
        
        let friends = NSUserDefaults.standardUserDefaults().objectForKey(key)
        if friends != nil {
            cache.setObject(friends!, forKey: key)
            return friends as! [PFUser]
        }
        return [PFUser]()
    }

    // MARK:- ()

    func setAttributes(attributes: [String:AnyObject], forPhoto photo: PFObject) {
        let key: String = self.keyForPhoto(photo)
        cache.setObject(attributes, forKey: key)
    }

    func setAttributes(attributes: [String:AnyObject], forItem item: PFObject) {
        let key: String = self.keyForItem(item)
        cache.setObject(attributes, forKey: key)
    }
    
    func setAttributes(attributes: [String:AnyObject], forUser user: PFUser) {
        let key: String = self.keyForUser(user)
        cache.setObject(attributes, forKey: key)
    }

    func keyForPhoto(photo: PFObject) -> String {
        return "photo_\(photo.objectId)"
    }

    func keyForItem(item: PFObject) -> String {
        return "item_\(item.objectId)"
    }
    
    func keyForUser(user: PFUser) -> String {
        return "user_\(user.objectId)"
    }
}
