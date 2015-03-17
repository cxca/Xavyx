//
//  CommentsTableViewController.m
//  Xavyx
//
//  Created by Xavy on 4/13/14.
//  Copyright (c) 2014 Carlos Chaparro. All rights reserved.
//

#import "CommentsTableViewController.h"
#define isiPhone5  ([[UIScreen mainScreen] bounds].size.height == 568)?TRUE:FALSE

@interface CommentsTableViewController () 
{
    AppDelegate *appDelegate;
    NSMutableArray *tempMytableArray;
    NSString *streamCurrentDateTime;
    NSInteger streamOffset;

}
@end

@implementation CommentsTableViewController
@synthesize viewTable;
@synthesize viewForm;
@synthesize chatBox;
@synthesize chatButton;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
     self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //UIView for comment textfield
    
    CGRect frameView = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height-44, [[UIScreen mainScreen] bounds].size.width, 44);
    _commentView = [[UIView alloc]initWithFrame:frameView];
    
    //Comments
    //set notification for when keyboard shows/hides
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
	//set notification for when a key is pressed.
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector: @selector(keyPressed:)
                                                 name: UITextViewTextDidChangeNotification
                                               object: nil];
    
	//turn off scrolling and set the font details.
	chatBox.scrollEnabled = NO;
	chatBox.font = [UIFont fontWithName:@"Helvetica" size:14];
    viewForm = [[UIView alloc]initWithFrame:frameView];
    viewTable = [[UIView alloc]initWithFrame:frameView];
    viewTable.backgroundColor = [UIColor blackColor];
    viewForm.backgroundColor = [UIColor lightGrayColor];
    CGRect chatBoxFrame = CGRectMake(5, 5, [[UIScreen mainScreen] bounds].size.width-70, 34);

    chatBox = [[UITextView alloc]initWithFrame:chatBoxFrame];
    //To make the border look very close to a UITextField
//    [chatBox.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
//    [chatBox.layer setBorderWidth:2.0];
    
    //The rounded corner part, where you specify your view's corner radius:
    chatBox.layer.cornerRadius = 8;
    chatBox.clipsToBounds = YES;
    
    CGRect chatButtonFrame = CGRectMake([[UIScreen mainScreen] bounds].size.width-55, 5, 50, 34);
    
    chatButton = [UIButton buttonWithType:UIButtonTypeCustom];
    chatButton.frame = chatButtonFrame;
    [chatButton addTarget:self action:@selector(chatButtonClick:) forControlEvents:UIControlEventTouchUpInside];

    [chatButton setImage:[UIImage imageNamed:@"sendArrow"] forState:UIControlStateNormal];
    [chatButton setImage:[UIImage imageNamed:@"sendArrowHighlighted"] forState:UIControlStateHighlighted];

    chatButton.userInteractionEnabled = YES;
    [viewForm addSubview:chatBox];
    [viewForm addSubview:chatButton];
    
