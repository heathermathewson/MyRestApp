//
//  ApiManager.m
//  ApiTest
//
//  Created by ios on 10/23/15.
//  Copyright © 2015 Brandon. All rights reserved.
//

#import "ApiManager.h"

NSString *SERVER_API_BASE_URL = @"http://localhost:5000";

@interface ApiManager ()

@property (readonly, strong, nonatomic) NSString *serverBase;
@property (strong, nonatomic) NSString *authToken;

@end

@implementation ApiManager

+(instancetype)getInstance {
    // the 'static' keyword causes this line to only be executed once, ever.
    static ApiManager *instance = nil;
    
    // what is this doing?
    if (!instance) {
        NSLog(@"initializing ApiManager");
        instance = [[ApiManager alloc] initWithServerBase:SERVER_API_BASE_URL];
    }
    
    return instance;
}

- (instancetype)initWithServerBase:(NSString *)serverBase {
    self = [self init];

    _serverBase = serverBase;
    
    return self;
}

/**
 * This is a convenience method that takes a url fragment like '/path/to/something'
 * and it makes an absolute url like 'http://myapi.com/path/to/something'
 * you can also add substitution values like this:
 * [self url:@"/my/path?auth%@", self.authToken], which produces 'http://myapi.com/my/path?auth=ABC123'
 */
- (NSString *)url:(NSString *)pathFormat, ... NS_FORMAT_FUNCTION(1, 2) {

    va_list args;
    va_start(args, pathFormat);
    pathFormat = [[NSString alloc] initWithFormat:pathFormat arguments:args];
    va_end(args);
    
    return [NSString stringWithFormat:@"%@%@", self.serverBase, pathFormat];
}

#pragma mark CHALLENGE #1 - let's do this together with a projector
    //method call for registering a new user with all that needs to be done in it
- (void)registerNewUsername:(NSString *)username withPassword:(NSString *)password completion:(void (^)(NSString *))completion failure:(void (^)(void))failure
{
    //beginning to talk to server: like picking up the phone
    NSURLSession *urlSession = [NSURLSession sharedSession];
    //make a request object (NSMutableURLRequest)
    //next step: like looking up the number to use
    
    NSURL *url = [NSURL URLWithString:@"http://104.236.231.254:5000/user"];
    
    //making the call: dialing the number
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    //populate the request with the info from documentation
    //first step for giving information:introduction
    request.HTTPMethod = @"POST";
    //create dictionary
    //why you called/what you are planning on doing while talking
    NSMutableDictionary *userDataDictionary = [[NSMutableDictionary alloc]init];
    //the items in the dictionary
    [userDataDictionary setObject:username forKey:@"username"];
    [userDataDictionary setObject:password forKey:@"password"];
    //setHeader or Body
    
    //declaring an error so we can use it
    NSError *error;
    
    //final packaging before sending, if not done correctly then error
    NSData *dataToPass = [NSJSONSerialization dataWithJSONObject:userDataDictionary options:0 error:&error];
   //put the basket into the car/put the data into the http body
    request.HTTPBody = dataToPass;
    
    //tell server what type of info to expect//talk to me in the application/json"language", say it explicitly in "content-type"
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    //actually pass info to server//everything is ready to go//dataTaskWithRequest sends request to server
     NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //did my server call work?
         if (error)
         {
             NSLog(@"error %ld", (long)((NSHTTPURLResponse *)response).statusCode);
             failure();
         }
         else
         {
             NSLog(@"connected %ld",(long)((NSHTTPURLResponse *)response).statusCode);
             if (((NSHTTPURLResponse *)response).statusCode == 200)
             {//data is the binary, the encoding is UTF-8 String
                 NSString *createdAuthToken = [[NSString alloc]initWithData:data encoding: NSUTF8StringEncoding];
                 self.authToken = createdAuthToken;
                 completion(createdAuthToken);
             }
             else
             {
                 failure();
             }
         }
         NSLog(@"hi");
    }];
    //now go
    [dataTask resume];
    
}

#pragma mark CHALLENGE #2 - with a partner
- (void)authenticateUser:(NSString *)username withPassword:(NSString *)password completion:(void (^)(NSString *))completion failure:(void (^)(void))failure
{
    NSURLSession *urlSession = [NSURLSession sharedSession];

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://104.236.231.254:5000/auth?username=%@&password=%@",username, password]];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

    request.HTTPMethod = @"POST";

    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error)
        {
            NSLog(@"error %ld", (long)((NSHTTPURLResponse *)response).statusCode);
            failure();
        }
        else
        {
            NSLog(@"connected success %ld",(long)((NSHTTPURLResponse *)response).statusCode);
            if (((NSHTTPURLResponse *)response).statusCode == 200)
            {
                NSString *createdAuthToken = [[NSString alloc]initWithData:data encoding: NSUTF8StringEncoding];
                self.authToken = createdAuthToken;
                completion(createdAuthToken);
            }
            else
            {
                failure();
            }
        }
        NSLog(@"hello");
    }];
    [dataTask resume];
    
}

#pragma mark CHALLENGE #3 - with a partner or on your own
- (void)fetchAllUserDataWithCompletion:(void (^)(NSArray<User *> *))completion failure:(void (^)(void))failure
{
    NSURLSession *urlSession = [NSURLSession sharedSession];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://104.236.231.254:5000/user?auth=%@", self.authToken]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    request.HTTPMethod = @"GET";
    
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error)
        {
            NSLog(@"error %ld", (long)((NSHTTPURLResponse *)response).statusCode);
            failure();
        }
        else
        {
            NSLog(@"all is fetched %ld",(long)((NSHTTPURLResponse *)response).statusCode);
            if (((NSHTTPURLResponse *)response).statusCode == 200)
            {
                NSString *createdAuthToken = [[NSString alloc]initWithData:data encoding: NSUTF8StringEncoding];
                self.authToken = createdAuthToken;
                completion([User usersFromData:data]);
            }
            else
            {
                failure();
            }
        }
        NSLog(@"hello again");
    }];
    [dataTask resume];
    
 
}

#pragma mark CHALLENGE #4 - with a partner or on your own
-(void)saveDevice:(Device *)device forUser:(User *)user completion:(void (^)(void))completion failure:(void (^)(void))failure {

}

-(BOOL)isAuthenticated {
    return self.authToken;
}

/**
 * BONUS CHALLENGES...
 *
 * Below here you'll find methods that will flesh out this API Manager
 * even more. Pick and choose which you're interested in and ask for help...
 * Heads up! These have actually not been implemented as any prep for this
 * exercise, so you're probably the first one doing these!
 */

-(void)logout {
    NSLog(@"Hi! Does anybody want to implement ApiManager.logout ;)");
    
    // what should this method do?
    
    // How do we DELETE an auth token from the API?
    
    // What if ApiManager simply 'forgets' its auth token?
    
    // What do you think this method should really do?
}

@end
