//
//  MySuperAppViewController_iPad.h
//  MySuperApplication_iPad
//
//  Created by Viadeo on 20/09/11.
//  Copyright (c) 2011 Viadeo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VDConnect.h"

@interface MySuperAppViewController_iPad : UIViewController <ViadeoConnectDelegate, VDRequestDelegate> {
    Viadeo *viadeo;
}

@property (nonatomic, retain) Viadeo *viadeo;

@property (nonatomic, retain) IBOutlet UIButton *logInButton;
@property (nonatomic, retain) IBOutlet UIButton *logOutButton;
@property (nonatomic, retain) IBOutlet UIButton *getMyProfileButton;
@property (nonatomic, retain) IBOutlet UIButton *postButton;
@property (nonatomic, retain) IBOutlet UIButton *putButton;
@property (nonatomic, retain) IBOutlet UIButton *deleteButton;

- (IBAction)selectLogInButton;
- (IBAction)selectLogOutButton;
- (IBAction)selectGetMyProfileButton;
- (IBAction)selectPostButton;
- (IBAction)selectPutButton;
- (IBAction)selectDeleteButton;

@end
