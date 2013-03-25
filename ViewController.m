//
//  ViewController.m
//  TumblrShare
//
//  Created by Lucian Boboc on 3/14/13.
//  Copyright (c) 2013 Lucian Boboc. All rights reserved.
//



#import "ViewController.h"
#import "NSURLConnection+downloads.h"




#pragma mark - TUMBLR STATIC STRINGS
static NSString *kTumblrMyClientID = @"Yyj9ZOua8IlObJJqHRVPizJO08Il5hJMfZILPqTYHkVv9MIdoy";
static NSString *kTumblrMyClientSecret =  @"s7qaTifRHRiVFKcFRjD4jbhAYr1kkkAzMyyzGH87P5EK1EiqI5";
static NSString *kTumblrKeychainItemName = @"OAuth2_Adevarul";
static NSString *kTumblrRedirectURI = @"http://www.adevarul.ro/callback/oauth";
static NSString *kTumblrOAuthScope = @"posting";
static NSString *kTumblrRequestTokenURL = @"https://www.tumblr.com/oauth/request_token";
static NSString *kTumblrAccessTokenURL = @"https://www.tumblr.com/oauth/access_token";
static NSString *kTumblrAuthorizationURL = @"https://www.tumblr.com/oauth/authorize";

static NSString *const kTumblrURLRequestString = @"http://api.tumblr.com/v2/user/info";
#define kTumblrAuthorize 1888




@interface ViewController () <UIAlertViewDelegate>
@property (strong, nonatomic) GTMOAuthAuthentication *auth;
@property (strong, nonatomic) NSOperationQueue *myQueue;
@property (weak, nonatomic) IBOutlet UIButton *tumblrButton;
@property (strong, nonatomic) NSString *blogName;
- (IBAction)tumblrAction:(id)sender;


// ONLY FOR TESTING
@property (strong, nonatomic) NSString *titleStringForShare;
@property (strong, nonatomic) NSString *urlStringForShare;



#pragma mark - Tumblr
- (GTMOAuthAuthentication *)myCustomAuth;
- (void)signInToCustomService;
- (void) authorizeTumblr;
- (void) postToTumblr;
- (void) reloadObjectFromKeychain;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(!self.myQueue)
        self.myQueue = [[NSOperationQueue alloc] init];
    
    [self reloadObjectFromKeychain];
    
    // ONLY FOR TESTING
    self.titleStringForShare = @"Cine sunt iezuiţii, ordinul din care face parte noul Papă, Jorge Bergoglio?";
    self.urlStringForShare = @"http://adevarul.ro/international/europa/cine-iezuitii-ordinul-parte-noul-papa-jorge-bergoglioi-1_514191bc00f5182b8507244a/index.html";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}








#pragma mark - tumblr methods

- (IBAction)tumblrAction:(id)sender
{
    BOOL isSignedIn = [self.auth canAuthorize];
    if(isSignedIn)
    {
        [self postToTumblr];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Message" message: @"To share on Tumblr you must authorize first." delegate: self cancelButtonTitle: @"Cancel" otherButtonTitles: @"Authorize", nil];
        alert.tag = kTumblrAuthorize;
        [alert show];
    }
}


- (void) authorizeTumblr
{
    [self signInToCustomService];
}

- (void)signInToCustomService
{
    NSURL *requestURL = [NSURL URLWithString: kTumblrRequestTokenURL];
    NSURL *accessURL = [NSURL URLWithString: kTumblrAccessTokenURL];
    NSURL *authorizeURL = [NSURL URLWithString: kTumblrAuthorizationURL];
    NSString *scope = kTumblrOAuthScope;
    
    GTMOAuthAuthentication *auth = [self myCustomAuth];
    [auth setCallback: kTumblrRedirectURI];
    
    GTMOAuthViewControllerTouch *viewController = [[GTMOAuthViewControllerTouch alloc] initWithScope:scope
                                                                                            language:nil
                                                                                     requestTokenURL: requestURL
                                                                                   authorizeTokenURL: authorizeURL
                                                                                      accessTokenURL: accessURL
                                                                                      authentication: auth
                                                                                      appServiceName: kTumblrKeychainItemName
                                                                                            delegate: self
                                                                                    finishedSelector: @selector(viewController:finishedWithAuth:error:)];
    [[self navigationController] pushViewController:viewController animated:YES];
}


