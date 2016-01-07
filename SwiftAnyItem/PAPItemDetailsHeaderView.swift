import UIKit
import ParseUI
import FormatterKit

private let baseHorizontalOffset: CGFloat = 0.0
private let baseWidth: CGFloat = 320.0

private let horiBorderSpacing: CGFloat = 6.0
private let horiMediumSpacing: CGFloat = 8.0

private let vertBorderSpacing: CGFloat = 6.0
private let vertSmallSpacing: CGFloat = 2.0

private let nameHeaderX: CGFloat = baseHorizontalOffset
private let nameHeaderY: CGFloat = 0.0
private let nameHeaderWidth: CGFloat = baseWidth
private let nameHeaderHeight: CGFloat = 46.0

private let avatarImageX: CGFloat = horiBorderSpacing
private let avatarImageY: CGFloat = vertBorderSpacing
private let avatarImageDim: CGFloat = 35.0

private let nameLabelX: CGFloat = avatarImageX+avatarImageDim+horiMediumSpacing
private let nameLabelY: CGFloat = avatarImageY+vertSmallSpacing
private let nameLabelMaxWidth: CGFloat = 280.0 - (horiBorderSpacing+avatarImageDim+horiMediumSpacing+horiBorderSpacing)

private let timeLabelX: CGFloat = nameLabelX
private let timeLabelMaxWidth: CGFloat = nameLabelMaxWidth

private let mainImageX: CGFloat = baseHorizontalOffset
private let mainImageY: CGFloat = nameHeaderHeight
private let mainImageWidth: CGFloat = baseWidth
private let mainImageHeight: CGFloat = 320.0

private let likeBarX: CGFloat = baseHorizontalOffset
private let likeBarY: CGFloat = nameHeaderHeight + mainImageHeight
private let likeBarWidth: CGFloat = baseWidth
private let likeBarHeight: CGFloat = 43.0

private let likeButtonX: CGFloat = 9.0
private let likeButtonY: CGFloat = 8.0
private let likeButtonDim: CGFloat = 28.0

private let likeProfileXBase: CGFloat = 46.0
private let likeProfileXSpace: CGFloat = 3.0
private let likeProfileY: CGFloat = 6.0
private let likeProfileDim: CGFloat = 30.0

private let viewTotalHeight: CGFloat = likeBarY+likeBarHeight
private let numLikePics: CGFloat = 7.0


class PAPItemDetailsHeaderView: UIView {

    /// The user that took the item
    private(set) var itemgrapher: PFUser?

    /// Heart-shaped like button
    private(set) var likeButton: UIButton?

    /*! @name Delegate */
    var delegate: PAPItemDetailsHeaderViewDelegate?
    
    // View components
    var nameHeaderView: UIView?
    var itemImageView: PFImageView?
    var likeBarView: UIView?
    var currentLikeAvatars = [PAPProfileImageView]()

    // Redeclare for edit
// FIXME????    var itemgrapher: PFUser?

    // MARK:- NSObject

    init(frame: CGRect, item aItem: PFObject) {
        super.init(frame: frame)
        // Initialization code
        if timeFormatter == nil {
            timeFormatter = TTTTimeIntervalFormatter()
        }
        
        self.item = aItem
        self.itemgrapher = self.item!.objectForKey(kPAPItemUserKey) as? PFUser
        self.likeUsers = nil
        
        self.backgroundColor = UIColor.clearColor()
        self.createView()
    }

