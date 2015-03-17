//
//  FetchComments.m
//  Xavyx
//
//  Created by Xavy on 4/15/14.
//  Copyright (c) 2014 Carlos Chaparro. All rights reserved.
//

#import "FetchComments.h"

@implementation FetchComments
 NSString *count;

-(NSString*)fetchCommentCounts:(NSString*)idPhoto
{
   
    NSString* command = @"commentsCount";
 
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   command, @"command",
                                   idPhoto, @"IdPhoto",
                                   nil];

    NSString *script = [NSString stringWithFormat:@"%@/%@/%@",kAPIHost,kAPIPath,@"app.php"];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:script parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        
        NSArray *response = [responseObject allKeys];
        if(response.count >0)
        {
            
            NSLog(@"Response count %lu",(unsigned long)response.count);
            if(![[response objectAtIndex:0] isEqual: @"error"])
            {
                NSLog(@"Response stream %@",responseObject);
                NSLog(@"Response success");
                
                
                count = [NSString stringWithFormat:@"%@",[responseObject objectForKey:@"nr"]];
                
                NSLog(@"Respond stream comments count: %@",count);
              
            }
            else
            {
                NSLog(@"Error: Authorization failed");
            }
            
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
    }];
    
    return count;
}
@end
