//
//  ViewController.m
//  LinkedInShare
//
//  Created by Lucian Boboc on 3/14/13.
//  Copyright (c) 2013 Lucian Boboc. All rights reserved.
//



#import "ViewController.h"
#import "NSURLConnection+downloads.h"




#pragma mark - LinkedIn STATIC STRINGS
// TO BE REPLACES WITH YOUR APP INFO FROM LinkedIn

static NSString *kLinkedInMyClientID = @"s734mx64dyoi";
static NSString *kLinkedInMyClientSecret =  @"LeX71jF1DbcUsyrb";
static NSString *kLinkedInKeychainItemName = @"AppServiceName";
static NSString *kLinkedInRedirectURI = @"http://www.adevarul.ro/callback_accept";

#define kTitleToBeShared @"Title to be shared!"
#define kURLToBeShared @"URL to be shared!"










static NSString *kLinkedInOAuthScope = @"rw_nus";
static NSString *kLinkedInRequestTokenURL = @"https://api.linkedin.com/uas/oauth/requestToken";
static NSString *kLinkedInAccessTokenURL = @"https://api.linkedin.com/uas/oauth/accessToken";
static NSString *kLinkedInAuthorizationURL = @"https://www.linkedin.com/uas/oauth/authorize";

#define kLinkedInAuthorize 20




@interface ViewController () <UIAlertViewDelegate>
@property (strong, nonatomic) GTMOAuthAuthentication *auth;
@property (strong, nonatomic) NSOperationQueue *myQueue;
@property (weak, nonatomic) IBOutlet UIButton *linkedInButton;
@property (strong, nonatomic) NSString *blogName;
- (IBAction)linkedInAction:(id)sender;


// ONLY FOR TESTING
@property (strong, nonatomic) NSString *titleStringForShare;
@property (strong, nonatomic) NSString *urlStringForShare;



#pragma mark - LinkedIn
- (GTMOAuthAuthentication *)myCustomAuth;
- (void)signInToCustomService;
- (void) authorizeLinkedIn;
- (void) postToLinkedIn;
- (void) reloadObjectFromKeychain;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(!self.myQueue)
        self.myQueue = [[NSOperationQueue alloc] init];
    
    [self reloadObjectFromKeychain];    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}




#pragma mark - LinkedIn methods

- (IBAction)linkedInAction:(id)sender
{
    BOOL isSignedIn = [self.auth canAuthorize];
    if(isSignedIn)
    {
        [self postToLinkedIn];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Message" message: @"To share on LinkedIn you must authorize first." delegate: self cancelButtonTitle: @"Cancel" otherButtonTitles: @"Authorize", nil];
        alert.tag = kLinkedInAuthorize;
        [alert show];
    }
}


- (void) authorizeLinkedIn
{
    [self signInToCustomService];
}

- (void)signInToCustomService
{
    NSURL *requestURL = [NSURL URLWithString: kLinkedInRequestTokenURL];
    NSURL *accessURL = [NSURL URLWithString: kLinkedInAccessTokenURL];
    NSURL *authorizeURL = [NSURL URLWithString: kLinkedInAuthorizationURL];
    NSString *scope = kLinkedInOAuthScope;
    
    GTMOAuthAuthentication *auth = [self myCustomAuth];
    [auth setCallback: kLinkedInRedirectURI];
    
    GTMOAuthViewControllerTouch *viewController = [[GTMOAuthViewControllerTouch alloc] initWithScope: scope
                                                                                            language: nil
                                                                                     requestTokenURL: requestURL
                                                                                   authorizeTokenURL: authorizeURL
                                                                                      accessTokenURL: accessURL
                                                                                      authentication: auth
                                                                                      appServiceName: kLinkedInKeychainItemName
                                                                                            delegate: self
                                                                                    finishedSelector: @selector(viewController:finishedWithAuth:error:)];
    
    [[self navigationController] pushViewController:viewController animated:YES];
}


- (GTMOAuthAuthentication *)myCustomAuth
{
    NSString *myConsumerKey = kLinkedInMyClientID;    // pre-registered with service
    NSString *myConsumerSecret = kLinkedInMyClientSecret; // pre-assigned by service
    
    GTMOAuthAuthentication *auth;
    auth = [[GTMOAuthAuthentication alloc] initWithSignatureMethod:kGTMOAuthSignatureMethodHMAC_SHA1 consumerKey:myConsumerKey privateKey:myConsumerSecret];
    
    [auth setServiceProvider:@"LinkedIn"];
    
    return auth;
}


- (void)viewController:(GTMOAuthViewControllerTouch *)viewController finishedWithAuth:(GTMOAuthAuthentication *)auth error:(NSError *)error {
    if (error != nil) {
        // Authentication failed
        NSLog(@"Authentication failed: %@",error.localizedDescription);
    } else {
        self.auth = auth;
        // Authentication succeeded
        NSLog(@"Authentication succeeded");
        // Call the linkedInAction again
        [self linkedInAction: nil];
    }
}

- (void) reloadObjectFromKeychain
{
    // Get the saved authentication, if any, from the keychain.
    GTMOAuthAuthentication *auth = [self myCustomAuth];
    if (auth) {
        BOOL didAuth = [GTMOAuthViewControllerTouch authorizeFromKeychainForName: kLinkedInKeychainItemName authentication: auth];
        if(!didAuth)
            NSLog(@"Controller not authorized after viewDidLoad is called");
        else
            NSLog(@"Controller is authorized after viewDidLoad is called");
    }
    self.auth = auth;
}




- (void) postToLinkedIn
{
    [self sendLinkedInPostRequest];
}


- (void) sendLinkedInPostRequest
{
    NSString *urlString = [NSString stringWithFormat:@"http://api.linkedin.com/v1/people/~/shares"];
    NSURL *url = [NSURL URLWithString: urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url];
    
    NSDictionary *content = @{@"title":kTitleToBeShared, @"submitted-url": kURLToBeShared};
    NSDictionary *visibility = @{@"code": @"anyone"};
    NSDictionary *jsonDictionary = @{@"content": content, @"visibility": visibility};
    
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options: 0  error: &jsonError];    
    if(jsonError)
        NSLog(@"ERROR JSON: %@",jsonError.localizedDescription);
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setAllHTTPHeaderFields: @{@"x-li-format":@"json"}];
    [request setHTTPMethod: @"POST"];
    [request setHTTPBody: jsonData];
    
    self.linkedInButton.enabled = NO;
    [self.auth authorizeRequest: request];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [NSURLConnection sendAsynchronousRequest: request queue: self.myQueue completionHandler: ^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if(error != nil)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                 self.linkedInButton.enabled = YES;
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error" message: error.localizedDescription delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
                 [alert show];
                 NSLog(@"URL RESPONSE ERROR: %@",error.localizedDescription);
             });
             
         }
         else if(error == nil)
         {
             NSError *jsonError = nil;
             NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData: data options: 0  error: &jsonError];
             NSLog(@"%@",dict);
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 self.linkedInButton.enabled = YES;
                 NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                 
                 if(httpResponse.statusCode == 201)
                 {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Message" message: @"Sharing to LinkedIn Successful!" delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil];
                     [alert show];
                 }
                 else
                 {
                     NSString *msg = [[[dict objectForKey: @"response"] objectForKey: @"errors"] objectAtIndex: 0];
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error" message: msg delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
                     [alert show];
                 }
                 [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
             });
         }
     }];
}











#pragma mark UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == kLinkedInAuthorize)
    {
        if(buttonIndex != alertView.cancelButtonIndex)
        {
            [self authorizeLinkedIn];
        }
    }
}

@end