    init(frame: CGRect, item aItem: PFObject, itemgrapher aItemgrapher: PFUser, likeUsers theLikeUsers: [PFUser]) {
        super.init(frame: frame)
        // Initialization code
        if timeFormatter == nil {
            timeFormatter = TTTTimeIntervalFormatter()
        }

        self.item = aItem
        self.itemgrapher = aItemgrapher
        self.likeUsers = theLikeUsers
        
        self.backgroundColor = UIColor.clearColor()

        if self.item != nil && self.itemgrapher != nil && likeUsers != nil {
            self.createView()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK:- PAPItemDetailsHeaderView

    class func rectForView() -> CGRect {
        return CGRectMake(CGFloat(0.0), CGFloat(0.0), UIScreen.mainScreen().bounds.size.width, CGFloat(viewTotalHeight))
    }
    
    /// The item displayed in the view
    var item: PFObject? {
        didSet {
            if item != nil && self.itemgrapher != nil && self.likeUsers != nil {
                self.createView()
                self.setNeedsDisplay()
            }
        }
    }

    /// Array of the users that liked the item
    var likeUsers: [PFUser]? {
        didSet {
            likeUsers = likeUsers!.sort { (liker1, liker2) in
                let displayName1 = liker1.objectForKey(kPAPUserDisplayNameKey) as! String
                let displayName2 = liker2.objectForKey(kPAPUserDisplayNameKey) as! String
                
                if liker1.objectId == PFUser.currentUser()!.objectId {
                    return true
                } else if liker2.objectId == PFUser.currentUser()!.objectId {
                    return false
                }
                
                let comparisonResult: NSComparisonResult = displayName1.compare(displayName2, options:[NSStringCompareOptions.CaseInsensitiveSearch, NSStringCompareOptions.DiacriticInsensitiveSearch])
                switch comparisonResult {
                    case .OrderedAscending, .OrderedSame:
                        return true
                    case .OrderedDescending:
                        return false
                }
            }
            
            for image: PAPProfileImageView in currentLikeAvatars {
                image.removeFromSuperview()
            }

            likeButton!.setTitle("\(likeUsers!.count)", forState: UIControlState.Normal)

            self.currentLikeAvatars = Array<PAPProfileImageView>(count: likeUsers!.count, repeatedValue: PAPProfileImageView())
            
            let numOfPics: Int = Int(numLikePics) > likeUsers!.count ? likeUsers!.count : Int(numLikePics)

            for var i = 0; i < numOfPics; i++ {
                let profilePic = PAPProfileImageView()
                profilePic.frame = CGRectMake(likeProfileXBase + CGFloat(i) * (likeProfileXSpace + likeProfileDim), likeProfileY, likeProfileDim, likeProfileDim)
                profilePic.profileButton!.addTarget(self, action: Selector("didTapLikerButtonAction:"), forControlEvents: UIControlEvents.TouchUpInside)
                profilePic.profileButton!.tag = i

                
                if PAPUtility.userHasProfilePictures(likeUsers![i]) {
                    profilePic.setFile((likeUsers![i] as PFUser).objectForKey(kPAPUserProfilePicSmallKey) as? PFFile)
                } else {
                    profilePic.setImage(PAPUtility.defaultProfilePicture()!)
                }

                likeBarView!.addSubview(profilePic)
                currentLikeAvatars.append(profilePic)
            }
            
            self.setNeedsDisplay()
        }
    }

    func setLikeButtonState(selected: Bool) {
        if selected {
            likeButton!.titleEdgeInsets = UIEdgeInsetsMake(-1.0, 0.0, 0.0, 0.0)
        } else {
            likeButton!.titleEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        }
        likeButton!.selected = selected
    }

    func reloadLikeBar() {
        likeUsers = PAPCache.sharedCache.likersForItem(self.item!)
        self.setLikeButtonState(PAPCache.sharedCache.isItemLikedByCurrentUser(self.item!))
        likeButton!.addTarget(self, action: Selector("didTapLikeItemButtonAction:"), forControlEvents: UIControlEvents.TouchUpInside)
    }

    // MARK:- ()

    private func createView() {
        /*
         Create middle section of the header view; the image
         */
        self.itemImageView = PFImageView(frame: CGRectMake(mainImageX, mainImageY, mainImageWidth, mainImageHeight))
        self.itemImageView!.image = UIImage(named: "PlaceholderPhoto.png")
        self.itemImageView!.backgroundColor = UIColor.blackColor()
        self.itemImageView!.contentMode = UIViewContentMode.ScaleAspectFit
        
        let imageFile: PFFile? = self.item!.objectForKey(kPAPItemPictureKey) as? PFFile

        if imageFile != nil {
            self.itemImageView!.file = imageFile
            self.itemImageView!.loadInBackground()
        }
        
        self.addSubview(self.itemImageView!)
        
        /*
         Create top of header view with name and avatar
         */
        self.nameHeaderView = UIView(frame: CGRectMake(nameHeaderX, nameHeaderY, nameHeaderWidth, nameHeaderHeight))
        self.nameHeaderView!.backgroundColor = UIColor.whiteColor()
        self.addSubview(self.nameHeaderView!)
        
        // Load data for header
        self.itemgrapher!.fetchIfNeededInBackgroundWithBlock { (object, error) in
            // Create avatar view
            let avatarImageView = PAPProfileImageView(frame: CGRectMake(avatarImageX, avatarImageY, avatarImageDim, avatarImageDim))

            if PAPUtility.userHasProfilePictures(self.itemgrapher!) {
                avatarImageView.setFile(self.itemgrapher!.objectForKey(kPAPUserProfilePicSmallKey) as? PFFile)
            } else {
                avatarImageView.setImage(PAPUtility.defaultProfilePicture()!)
            }

            avatarImageView.backgroundColor = UIColor.clearColor()
            avatarImageView.opaque = false
            avatarImageView.profileButton!.addTarget(self, action: Selector("didTapUserNameButtonAction:"), forControlEvents: UIControlEvents.TouchUpInside)
            avatarImageView.contentMode = UIViewContentMode.ScaleAspectFill
            avatarImageView.layer.cornerRadius = 66.0
            avatarImageView.layer.masksToBounds = true
            //[avatarImageView load:^(UIImage *image, NSError *error) {}];
            self.nameHeaderView!.addSubview(avatarImageView)
            
            // Create name label
            let nameString = self.itemgrapher!.objectForKey(kPAPUserDisplayNameKey) as! String
            let userButton = UIButton(type: UIButtonType.Custom)
            self.nameHeaderView!.addSubview(userButton)
            userButton.backgroundColor = UIColor.clearColor()
            userButton.titleLabel!.font = UIFont.boldSystemFontOfSize(15.0)
            userButton.setTitle(nameString, forState: UIControlState.Normal)
            userButton.setTitleColor(UIColor(red: 34.0/255.0, green: 34.0/255.0, blue: 34.0/255.0, alpha: 1.0), forState: UIControlState.Normal)
            userButton.setTitleColor(UIColor(red: 114.0/255.0, green: 114.0/255.0, blue: 114.0/255.0, alpha: 1.0), forState: UIControlState.Highlighted)
            userButton.titleLabel!.lineBreakMode = NSLineBreakMode.ByTruncatingTail
            userButton.addTarget(self, action: Selector("didTapUserNameButtonAction:"), forControlEvents: UIControlEvents.TouchUpInside)
            
            // we resize the button to fit the user's name to avoid having a huge touch area
            let userButtonPoint: CGPoint = CGPointMake(50.0, 6.0)
            let constrainWidth: CGFloat = self.nameHeaderView!.bounds.size.width - (avatarImageView.bounds.origin.x + avatarImageView.bounds.size.width)
            let constrainSize: CGSize = CGSizeMake(constrainWidth, self.nameHeaderView!.bounds.size.height - userButtonPoint.y*2.0)
            let userButtonSize: CGSize = userButton.titleLabel!.text!.boundingRectWithSize(constrainSize,
                                                                             options: [NSStringDrawingOptions.TruncatesLastVisibleLine, NSStringDrawingOptions.UsesLineFragmentOrigin],
                                                                          attributes: [NSFontAttributeName: userButton.titleLabel!.font],
                                                                             context: nil).size

            
            let userButtonFrame: CGRect = CGRectMake(userButtonPoint.x, userButtonPoint.y, userButtonSize.width, userButtonSize.height)
            userButton.frame = userButtonFrame
            
            // Create time label
            let timeString: String = timeFormatter!.stringForTimeIntervalFromDate(NSDate(), toDate: self.item!.createdAt!)
            let timeLabelSize: CGSize = timeString.boundingRectWithSize(CGSizeMake(nameLabelMaxWidth, CGFloat.max),
                                                            options: [NSStringDrawingOptions.TruncatesLastVisibleLine, NSStringDrawingOptions.UsesLineFragmentOrigin],
                                                         attributes: [NSFontAttributeName: UIFont.systemFontOfSize(11.0)],
                                                            context: nil).size
            
            let timeLabel = UILabel(frame: CGRectMake(timeLabelX, nameLabelY+userButtonSize.height, timeLabelSize.width, timeLabelSize.height))
            timeLabel.text = timeString
            timeLabel.font = UIFont.systemFontOfSize(11.0)
            timeLabel.textColor = UIColor(red: 114.0/255.0, green: 114.0/255.0, blue: 114.0/255.0, alpha: 1.0)
            timeLabel.backgroundColor = UIColor.clearColor()
            self.nameHeaderView!.addSubview(timeLabel)
            
            self.setNeedsDisplay()
        }
        
        /*
         Create bottom section fo the header view; the likes
         */
        likeBarView = UIView(frame: CGRectMake(likeBarX, likeBarY, likeBarWidth, likeBarHeight))
        likeBarView!.backgroundColor = UIColor.whiteColor()
        self.addSubview(likeBarView!)
        
        // Create the heart-shaped like button
        likeButton = UIButton(type: UIButtonType.Custom)
        likeButton!.frame = CGRectMake(likeButtonX, likeButtonY, likeButtonDim, likeButtonDim)
        likeButton!.backgroundColor = UIColor.clearColor()
        likeButton!.setTitleColor(UIColor(red: 254.0/255.0, green: 149.0/255.0, blue: 50.0/255.0, alpha: 1.0), forState: UIControlState.Normal)
        likeButton!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
        likeButton!.titleEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        likeButton!.titleLabel!.font = UIFont.systemFontOfSize(12.0)
        likeButton!.titleLabel!.minimumScaleFactor = 0.8
        likeButton!.titleLabel!.adjustsFontSizeToFitWidth = true
        likeButton!.adjustsImageWhenDisabled = false
        likeButton!.adjustsImageWhenHighlighted = false
        likeButton!.setBackgroundImage(UIImage(named: "ButtonLike.png"), forState: UIControlState.Normal)
        likeButton!.setBackgroundImage(UIImage(named: "ButtonLikeSelected.png"), forState: UIControlState.Selected)
        likeButton!.addTarget(self, action: Selector("didTapLikeItemButtonAction:"), forControlEvents: UIControlEvents.TouchUpInside)
        likeBarView!.addSubview(likeButton!)
        
        self.reloadLikeBar()
        
        let separator = UIImageView(image: UIImage(named: "SeparatorComments.png")!.resizableImageWithCapInsets(UIEdgeInsetsMake(0.0, 1.0, 0.0, 1.0)))
        separator.frame = CGRectMake(0.0, likeBarView!.frame.size.height - 1.0, likeBarView!.frame.size.width, 1.0)
        //[likeBarView addSubview:separator];
    }

    func didTapLikeItemButtonAction(button: UIButton) {
        let liked: Bool = !button.selected
        button.removeTarget(self, action: Selector("didTapLikeItemButtonAction:"), forControlEvents: UIControlEvents.TouchUpInside)
        self.setLikeButtonState(liked)

        let originalLikeUsersArray = likeUsers
        var newLikeUsersSet = Set<PFUser>(minimumCapacity: likeUsers!.count)
        
        for likeUser in likeUsers! {
            // add all current likeUsers BUT currentUser
            if likeUser.objectId != PFUser.currentUser()!.objectId {
                newLikeUsersSet.insert(likeUser)
            }
        }
        
        if liked {
            PAPCache.sharedCache.incrementLikerCountForItem(self.item!)
            newLikeUsersSet.insert(PFUser.currentUser()!)
        } else {
            PAPCache.sharedCache.decrementLikerCountForItem(self.item!)
        }
        
        PAPCache.sharedCache.setItemIsLikedByCurrentUser(self.item!, liked: liked)

        self.likeUsers = Array(newLikeUsersSet)

        if (liked) {
            PAPUtility.likeItemInBackground(self.item!, block: { (succeeded, error) in
                if !succeeded {
                    button.addTarget(self, action: Selector("didTapLikeItemButtonAction:"), forControlEvents: UIControlEvents.TouchUpInside)
                    self.likeUsers = originalLikeUsersArray
                    self.setLikeButtonState(false)
                }
            })
        } else {
            PAPUtility.unlikeItemInBackground(self.item!, block: { (succeeded, error) in
                if !succeeded {
                    button.addTarget(self, action: Selector("didTapLikeItemButtonAction:"), forControlEvents: UIControlEvents.TouchUpInside)
                    self.likeUsers = originalLikeUsersArray
                    self.setLikeButtonState(true)
                }
            })
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(PAPItemDetailsViewControllerUserLikedUnlikedItemNotification, object: self.item, userInfo: [PAPItemDetailsViewControllerUserLikedUnlikedItemNotificationUserInfoLikedKey: liked])
    }

    func didTapLikerButtonAction(button: UIButton) {
        let user: PFUser = likeUsers![button.tag]
        if delegate != nil && delegate!.respondsToSelector(Selector("itemDetailsHeaderView:didTapUserButton:user:")) {
            delegate!.itemDetailsHeaderView(self, didTapUserButton: button, user: user)
        }    
    }

    func didTapUserNameButtonAction(button: UIButton) {
        if delegate != nil && delegate!.respondsToSelector(Selector("itemDetailsHeaderView:didTapUserButton:user:")) {
            delegate!.itemDetailsHeaderView(self, didTapUserButton: button, user: self.itemgrapher!)
        }    
    }
}

@objc protocol PAPItemDetailsHeaderViewDelegate: NSObjectProtocol {
    /*!
     Sent to the delegate when the photgrapher's name/avatar is tapped
     @param button the tapped UIButton
     @param user the PFUser for the itemgraper
     */
    func itemDetailsHeaderView(headerView: PAPItemDetailsHeaderView, didTapUserButton button: UIButton, user: PFUser)
}
