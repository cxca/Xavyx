//
//  CommentsViewController.m
//  Xavyx
//
//  Created by Xavy on 4/16/14.
//  Copyright (c) 2014 Carlos Chaparro. All rights reserved.
//

#import "CommentsViewController.h"

@interface CommentsViewController ()
{
    AppDelegate *appDelegate;
    UIImage *postProfileImage;
    NSInteger postMainDateCount;
    NSMutableArray *tempMytableArray, *imagesArray, *rowHeightGlobal, *postDateCount;
    NSInteger streamOffset;
    NSInteger refreshCounter;
    UIRefreshControl *refreshControl;
    BOOL isRefreshing;
    BOOL noCommentsFound;
    PictureCountdownTimer *myAction;
    NSDateFormatter *DateFormatter;
    NSNumber *timerCount;
    UILabel *timerLabel;
    UILabel *dateMainLabel;
    dispatch_queue_t queue;
    UIImageView *imageViewMain;
}
@end

@implementation CommentsViewController
@synthesize viewTable;
@synthesize viewForm;
@synthesize chatBox;
@synthesize chatButton;
@synthesize streamCurrentDateTime;

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
    queue = dispatch_queue_create("com.subsystem.task", NULL);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    myAction = [[PictureCountdownTimer alloc]init];
    DateFormatter=[[NSDateFormatter alloc] init];
    tempMytableArray = [[NSMutableArray alloc]init];
    imagesArray = [[NSMutableArray alloc]init];
    rowHeightGlobal = [[NSMutableArray alloc]init];
    postDateCount = [[NSMutableArray alloc]init];
    
    for (NSInteger i = 0; i < 20; ++i)
    {
        [imagesArray addObject:[NSNull null]];
        [postDateCount addObject:[NSNull null]];
    }
    
    streamOffset = 0;
    self.title = NSLocalizedString(@"Conversation", nil);
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(reload) userInfo:nil repeats:YES];
    //Post Information
    _idPhoto = [NSString stringWithFormat:@"%@", [_postDictionary objectForKey:@"IdPhoto"]];
    
    CGRect frameView = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height-92, [[UIScreen mainScreen] bounds].size.width, 44);
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
    
    //Navigation Bar
    [self joinBarButton];

	//turn off scrolling and set the font details.
	chatBox.scrollEnabled = NO;
	chatBox.font = [UIFont fontWithName:@"Helvetica" size:14];
    viewForm = [[UIView alloc]initWithFrame:frameView];
    viewForm.layer.cornerRadius = 5;
    viewForm.clipsToBounds = YES;
    
    viewTable = [[UIView alloc]initWithFrame:frameView];
    viewTable.backgroundColor = [UIColor blackColor];
    viewForm.backgroundColor = [UIColor colorWithRed:(207/255.0) green:(209/255.0) blue:(208/255.0) alpha:1];

    CGRect chatBoxFrame = CGRectMake(5, 5, [[UIScreen mainScreen] bounds].size.width-70, 34);
    
    chatBox = [[UITextView alloc]initWithFrame:chatBoxFrame];
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
    
    [self.view addSubview:viewForm];
    
    //    Refresh control
    refreshControl = [[UIRefreshControl alloc] init];
    
    [refreshControl addTarget:self action:@selector(pullToRefresh)forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    self.tableView.delegate = self;

}
-(void)viewWillAppear:(BOOL)animated
{
    [self refreshStream];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    for (NSInteger i = 0; i < imagesArray.count; ++i)
    {
        [imagesArray addObject:[NSNull null]];
        
    }
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSInteger rowHeight = 289;// 314;
    if(INTERFACE_IS_PAD)
        rowHeight = 429;
    
    NSNumber *number = [rowHeightGlobal objectAtIndex:indexPath.row];
    rowHeight = number.integerValue;
    
    return rowHeight;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cell index: %ld",(long)indexPath.row);
    
    static NSString *commentsTableViewCellIdentifier = @"CellComments";
    
    CommentsTableViewCell *cell;
    cell.delegate = self;
    
    //Comments Cell
    {
        cell = (CommentsTableViewCell*)[tableView dequeueReusableCellWithIdentifier:commentsTableViewCellIdentifier forIndexPath:indexPath];
        if(cell == nil)
        {
            cell = [[CommentsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commentsTableViewCellIdentifier];
        }
        
        //Activity
        if([tempMytableArray count] == 0)
        {
            UIActivityIndicatorView *activity = (UIActivityIndicatorView *)[cell viewWithTag:21];
            [activity startAnimating];
            //Hide
            UIImageView *imageViewProfile = (UIImageView*)[cell viewWithTag:16];
            UILabel *fullNameLabel =(UILabel *)[cell viewWithTag:17];
            UILabel *dateLabel =(UILabel *)[cell viewWithTag:18];
            imageViewProfile.hidden = YES;
            fullNameLabel.hidden = YES;
            dateLabel.hidden = YES;
            
            if(noCommentsFound)
            {
                [activity stopAnimating];
                UILabel *noCommentsLabel =(UILabel *)[cell viewWithTag:22];
                noCommentsLabel.text = NSLocalizedString(@"No comments", nil);
                noCommentsLabel.hidden = NO;

            }

        }
        else
        {
            UIActivityIndicatorView *activity = (UIActivityIndicatorView *)[cell viewWithTag:21];
            [activity stopAnimating];
            //Unhide
            UIImageView *imageViewProfile = (UIImageView*)[cell viewWithTag:16];
            UILabel *fullNameLabel =(UILabel *)[cell viewWithTag:17];
            UILabel *dateLabel =(UILabel *)[cell viewWithTag:18];
            imageViewProfile.hidden = NO;
            fullNameLabel.hidden = NO;
            dateLabel.hidden = NO;
            noCommentsFound = NO;
            
            UILabel *noCommentsLabel =(UILabel *)[cell viewWithTag:22];
            noCommentsLabel.hidden = YES;


        }
        //Cell properties
        int width = 320;
        if(INTERFACE_IS_PAD)
            width = iPadWidth;

        int tmpCount = streamOffset+17;
        NSNumber *tempCount2 = [NSNumber numberWithInt:indexPath.row];
        if(indexPath.row >= [tempMytableArray count]-3 && tempCount2.intValue >= (int)tmpCount)
        {
            streamOffset = streamOffset +20;
            for (NSInteger i = 0; i < 20; ++i)
            {
                [imagesArray addObject:[NSNull null]];
                [postDateCount addObject:[NSNull null]];
            }
            [self refreshStream];
        }
        
        if([tempMytableArray count] >= indexPath.row)
        {
            NSDictionary *dictionary = [tempMytableArray objectAtIndex:indexPath.row];
            //    Get firstname, lastname
            NSString *fullName = [NSString stringWithFormat:@"%@ %@",[dictionary objectForKey:@"firstName"],[dictionary objectForKey:@"lastName"]];
            UILabel *fullNameLabel =(UILabel *)[cell viewWithTag:17];
            fullNameLabel.text = fullName;
            //  Date
            NSString *dateStr = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"transactionDateTime"]];
            [DateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *datePosted = [DateFormatter dateFromString:dateStr];
            NSDate *currentDate = [DateFormatter dateFromString:streamCurrentDateTime];
            //            Diference
            NSTimeInterval diff = [datePosted timeIntervalSinceDate:currentDate];
            NSLog(@"Date life: %@ current: %@",datePosted, currentDate);
            NSLog(@"Date diff: %f",diff);
            NSNumber *tmpTime = [NSNumber numberWithLong:diff];
            if(diff <= 0.0)
                tmpTime = [NSNumber numberWithInt:0];
            [postDateCount replaceObjectAtIndex:indexPath.row withObject:tmpTime];
            long secondIncrease = (long)diff;
            
            NSString *tmpString = [myAction timeCounterString:labs(secondIncrease)];

            UILabel *dateLabel =(UILabel *)[cell viewWithTag:18];
            dateLabel.text = tmpString;
            
            //Comment
            NSString *commentStr = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"comment"]];
            UITextView *commentTextView = (UITextView*)[cell viewWithTag:19];
            
            if(INTERFACE_IS_PAD)
            {
                [commentTextView setScrollEnabled:YES];
                NSInteger deviceRowHeight = 104;
                NSString *str = [NSString stringWithFormat:@"%@",rowHeightGlobal[indexPath.row]];
                CGRect frame = CGRectMake(32, 66, 700, str.integerValue-deviceRowHeight);
                commentTextView.frame = frame;
                commentTextView.contentSize = CGSizeMake(700, str.integerValue);
                CGRect newTextViewFrame = commentTextView.frame;
                newTextViewFrame.size.width = commentTextView.contentSize.width + commentTextView.contentInset.right + commentTextView.contentInset.left;
                newTextViewFrame.size.height = commentTextView.contentSize.height + commentTextView.contentInset.top + commentTextView.contentInset.bottom;
                commentTextView.frame = newTextViewFrame;
                [self contraint:commentTextView cell:cell constant:str.integerValue-deviceRowHeight];

            }
            commentTextView.text = commentStr;
            if(INTERFACE_IS_PAD)
            {
                [commentTextView sizeToFit];
                [commentTextView setScrollEnabled:NO];
                commentTextView.layoutManager.allowsNonContiguousLayout = false;

                [commentTextView layoutIfNeeded];
            }
            int numLines = commentTextView.contentSize.height / commentTextView.font.lineHeight;
            
            //Cell properties
            CGRect cellFrame = CGRectMake(0, 314, width, 75+20*numLines);
            if(INTERFACE_IS_PAD)
                cellFrame = CGRectMake(0, 467, width, 104+15*numLines);
            cell.frame = cellFrame;
        }
    if([tempMytableArray count]>0)
    {
        if([imagesArray objectAtIndex:indexPath.row] == [NSNull null])
        {
            NSDictionary *dictionary = [tempMytableArray objectAtIndex:indexPath.row];
            //Profile Image
            UIImageView *imageViewProfile = (UIImageView*)[cell viewWithTag:16];
            NSString *str = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"IdUser"]];
            
                [self getPrifilePicture:imageViewProfile userId:str.integerValue index:indexPath.row];
        }
        else//when not null
        {
            //Profile Image
            UIImageView *imageViewProfile = (UIImageView*)[cell viewWithTag:16];
            imageViewProfile.image = [imagesArray objectAtIndex:indexPath.row];
          
        }
    }


    }
    return cell;
}
-(void)contraint:(UITextView*)centerView cell:(UITableViewCell*)cell constant:(NSInteger)constant
{
    // Height constraint, half of parent view height
    [cell addConstraint:[NSLayoutConstraint constraintWithItem:centerView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:cell
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:0
                                                           constant:constant+30]];
    
    // Center horizontally
    [cell addConstraint:[NSLayoutConstraint constraintWithItem:centerView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:cell
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0]];
}