- (GTMOAuthAuthentication *)myCustomAuth
{
    NSString *myConsumerKey = kTumblrMyClientID;    // pre-registered with service
    NSString *myConsumerSecret = kTumblrMyClientSecret; // pre-assigned by service
    
    GTMOAuthAuthentication *auth;
    auth = [[GTMOAuthAuthentication alloc] initWithSignatureMethod:kGTMOAuthSignatureMethodHMAC_SHA1 consumerKey:myConsumerKey privateKey:myConsumerSecret];
    
    auth.serviceProvider = kTumblrKeychainItemName;
    
    return auth;
}


- (void)viewController:(GTMOAuthViewControllerTouch *)viewController finishedWithAuth:(GTMOAuthAuthentication *)auth error:(NSError *)error {
    if (error != nil) {
        // Authentication failed
        NSLog(@"%@",error.localizedDescription);
    } else {
        self.auth = auth;
        // Authentication succeeded
        // Call the tumblrAction again
        [self tumblrAction: nil];
    }
}

- (void) reloadObjectFromKeychain
{
    // Get the saved authentication, if any, from the keychain.
    GTMOAuthAuthentication *auth = [self myCustomAuth];
    if (auth) {
        BOOL didAuth = [GTMOAuthViewControllerTouch authorizeFromKeychainForName: kTumblrKeychainItemName authentication: auth];
        if(!didAuth)
            NSLog(@"Controller not authorized after viewDidLoad is called");
        else
            NSLog(@"Controller is authorized after viewDidLoad is called");
    }    
    self.auth = auth;
}




- (void) postToTumblr
{
    [self getTumblrBlogName];
}

- (void) getTumblrBlogName
{
    NSURL *url = [NSURL URLWithString: kTumblrURLRequestString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url];
    
    [request setHTTPMethod: @"GET"];
    
    [self.auth authorizeRequest: request];
    
    self.tumblrButton.enabled = NO;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [NSURLConnection sendAsynchronousRequest: request queue: self.myQueue completionHandler: ^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if(error != nil)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 self.tumblrButton.enabled = YES;
                 [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error" message: error.localizedDescription delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
                 [alert show];
                 NSLog(@"error: %@",error.localizedDescription);
             });
         }
         else if(error == nil)
         {
             NSError *jsonError = nil;
             NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData: data options: 0  error: &jsonError];
             if(jsonError)
                 NSLog(@"jsonError: %@",jsonError.localizedDescription);
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 self.tumblrButton.enabled = YES;
                 [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                 self.blogName = [[[dict objectForKey: @"response"] objectForKey: @"user"] objectForKey: @"name"];
                 if(self.blogName)
                     [self sendTumblrPostRequest: self.blogName];
             });
         }
     }];
}



- (void) sendTumblrPostRequest:(NSString *)blogName
{
    NSString *urlString = [[NSString stringWithFormat:@"http://api.tumblr.com/v2/blog/%@.tumblr.com/post",blogName] stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString: urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url];
    
    NSString *string = [NSString stringWithFormat: @"type=text&title=%@&body=%@",self.titleStringForShare,self.urlStringForShare];
    
    NSData *data = [string dataUsingEncoding: NSUTF8StringEncoding];
    
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod: @"POST"];
    [request setHTTPBody: data];
    
    self.tumblrButton.enabled = NO;
    [self.auth authorizeRequest: request];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [NSURLConnection sendAsynchronousRequest: request queue: self.myQueue completionHandler: ^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if(error != nil)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                 self.tumblrButton.enabled = YES;
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error" message: error.localizedDescription delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
                 [alert show];
                 NSLog(@"error: %@",error.localizedDescription);
             });
             
         }
         else if(error == nil)
         {
             NSError *jsonError = nil;
             NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData: data options: 0  error: &jsonError];
             NSLog(@"%@",dict);
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 self.tumblrButton.enabled = YES;
                 NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                 if(httpResponse.statusCode == 201)
                 {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Message" message: @"Sharing to Tumblr Successful!" delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil];
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
    if(alertView.tag == kTumblrAuthorize)
    {
        if(buttonIndex != alertView.cancelButtonIndex)
        {
            [self authorizeTumblr];
        }
    }
}

@end
