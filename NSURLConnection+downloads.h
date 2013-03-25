//
//  NSURLConnection+downloads.h
//  Created by Lucian Boboc on 1/27/13.
//


// This NSURLConnection category was created to help you do 3 things easier:
// 1. return an UIImage from a URL
// 2. return an NSMutableArray from a URL/JSON
// 3. return an NSMutableDictionary from a URL/JSON

// To use this methods you should pass an instance of NSOperationQueue and the urlData string to be set on the NSMutableURLRquest for the HTTPBody property.
// If the server required GET instead of POST method for the JSON you can change the method in the implementation file as needed.
// If the NSError object is nil, the image/array/discionary is returnted.



#import <Foundation/Foundation.h>

typedef void (^DownloadImageCompletionBlock)(UIImage *image, NSError *error);
typedef void (^DownloadImageDataCompletionBlock)(NSData *imageData, NSError *error);
typedef void (^DownloadJSONArrayCompletionBlock)(NSMutableArray *array, NSError *error);
typedef void (^DownloadJSONDictionaryCompletionBlock)(NSMutableDictionary *dictionary, NSError *error);

@interface NSURLConnection (downloadImage)

+ (void) downloadImageFromURLString: (NSString *) urlString method: (NSString *) method  operationQueue: (NSOperationQueue *) queue completionBlock: (DownloadImageCompletionBlock) theBlock;

+ (void) downloadImageDataFromURLString: (NSString *) urlString method: (NSString *) method  operationQueue: (NSOperationQueue *) queue completionBlock: (DownloadImageDataCompletionBlock) theBlock;

+ (void) downloadJSONArrayFromURLString: (NSString *) urlString urlData: (NSString *) urlData method: (NSString *) method operationQueue: (NSOperationQueue *) queue completionBlock: (DownloadJSONArrayCompletionBlock) theBlock;

+ (void) downloadJSONDictionaryFromURLString: (NSString *) urlString urlData: (NSString *) urlData method: (NSString *) method operationQueue: (NSOperationQueue *) queue completionBlock: (DownloadJSONDictionaryCompletionBlock) theBlock;

@end