- (CGFloat)textViewHeightForAttributedText:(NSAttributedString *)text andWidth:(CGFloat)width
{
    UITextView *textView = [[UITextView alloc] init];
    [textView setAttributedText:text];
    CGSize size = [textView sizeThatFits:CGSizeMake(width, FLT_MAX)];
    return size.height;
}

#pragma mark Fetch
-(void)refreshStream {
    //just call the "stream" command from the web API
    timer =nil;

    NSString* command = @"commentsFetch";
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
                //NSLog(@"Response stream %@",responseObject);
                NSLog(@"Response success");
                
                
                [tempMytableArray addObjectsFromArray:[responseObject objectForKey:@"result"]];
                if([tempMytableArray count] == 0)
                {
                    noCommentsFound = YES;
                }
                
                for(NSDictionary *dictionary in tempMytableArray)
                {
                    NSString *commentStr = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"comment"]];
                    UITextView *commentTextView = [[UITextView alloc]init];
                    if(INTERFACE_IS_PAD)
                    {
                        CGRect frame = CGRectMake(32, 66, 700, 52);
                        commentTextView.frame = frame;
                    }

                    commentTextView.text = commentStr;
                    if(INTERFACE_IS_PAD)
                        [commentTextView sizeToFit];
                    
                    CGSize sizeThatShouldFitTheContent = [commentTextView sizeThatFits:commentTextView.frame.size];
                    CGSize size = [commentStr sizeWithAttributes:@{NSFontAttributeName:commentTextView.font}]; // default mode
                    int numberOfLines = sizeThatShouldFitTheContent.height / commentTextView.font.lineHeight;
                    if(INTERFACE_IS_PHONE)
                        numberOfLines = size.height / commentTextView.font.lineHeight;

                    NSInteger rowHeight;
                    if(INTERFACE_IS_PHONE)
                        rowHeight = 65+15*numberOfLines;
                    else
                        rowHeight = 80+15*numberOfLines;
                    NSNumber *number = [NSNumber numberWithInteger:rowHeight];
                    [rowHeightGlobal addObject:number];
                }
                [self.tableView reloadData];
                [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:1.0];

                NSLog(@"Respond stream: %@",tempMytableArray);
            }
            else
            {
                NSLog(@"Error: Authorization failed");
                [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:1.0];
            }
            
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self refreshStream];
        
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
    [refreshControl endRefreshing];
}

