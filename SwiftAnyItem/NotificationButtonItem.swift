import UIKit

class NotificationsButtonItem: UIBarButtonItem {

    // MARK:- Initialization

    init(target: AnyObject, action: Selector) {
        let notificationsButton: UIButton = UIButton(type: UIButtonType.Custom)

        super.init()
        customView = notificationsButton
//        [settingsButton setBackgroundImage:[UIImage imageNamed:@"ButtonSettings.png"] forState:UIControlStateNormal];
        notificationsButton.addTarget(target, action: action, forControlEvents: UIControlEvents.TouchUpInside)
        notificationsButton.frame = CGRectMake(0.0, 0.0, 35.0, 32.0)
        notificationsButton.setImage(UIImage(named: "notifs_icon.png"), forState: UIControlState.Normal)
        notificationsButton.setImage(UIImage(named: "notifs_icon.png"), forState:UIControlState.Highlighted)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
