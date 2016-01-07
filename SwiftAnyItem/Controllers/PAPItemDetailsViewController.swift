import UIKit
import ParseUI
import MBProgressHUD

//let kPAPCellInsetWidth: CGFloat = 0.0

class PAPItemDetailsViewController : PFQueryTableViewController, UITextFieldDelegate, PAPItemDetailsHeaderViewDelegate, PAPBaseTextCellDelegate {
    private(set) var item: PFObject?
    private var likersQueryInProgress: Bool
    
    private var commentTextField: UITextField?
    private var headerView: PAPItemDetailsHeaderView?

    // MARK:- Initialization

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: PAPUtilityUserLikedUnlikedItemCallbackFinishedNotification, object: self.item!)
    }
    
    init(item aItem: PFObject) {
        self.likersQueryInProgress = false
        
        super.init(style: UITableViewStyle.Plain, className: nil)
        
        // The className to query on
        self.parseClassName = kPAPActivityClassKey

        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = true

        // Whether the built-in pagination is enabled
        self.paginationEnabled = true
        
        // The number of comments to show per page
        self.objectsPerPage = 30
        
        self.item = aItem
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK:- UIViewController
    override func viewDidLoad() {
        self.tableView!.separatorStyle = UITableViewCellSeparatorStyle.None

        super.viewDidLoad()
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "LogoNavigationBar.png"))
        
        // Set table view properties
        let texturedBackgroundView = UIView(frame: self.view.bounds)
        texturedBackgroundView.backgroundColor = UIColor.blackColor()
        self.tableView!.backgroundView = texturedBackgroundView
        
        // Set table header
        self.headerView = PAPItemDetailsHeaderView(frame: PAPItemDetailsHeaderView.rectForView(), item:self.item!)
        self.headerView!.delegate = self
        
        self.tableView.tableHeaderView = self.headerView;
        
        // Set table footer
        let footerView = PAPItemDetailsFooterView(frame: PAPItemDetailsFooterView.rectForView())
        commentTextField = footerView.commentField
        commentTextField!.delegate = self
        self.tableView.tableFooterView = footerView

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: Selector("actionButtonAction:"))
        
        // Register to be notified when the keyboard will be shown to scroll the view
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("userLikedOrUnlikedItem:"), name: PAPUtilityUserLikedUnlikedItemCallbackFinishedNotification, object: self.item)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.headerView!.reloadLikeBar()
        
        // we will only hit the network if we have no cached data for this item
        let hasCachedLikers: Bool = PAPCache.sharedCache.attributesForItem(self.item!) != nil
        if !hasCachedLikers {
            self.loadLikers()
        }
    }


    // MARK:- UITableViewDelegate

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row < self.objects!.count { // A comment row
            let object: PFObject? = self.objects![indexPath.row] as? PFObject
            
            if object != nil {
                let commentString: String = object!.objectForKey(kPAPActivityContentKey) as! String
                
                let commentAuthor: PFUser? = object!.objectForKey(kPAPActivityFromUserKey) as? PFUser
                
                var nameString = ""
                if commentAuthor != nil {
                    nameString = commentAuthor!.objectForKey(kPAPUserDisplayNameKey) as! String
                }
                
                return PAPActivityCell.heightForCellWithName(nameString, contentString: commentString, cellInsetWidth: kPAPCellInsetWidth)
            }
        }
        
        // The pagination row
        return 44.0
    }


    // MARK:- PFQueryTableViewController

    override func queryForTable() -> PFQuery {
        let query = PFQuery(className: self.parseClassName!)
        query.whereKey(kPAPActivityItemKey, equalTo: self.item!)
        query.includeKey(kPAPActivityFromUserKey)
        query.whereKey(kPAPActivityTypeKey, equalTo: kPAPActivityTypeComment)
        query.orderByAscending("createdAt")

        query.cachePolicy = PFCachePolicy.NetworkOnly

        // If no objects are loaded in memory, we look to the cache first to fill the table
        // and then subsequently do a query against the network.
        //
        // If there is no network connection, we will hit the cache first.
        if self.objects!.count == 0 || UIApplication.sharedApplication().delegate!.performSelector(Selector("isParseReachable")) != nil {
            query.cachePolicy = PFCachePolicy.CacheThenNetwork
        }
        
        return query
    }

    override func objectsDidLoad(error: NSError?) {
        super.objectsDidLoad(error)

        self.headerView!.reloadLikeBar()
        self.loadLikers()
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        let cellID = "CommentCell"

        // Try to dequeue a cell and create one if necessary
        var cell: PAPBaseTextCell? = tableView.dequeueReusableCellWithIdentifier(cellID) as? PAPBaseTextCell
        if cell == nil {
            cell = PAPBaseTextCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellID)
            cell!.cellInsetWidth = kPAPCellInsetWidth
            cell!.delegate = self
        }
        
        cell!.user = object!.objectForKey(kPAPActivityFromUserKey) as? PFUser
        cell!.setContentText(object!.objectForKey(kPAPActivityContentKey) as! String)
        cell!.setDate(object!.createdAt!)

        return cell
    }

    override func tableView(tableView: UITableView, cellForNextPageAtIndexPath indexPath: NSIndexPath) -> PFTableViewCell? {
        let CellIdentifier = "NextPageDetails"
        
        var cell: PAPLoadMoreCell? = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as? PAPLoadMoreCell
        
        if cell == nil {
            cell = PAPLoadMoreCell(style: UITableViewCellStyle.Default, reuseIdentifier: CellIdentifier)
            cell!.cellInsetWidth = kPAPCellInsetWidth
            cell!.hideSeparatorTop = true
        }
        
        return cell
    }


    // MARK:- UITextFieldDelegate

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let trimmedComment = textField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if trimmedComment.length != 0 && self.item!.objectForKey(kPAPItemUserKey) != nil {
            let comment = PFObject(className: kPAPActivityClassKey)
            comment.setObject(trimmedComment, forKey: kPAPActivityContentKey) // Set comment text
            comment.setObject(self.item!.objectForKey(kPAPItemUserKey)!, forKey: kPAPActivityToUserKey) // Set toUser
            comment.setObject(PFUser.currentUser()!, forKey: kPAPActivityFromUserKey) // Set fromUser
            comment.setObject(kPAPActivityTypeComment, forKey:kPAPActivityTypeKey)
            comment.setObject(self.item!, forKey: kPAPActivityItemKey)
            
            let ACL = PFACL(user: PFUser.currentUser()!)
            ACL.setPublicReadAccess(true)
            ACL.setWriteAccess(true, forUser: self.item!.objectForKey(kPAPItemUserKey) as! PFUser)
            comment.ACL = ACL

            PAPCache.sharedCache.incrementCommentCountForItem(self.item!)
            
            // Show HUD view
            MBProgressHUD.showHUDAddedTo(self.view.superview, animated: true)
            
            // If more than 5 seconds pass since we post a comment, stop waiting for the server to respond
            let timer: NSTimer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: Selector("handleCommentTimeout:"), userInfo: ["comment": comment], repeats: false)

            comment.saveEventually { (succeeded, error) in
                timer.invalidate()
                
                if error != nil && error!.code == PFErrorCode.ErrorObjectNotFound.rawValue {
                    PAPCache.sharedCache.decrementCommentCountForItem(self.item!)
                    
                    let alertController = UIAlertController(title: NSLocalizedString("Could not post comment", comment: ""), message: NSLocalizedString("This item is no longer available", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
                    let alertAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                    alertController.addAction(alertAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                    
                    self.navigationController!.popViewControllerAnimated(true)
                }
                
                NSNotificationCenter.defaultCenter().postNotificationName(PAPItemDetailsViewControllerUserCommentedOnItemNotification, object: self.item!, userInfo: ["comments": self.objects!.count + 1])
                
                MBProgressHUD.hideHUDForView(self.view.superview, animated: true)
                self.loadObjects()
            }
        }
        
        textField.text = ""
        return textField.resignFirstResponder()
    }

    // MARK:- UIScrollViewDelegate

    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        commentTextField!.resignFirstResponder()
    }

    // MARK:- PAPBaseTextCellDelegate

    func cell(cellView: PAPBaseTextCell, didTapUserButton aUser: PFUser) {
        self.shouldPresentAccountViewForUser(aUser)
    }

    // MARK:- PAPItemDetailsHeaderViewDelegate

    func itemDetailsHeaderView(headerView: PAPItemDetailsHeaderView, didTapUserButton button: UIButton, user: PFUser) {
        self.shouldPresentAccountViewForUser(user)
    }


    // MARK:- ()

    func actionButtonAction(sender: AnyObject) {
        let actionController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        if self.currentUserOwnsItem() {
            let deleteItemAction = UIAlertAction(title: NSLocalizedString("Delete Item", comment: ""), style: UIAlertActionStyle.Destructive, handler: { _ in
                // prompt to delete
                self.showConfirmDeleteItemActionSheet()
            })
            actionController.addAction(deleteItemAction)
        }
        let shareItemAction = UIAlertAction(title: NSLocalizedString("Share Item", comment: ""), style: UIAlertActionStyle.Default, handler: { _ in
            self.activityButtonAction(self)
        })
        actionController.addAction(shareItemAction)
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
        actionController.addAction(cancelAction)
        
        presentViewController(actionController, animated: true, completion: nil)
    }
    
    func showConfirmDeleteItemActionSheet() {
        // prompt to delete
        let actionController = UIAlertController(title: NSLocalizedString("Are you sure you want to delete this item?", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let deleteAction = UIAlertAction(title: NSLocalizedString("Yes, delete item", comment: ""), style: UIAlertActionStyle.Destructive, handler: { _ in
            self.shouldDeleteItem()
        })
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
        
        actionController.addAction(deleteAction)
        actionController.addAction(cancelAction)
        
        presentViewController(actionController, animated: true, completion: nil)
    }

    func activityButtonAction(sender: AnyObject) {
        if self.item!.objectForKey(kPAPItemPictureKey)!.isDataAvailable() {
            self.showShareSheet()
        } else {
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            self.item!.objectForKey(kPAPItemPictureKey)!.getDataInBackgroundWithBlock { (data, error) in
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                if error == nil {
                    self.showShareSheet()
                }
            }
        }
    }

    func showShareSheet() {
        self.item!.objectForKey(kPAPItemPictureKey)!.getDataInBackgroundWithBlock { (data, error) in
            if error == nil {
                var activityItems = [AnyObject]()
                            
                // Prefill caption if this is the original poster of the item, and then only if they added a caption initially.
                if (PFUser.currentUser()!.objectId == self.item!.objectForKey(kPAPItemUserKey)!.objectId) && self.objects!.count > 0 {
                    let firstActivity: PFObject = self.objects![0] as! PFObject
                    if firstActivity.objectForKey(kPAPActivityFromUserKey)!.objectId == self.item!.objectForKey(kPAPItemUserKey)!.objectId {
                        let commentString = firstActivity.objectForKey(kPAPActivityContentKey)
                        activityItems.append(commentString!)
                    }
                }
                
                activityItems.append(UIImage(data: data!)!)
                activityItems.append(NSURL(string:  "https://anypic.org/#pic/\(self.item!.objectId!)")!)
                
                let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
                self.navigationController!.presentViewController(activityViewController, animated: true, completion: nil)
            }
        }
    }

    func handleCommentTimeout(aTimer: NSTimer) {
        MBProgressHUD.hideHUDForView(self.view.superview, animated: true)
        
        let alertController = UIAlertController(title: NSLocalizedString("New Comment", comment: ""), message: NSLocalizedString("Your comment will be posted next time there is an Internet connection.", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
        let alertAction = UIAlertAction(title: NSLocalizedString("Dismiss", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(alertAction)
        presentViewController(alertController, animated: true, completion: nil)
    }

    func shouldPresentAccountViewForUser(user: PFUser) {
        let accountViewController = PAPAccountViewController(user: user)
        print("Presenting account view controller with user: \(user)")
        self.navigationController!.pushViewController(accountViewController, animated: true)
    }

    func backButtonAction(sender: AnyObject) {
        self.navigationController!.popViewControllerAnimated(true)
    }

    func userLikedOrUnlikedItem(note: NSNotification) {
        self.headerView!.reloadLikeBar()
    }

    func keyboardWillShow(note: NSNotification) {
        // Scroll the view to the comment text box
        let info = note.userInfo
        let kbSize: CGSize = (info![UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue().size
        self.tableView.setContentOffset(CGPointMake(0.0, self.tableView.contentSize.height-kbSize.height), animated: true)
    }

    func loadLikers() {
        if self.likersQueryInProgress {
            return
        }

        self.likersQueryInProgress = true
        let query: PFQuery = PAPUtility.queryForActivitiesOnItem(item!, cachePolicy: PFCachePolicy.NetworkOnly)
        query.findObjectsInBackgroundWithBlock { (objects, error) in
            self.likersQueryInProgress = false
            if error != nil {
                self.headerView!.reloadLikeBar()
                return
            }
            
            var likers = [PFUser]()
            var commenters = [PFUser]()
            
            var isLikedByCurrentUser = false
            
            for activity in objects! {
                if (activity.objectForKey(kPAPActivityTypeKey) as! String) == kPAPActivityTypeLike && activity.objectForKey(kPAPActivityFromUserKey) != nil {
                    likers.append(activity.objectForKey(kPAPActivityFromUserKey) as! PFUser)
                } else if (activity.objectForKey(kPAPActivityTypeKey) as! String) == kPAPActivityTypeComment && activity.objectForKey(kPAPActivityFromUserKey) != nil {
                    commenters.append(activity.objectForKey(kPAPActivityFromUserKey) as! PFUser)
                }
                
                if ((activity.objectForKey(kPAPActivityFromUserKey) as? PFObject)?.objectId) == PFUser.currentUser()!.objectId {
                    if (activity.objectForKey(kPAPActivityTypeKey) as! String) == kPAPActivityTypeLike {
                        isLikedByCurrentUser = true
                    }
                }
            }
            
            PAPCache.sharedCache.setAttributesForItem(self.item!, likers: likers, commenters: commenters, likedByCurrentUser: isLikedByCurrentUser)
            self.headerView!.reloadLikeBar()
        }
    }

    func currentUserOwnsItem() -> Bool {
        return (self.item!.objectForKey(kPAPItemUserKey) as! PFObject).objectId == PFUser.currentUser()!.objectId
    }

    func shouldDeleteItem() {
        // Delete all activites related to this item
        let query = PFQuery(className: kPAPActivityClassKey)
        query.whereKey(kPAPActivityItemKey, equalTo: self.item!)
        query.findObjectsInBackgroundWithBlock { (activities, error) in
            if error == nil {
                for activity in activities! {
                    activity.deleteEventually()
                }
            }
            
            // Delete item
            self.item!.deleteEventually()
        }
        NSNotificationCenter.defaultCenter().postNotificationName(PAPItemDetailsViewControllerUserDeletedItemNotification, object: self.item!.objectId)
        self.navigationController!.popViewControllerAnimated(true)
    }
}