#pragma mark-Buttons
- (void)likeCommentButtonTappedOnCell:(id)sender {
    NSIndexPath *indepath = [self.tableView indexPathForCell:sender];
    
    NSLog(@"cell %i", indepath.row);
}
- (void)flagButtonTappedOnCell:(id)sender {
    NSIndexPath *indepath = [self.tableView indexPathForCell:sender];
    
    NSLog(@"cell %i", indepath.row);
}
- (void)deleteButtonTappedOnCell:(id)sender {
    
}

#pragma mark Comments
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
	formFrame.origin.y -= kbSizeH-50;
    
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3f];
    
	// set views with new info
	viewTable.frame = tableFrame;
	viewForm.frame = formFrame;
    chatButton.enabled = YES;

	// commit animations
	[UIView commitAnimations];
}
-(void) keyPressed: (NSNotification*) notification{
	// get the size of the text block so we can work our magic
    CGRect newSize = [chatBox.text boundingRectWithSize: CGSizeMake(230,9999)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:14]}
                                                context:nil];

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
			formFrame.origin.y = 162 - (newSizeH - y);
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
        chatButton.enabled = NO;
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
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{[_tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
                    }
                     completion:^(BOOL finished){
                         [self pullToRefresh];

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
                         formFrame.origin.y = [[UIScreen mainScreen] bounds].size.height-90;
                         viewForm.frame = formFrame;
                         
                         // table view
                         CGRect tableFrame = viewTable.frame;
                         tableFrame.size.height = 415;
                         viewTable.frame = tableFrame;
                     }];
    
    
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
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UIView * txt in self.view.subviews){
        if ([txt isKindOfClass:[UITextField class]] && [txt isFirstResponder]) {
            [txt resignFirstResponder];
        }
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Table did select");
    if ([chatBox isKindOfClass:[UITextField class]] && [chatBox isFirstResponder]) {
        [chatBox resignFirstResponder];
    }

}
#pragma mark Timer
-(void)reload
{
    //Timer update
    long tmpInteger = [timerCount longValue];
    tmpInteger = tmpInteger-1;
     NSString *str = [myAction timeRemainingString:tmpInteger];
     timerLabel.text = str;
    timerCount = [NSNumber numberWithLong:tmpInteger];
    
    //Date
    postMainDateCount++;
    str = [myAction timeCounterString:postMainDateCount];
    dateMainLabel.text = str;

    //Refresh every 5 mins
    refreshCounter++;
    if(refreshCounter >= 200)
    {
        refreshCounter = 0;
        [self pullToRefresh];
    }
 }