//    [[[UIApplication sharedApplication] keyWindow] addSubview:viewTable];
    [[[UIApplication sharedApplication] keyWindow] addSubview:viewForm];
    
    
    //    Refresh control
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    
    //    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    
    
    
    [refresh addTarget:self action:@selector(pullToRefresh)forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refresh;


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [tempMytableArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark Fetch
-(void)refreshStream {
    //just call the "stream" command from the web API
    timer =nil;
    /*
     [[API sharedClient] commandWithParams:params onCompletion:^(NSDictionary *json) {
     //got stream
     
     [self.tableView reloadData];
     }];
     */
    
    NSString* command = @"stream";
    if(appDelegate.controllerView == 1)
        command = @"commentsFetch";
    NSString* tmpOffset = [NSString stringWithFormat:@"%ld",(long)streamOffset];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   command, @"command",
                                   _idPhoto, @"IdPhoto",
                                   tmpOffset, @"offset",
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
                //                NSLog(@"Response stream %@",responseObject);
                NSLog(@"Response success");
                
                
                [tempMytableArray addObjectsFromArray:[responseObject objectForKey:@"result"]];

                NSLog(@"Respond stream: %@",tempMytableArray);
//                [self getCurrentDateTime];

            }
            else
            {
                NSLog(@"Error: Authorization failed");
                [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:2.0];
            }
            
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:2.0];
        
    }];
    
    
}
-(void)getCurrentDateTime
{
    
    NSString* command = @"dateTime";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   command, @"command",
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
                streamCurrentDateTime = [NSString stringWithFormat:@"%@",[responseObject objectForKey:@"dateTime"]];
                NSLog(@"Respond currentDateTime: %@",streamCurrentDateTime);
                [self.tableView reloadData];
                [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:2.0];
                
                
                
            }
            else
            {
                NSLog(@"Error: Authorization failed");
                [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:2.0];
            }
            
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:2.0];
        
    }];
}
- (void)stopRefresh
{
    //    isRefreshing = false;
    
    [self.refreshControl endRefreshing];
    
}
#pragma mark-Buttons
- (void)likeButtonTappedOnCell:(id)sender {
    NSIndexPath *indepath = [self.tableView indexPathForCell:sender];
    
    NSLog(@"cell %i", indepath.row);
    
    
}
- (void)flagButtonTappedOnCell:(id)sender {
    NSIndexPath *indepath = [self.tableView indexPathForCell:sender];
    
    NSLog(@"cell %i", indepath.row);
    

    
}
- (void)deleteButtonTappedOnCell:(id)sender {

}

