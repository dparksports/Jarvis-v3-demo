//
//  MGAboutController.m
//  Data Robot
//
//  Created by Dan Park on 1/3/14.
//  Copyright (c) 2014 magicpoint.us. All rights reserved.
//

#import "MGAboutController.h"
//#import "MGLiveMeterController.h"
//#import "Flurry.h"

@interface MGAboutController ()
<MFMailComposeViewControllerDelegate,
MFMessageComposeViewControllerDelegate,
UIActionSheetDelegate>
{
    
}
@property (nonatomic, copy) NSString *appTitle;
@end

@implementation MGAboutController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setAppTitle:@"Just Call Me Pro"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [Flurry logEvent:@"About"];
//    [Flurry logPageView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

// -------------------------------------------------------------------------------
//	supportedInterfaceOrientations
//  Support only portrait orientation (iOS 6).
// -------------------------------------------------------------------------------
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

// -------------------------------------------------------------------------------
//	shouldAutorotateToInterfaceOrientation
//  Support only portrait orientation (IOS 5 and below).
// -------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - IBAction

- (void)showAlertView:(NSString *)message
            withTitle:(NSString*)title
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
	
	[alertView show];
}

- (void)composeSMSMessage:(NSArray*)recipients
              withMessage:(NSString*)message
{
	MFMessageComposeViewController *vc = [[MFMessageComposeViewController alloc] init];
    if (! [MFMessageComposeViewController canSendText]) {
		NSString *message = @"Device not configured to send SMS.";
        NSString *title =self.appTitle;
        [self showAlertView:message
                  withTitle:title];
    } else {
        vc.messageComposeDelegate = self;
        [vc setRecipients:recipients];
        [vc setBody:message];
        [self presentViewController:vc animated:YES completion:^(){
        }];
    }
}

- (void)composeEmail:(NSArray*)emailAddresses
         withSubject:(NSString*)subject
         withMessage:(NSString*)message
{
	MFMailComposeViewController *vc = [[MFMailComposeViewController alloc] init];
    if (! [MFMailComposeViewController canSendMail]) {
		NSString *message = @"Device not configured to send email.";
        NSString *title = self.appTitle;
        [self showAlertView:message
                  withTitle:title];
    } else {
        vc.mailComposeDelegate = self;
        [vc setToRecipients:emailAddresses];
        [vc setSubject:subject];
        [vc setMessageBody:message isHTML:NO];
        [self presentViewController:vc animated:YES completion:^(){
        }];
    }
}

- (IBAction)openReviewPage:(id)sender
{
    NSString *appId = @"577770349";
    NSString *address = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&type=Purple+Software", appId];
    NSURL *url = [NSURL URLWithString:address];
    UIApplication *application = [UIApplication sharedApplication];
    if (! [application canOpenURL:url]) {
		NSString *message = @"Device not configured to open App Store App Review.";
        NSString *title = self.appTitle;
        [self showAlertView:message
                  withTitle:title];
    } else {
        [application openURL:url];
    }
}

- (IBAction)openMaker:(id)sender
{
    NSString *address = @"http://appstore.com/hbholding";
    NSURL *url = [NSURL URLWithString:address];
    UIApplication *application = [UIApplication sharedApplication];
    if (! [application canOpenURL:url]) {
		NSString *message = @"Device not configured to open App Store.";
        NSString *title = self.appTitle;
        [self showAlertView:message
                  withTitle:title];
    } else {
        [application openURL:url];
    }
}

- (IBAction)emailSupport:(id)sender
{
    NSArray *emailAddress = @[@"support@magicpoint.us"];
	NSString *subject = [NSString stringWithFormat:@"Support for %@", self.appTitle];
	NSString *message = [NSString stringWithFormat:@"Hi Tech Support, can you help me with ... ?"];
    
    [self composeEmail:emailAddress
           withSubject:subject
           withMessage:message];
}

- (IBAction)shareByEmail:(id)sender
{
    NSArray *emailAddress = nil;
	NSString *subject = @"Share";
	NSString *message = [NSString stringWithFormat:@"Hi, I want to share this app with you.\n\nhttp://appstore.com/hbholding/justcallmepro"];
    
    [self composeEmail:emailAddress
           withSubject:subject
           withMessage:message];
}

- (IBAction)shareBySMS:(id)sender
{
    NSArray *recipients = nil;
	NSString *message = [NSString stringWithFormat:@"Hi, I want to share this app with you.\n\nhttp://appstore.com/hbholding/justcallmepro"];
    
    [self composeSMSMessage:recipients
                withMessage:message];
}

- (IBAction)shareAction:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Share By"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Email", @"SMS / TEXT", nil];
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
	[actionSheet showInView:self.view];	// show from our table view (pops up in the middle of the table)
}

- (IBAction)tappedButtonCancel:(id)sender {
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_async(queue, ^() {
        [self dismissViewControllerAnimated:true completion:^{
        }];
    });
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            [self shareByEmail:nil];
        }
            break;
        case 1:
        {
            [self shareBySMS:nil];
        }
            break;
        default:
            break;
    }
}


#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller
		  didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	switch (result) {
		case MFMailComposeResultCancelled:
        {
		}
			break;
		case MFMailComposeResultSaved:
		{
		}
			break;
			
		case MFMailComposeResultSent:
		{
		}
			break;
			
		case MFMailComposeResultFailed:
		{
            NSString *title = self.appTitle;
			NSString *message = @"Sending email failed.";
			[self showAlertView:message withTitle:title];
		}
			break;
		default:
		{
            NSString *title = self.appTitle;
			NSString *message = @"Sending email unknown error.";
			[self showAlertView:message withTitle:title];
		}
            break;
	}
    [controller dismissViewControllerAnimated:YES completion:^() {
    }];
}

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
				 didFinishWithResult:(MessageComposeResult)result
{
	switch (result)
	{
		case MessageComposeResultCancelled:
		{
		}
			break;
		case MessageComposeResultSent:
		{
		}
			break;
		case MessageComposeResultFailed:
		{
            NSString *title = self.appTitle;
			NSString *message = @"Sending SMS failed.";
			[self showAlertView:message withTitle:title];
		}
			break;
		default:
		{
            NSString *title = self.appTitle;
			NSString *message = @"Sending SMS unknown error.";
			[self showAlertView:message withTitle:title];
		}
            break;
	}
    [controller dismissViewControllerAnimated:YES completion:^() {
    }];
}
@end