-(void)pullToRefresh
{
    [self getCurrentDateTime];
    streamOffset = 0;
    //remove all objects from mutable array*******
    [tempMytableArray removeAllObjects];
    [imagesArray removeAllObjects];
    [rowHeightGlobal removeAllObjects];
    [postDateCount removeAllObjects];
    
    for (NSInteger i = 0; i < 20; ++i)
    {
        [imagesArray addObject:[NSNull null]];
        [postDateCount addObject:[NSNull null]];
        
    }
    [self refreshStream];
}

#pragma  mark-ProfilePicture
-(void)getPrifilePicture:(UIImageView*)imageViewLocal userId:(NSInteger)udid index:(NSInteger)index
{

    //Get Image from server
    NSString *imageUrl = [NSString stringWithFormat:@"%@/%@/%@/%d.jpg",kAPIHost,kAPIPath,@"profile",udid];

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Successfully downloaded");
        //3
        dispatch_async(dispatch_get_main_queue(), ^{
            // do stuff with image
        
            imageViewLocal.image = [UIImage imageWithData:responseObject];
        });
            if (responseObject == nil && [UIImage imageNamed:@"profilePicture"] == nil) {
                imageViewLocal.image = [UIImage imageNamed:@"profilePicture"];
                [imagesArray replaceObjectAtIndex:index withObject:[UIImage imageNamed:@"profilePicture"]];
            }
            else
            {
                if(index >=0)
                {
                    if ([UIImage imageWithData:responseObject] != nil)
                        [imagesArray replaceObjectAtIndex:index withObject:[UIImage imageWithData:responseObject]];
                }
            }
            [self stopRefresh];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        imageViewLocal.image = [UIImage imageNamed:@"profilePicture"];
        [self stopRefresh];
    }];
    
    [operation start];
    
}
-(void)getPostProfilePicture:(UIImageView*)imageViewLocal userId:(NSInteger)udid
{
    
    //Get Image from server
    NSString *imageUrl = [NSString stringWithFormat:@"%@/%@/%d.jpg",kAPIHost,@"profile",udid];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Successfully downloaded");
        //3
            // do stuff with image
        
        if ([UIImage imageWithData:responseObject] == nil) {
            imageViewLocal.image = [UIImage imageNamed:@"profilePicture"];
        }else {
            postProfileImage = [UIImage imageWithData:responseObject];
            imageViewLocal.image = [UIImage imageWithData:responseObject];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        imageViewLocal.image = [UIImage imageNamed:@"profilePicture"];
    }];
    
    [operation start];
    
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [chatBox resignFirstResponder];
    // get keyboard size and loction
    
	CGRect keyboardBounds;
    
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
-(void) scrollToTop
{
    if ([self numberOfSectionsInTableView:self.tableView] > 0)
    {
        NSIndexPath* top = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView scrollToRowAtIndexPath:top atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

-(void)joinBarButton
{
    NSLog(@"Button Join/Opt out");
  
    NSString* command = @"checkConversation";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   command, @"command",
                                   _idPhoto, @"IdPhoto",
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
                NSString *nr = [NSString stringWithFormat:@"%@",[responseObject objectForKey:@"nr"]];
                if([nr isEqualToString:@"0"])
                {
                    //Navigation Bar
                    //if nt joined
                    UIBarButtonItem *joinItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Join", nil) style:UIBarButtonItemStylePlain target:self action:@selector(joinButtonPressed)];
                    self.navigationItem.rightBarButtonItem = joinItem;
                }
                else
                {
                    //Navigation Bar
                    UIBarButtonItem *optOutItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Leave", nil) style:UIBarButtonItemStylePlain target:self action:@selector(optOutButtonPressed)];
                    self.navigationItem.rightBarButtonItem = optOutItem;
                }
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
-(void)joinButtonPressed
{
    if (![@"1" isEqualToString:[[NSUserDefaults standardUserDefaults]
                                objectForKey:@"pushNotificationComments"]]) {
        [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"pushNotificationComments"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: NSLocalizedString(@"Notifications",nil) message: NSLocalizedString(@"Joining a conversation will send you push notifications from anyone who comment in this picture. If you have disable push notifications you need to enable it. Go to Settings -> Notification Center -> Xavyx", nil) delegate: self cancelButtonTitle:@"Got it!" otherButtonTitles:nil];
        
        [alert show];
    }
//    else
        [self joinConversationNetwork:@"joinConversation"];
}
-(void)optOutButtonPressed
{
    [self joinConversationNetwork:@"removeConversation"];

}
-(void)joinConversationNetwork:(NSString*)command
{
    NSLog(@"Button Join/Opt out");
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   command, @"command",
                                   _idPhoto, @"IdPhoto",
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
                if([command isEqualToString:@"removeConversation"])
                {
                    //Navigation Bar
                    //if nt joined
                    UIBarButtonItem *joinItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Join", nil) style:UIBarButtonItemStylePlain target:self action:@selector(joinButtonPressed)];
                    self.navigationItem.rightBarButtonItem = joinItem;
                }
                else
                {
                    //Navigation Bar
                    UIBarButtonItem *optOutItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Leave", nil) style:UIBarButtonItemStylePlain target:self action:@selector(optOutButtonPressed)];
                    self.navigationItem.rightBarButtonItem = optOutItem;
                }
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
-(void)getMainImage
{
    NSString *imageUrl = [NSString stringWithFormat:@"%@/%@/%@.jpg",kAPIHost,@"upload",[_postDictionary objectForKey:@"IdPhoto"]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Successfully downloaded");
    
        dispatch_async(dispatch_get_main_queue(), ^{
            // do stuff with image
            imageViewMain.image = [UIImage imageWithData:responseObject];
            
        });
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];

    [operation start];
}
@end
