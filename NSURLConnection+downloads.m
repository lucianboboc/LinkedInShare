//
//  NSURLConnection+downloads.m
//  Created by Lucian Boboc on 1/27/13.
//

#import "NSURLConnection+downloads.h"

@implementation NSURLConnection (downloads)

+ (void) downloadImageFromURLString: (NSString *) urlString method: (NSString *) method  operationQueue: (NSOperationQueue *) queue completionBlock: (DownloadImageCompletionBlock) theBlock
{
    NSURL *url = [NSURL URLWithString: urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url];
    [request setHTTPMethod: method];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [NSURLConnection sendAsynchronousRequest: request queue: queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
        
        if(error != nil)
            theBlock(nil,error);
        else
        {
            UIImage *image = [UIImage imageWithData: data];
            theBlock(image,nil);
        }
    }];
}

+ (void) downloadImageDataFromURLString: (NSString *) urlString method: (NSString *) method  operationQueue: (NSOperationQueue *) queue completionBlock: (DownloadImageDataCompletionBlock) theBlock
{
    NSURL *url = [NSURL URLWithString: urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url];
    [request setHTTPMethod: method];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [NSURLConnection sendAsynchronousRequest: request queue: queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
        
        if(error != nil)
            theBlock(nil,error);
        else
            theBlock(data,nil);
    }];
}


+ (void) downloadJSONArrayFromURLString: (NSString *) urlString urlData: (NSString *) urlData method: (NSString *) method operationQueue: (NSOperationQueue *) queue completionBlock: (DownloadJSONArrayCompletionBlock) theBlock;
{
    NSURL *url = [NSURL URLWithString: urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url];
    [request setHTTPMethod: method];
    if(urlData)
        [request setHTTPBody: [urlData dataUsingEncoding:NSUTF8StringEncoding]];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [NSURLConnection sendAsynchronousRequest: request queue: queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
        
        if(error != nil)
            theBlock(nil,error);
        else
        {
            NSError *jsonError = nil;
            NSMutableArray *array = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error:&jsonError];
            if(jsonError != nil)
                theBlock(nil,jsonError);
            else
                theBlock(array,nil);
        }
    }];
}

+ (void) downloadJSONDictionaryFromURLString: (NSString *) urlString urlData: (NSString *) urlData method: (NSString *) method operationQueue: (NSOperationQueue *) queue completionBlock: (DownloadJSONDictionaryCompletionBlock) theBlock
{
    NSURL *url = [NSURL URLWithString: urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url];
    [request setHTTPMethod: method];
    if(urlData)
        [request setHTTPBody: [urlData dataUsingEncoding:NSUTF8StringEncoding]];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [NSURLConnection sendAsynchronousRequest: request queue: queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
        
        if(error != nil)
            theBlock(nil,error);
        else
        {
            NSError *jsonError = nil;
            NSMutableDictionary *dictionary = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error:&jsonError];
            if(jsonError != nil)
                theBlock(nil,jsonError);
            else
                theBlock(dictionary,nil);
        }
    }];
}



@end