//Comment Field
-(void)viewWillDisappear:(BOOL)animated
{
//    viewForm = nil;
    [viewForm removeFromSuperview];
    [viewTable removeFromSuperview];
}
-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loction
	CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    
	// get the height since this is the main value that we need.
	NSInteger kbSizeH = keyboardBounds.size.height;
    
	// get a rect for the table/main frame
	CGRect tableFrame = viewTable.frame;
	tableFrame.size.height -= kbSizeH;
    
	// get a rect for the form frame
	CGRect formFrame = viewForm.frame;
	formFrame.origin.y -= kbSizeH-0;
    
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3f];
    
	// set views with new info
	viewTable.frame = tableFrame;
	viewForm.frame = formFrame;
    
	// commit animations
	[UIView commitAnimations];
}
-(void) keyPressed: (NSNotification*) notification{
	// get the size of the text block so we can work our magic
    CGRect newSize = [chatBox.text boundingRectWithSize: CGSizeMake(230,9999)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:14]}
                                         context:nil];
    /*
	CGSize newSize = [chatBox.text
                      sizeWithFont:[UIFont fontWithName:@"Helvetica" size:14]
                      constrainedToSize:CGSizeMake(222,9999)
                      lineBreakMode:UILineBreakModeWordWrap];
     */
	NSInteger newSizeH = newSize.size.height;
	NSInteger newSizeW = newSize.size.width;
    
    // I output the new dimensions to the console
    // so we can see what is happening
	NSLog(@"NEW SIZE : %d X %d", newSizeW, newSizeH);
	if (chatBox.hasText)
	{
        // if the height of our new chatbox is
        // below 90 we can set the height
		if (newSizeH <= 90)
		{
//			[chatBox scrollRectToVisible:CGRectMake(0,0,1,1) animated:NO];
            
			// chatbox
			CGRect chatBoxFrame = chatBox.frame;
			NSInteger chatBoxH = chatBoxFrame.size.height;
			NSInteger chatBoxW = chatBoxFrame.size.width;
			NSLog(@"CHAT BOX SIZE : %d X %d", chatBoxW, chatBoxH);
			chatBoxFrame.size.height = newSizeH + 20;
			chatBox.frame = chatBoxFrame;
            
			// form view
            NSInteger y;
            if(INTERFACE_IS_PHONE)
            {
                if(isiPhone5)
                    y = 124;
                else
                    y =35;
            }
            else
                y = 530;
            
			CGRect formFrame = viewForm.frame;
			NSInteger viewFormH = formFrame.size.height;
			NSLog(@"FORM VIEW HEIGHT : %d", viewFormH);
			formFrame.size.height = 30 + newSizeH;
			formFrame.origin.y = 199 - (newSizeH - y);
			viewForm.frame = formFrame;
            
			// table view
			CGRect tableFrame = viewTable.frame;
			NSInteger viewTableH = tableFrame.size.height;
			NSLog(@"TABLE VIEW HEIGHT : %d", viewTableH);
			tableFrame.size.height = 199 - (newSizeH - 18);
			viewTable.frame = tableFrame;
		}
        
        // if our new height is greater than 90
        // sets not set the height or move things
        // around and enable scrolling
		if (newSizeH > 90)
		{
			chatBox.scrollEnabled = YES;
		}
	}
}
- (IBAction)chatButtonClick:(id)sender{
    //Insert comment
    if([chatBox.text length] >0)
    {
        
        NSString* command = @"commentInsert";
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       command, @"command",
                                       _idPhoto, @"IdPhoto",
                                       chatBox.text, @"comment",
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
                    
                    [self finishWithComment];
                }
                else
                {
                    NSLog(@"Error: Authorization failed");
                    //                [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:2.0];

                    [self finishWithComment];

                }
                
                
            }
            else{
                [self finishWithComment];

            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            //        [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:2.0];
            [self finishWithComment];
            
        }];
        
    }
	
}
-(void)finishWithComment
{
    // hide the keyboard, we are done with it.
    [chatBox resignFirstResponder];
    chatBox.text = nil;
    
    // chatbox
    CGRect chatBoxFrame = chatBox.frame;
    chatBoxFrame.size.height = 34;
    chatBox.frame = chatBoxFrame;
    // form view
    CGRect formFrame = viewForm.frame;
    formFrame.size.height = 45;
    formFrame.origin.y = [[UIScreen mainScreen] bounds].size.height-44;
    viewForm.frame = formFrame;
    
    // table view
    CGRect tableFrame = viewTable.frame;
    tableFrame.size.height = 415;
    viewTable.frame = tableFrame;
}
-(void) keyboardWillHide:(NSNotification *)note{
    // get keyboard size and loction
    
	CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    
	// get the height since this is the main value that we need.
	NSInteger kbSizeH = keyboardBounds.size.height;
    
	// get a rect for the table/main frame
	CGRect tableFrame = viewTable.frame;
	tableFrame.size.height += kbSizeH;
    
	// get a rect for the form frame
	CGRect formFrame = viewForm.frame;
	formFrame.origin.y += kbSizeH;
    
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3f];
    
	// set views with new info
	viewTable.frame = tableFrame;
	viewForm.frame = formFrame;
    
	// commit animations
	[UIView commitAnimations];
}

#pragma mark Timer
-(void)reload
{
   /* for(NSInteger i = 0;i<[timerArray count];i++ )
    {
        //        if(!isRefreshing)
        {
            if([timerArray objectAtIndex:i] != [NSNull null])
            {
                NSNumber *tmpNumber = [timerArray objectAtIndex:i];
                long tmpInteger = [tmpNumber longValue];
                tmpInteger = tmpInteger-1;
                tmpNumber = [NSNumber numberWithLong:tmpInteger];
                [timerArray replaceObjectAtIndex:i withObject:tmpNumber];
                //                dispatch_async(dispatch_get_main_queue(),^{
                
                UILabel *likesLabel = labelsArray[i][0];
                UILabel *timerLabel =labelsArray[i][1];
                
                NSString *str = [myAction timeRemainingString:tmpInteger];
                timerLabel.text = str;
                NSArray *array = @[likesLabel,timerLabel];
                
                [labelsArray replaceObjectAtIndex:i withObject:array];
                //                });
            }
            //            dispatch_async(dispatch_get_main_queue(),^{
            
            
            //        if(!isRefreshing)
            //            [self.tableView reloadData];
            //        });
        }
        
    }*/
}
@end
