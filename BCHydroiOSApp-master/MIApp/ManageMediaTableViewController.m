//
//  ManageMediaTableViewController.m
//  MIApp
//
//  Created by Gursimran Singh on 12/30/2013.
//  Copyright (c) 2013 BCHydro. All rights reserved.
//

#define FONT_SIZE 14.0f
#define CELL_CONTENT_WIDTH 1024.0f
#define CELL_CONTENT_MARGIN 10.0f

#import "ManageMediaTableViewController.h"
#import "QuestionList.h"
#import "DisplayMultipleChoiceQuestion.h"
#import "DisplayShortAnswerQuestion.h"
#import "DisplayTrueFalseQuestion.h"

@implementation ManageMediaTableViewController
{
    NSArray* videoFiles;
    NSArray* imageFiles;
    NSArray* soundFiles;
}

@synthesize currentQuestion;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
     // to reload selected cell
}

-(void) viewDidLoad{
    [super viewDidLoad];
    
    [self setTitle:@"Manage Media"];
    
    [self getVideoFiles];
    [self getImageFiles];
    
}

-(void) getVideoFiles
{
    videoFiles = [self getfile:@".mov"];
    NSLog(@"Total count: %lu", (unsigned long)[videoFiles count]);
}


-(void) getImageFiles
{
    imageFiles = [self getfile:@".jpg"];
    NSLog(@"Total count: %lu", (unsigned long)[imageFiles count]);
}


-(NSArray*) getfile:(NSString*) ofType
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    NSString *folderPath = [[documentsDirectoryPath stringByAppendingPathComponent:[[QuestionList sharedInstance] fileNameToBeSavedAs]] stringByAppendingString:@"/"];
    //NSString *fileName = [NSString stringWithFormat:@"Qid%@", self.id.stringValue];
    NSArray* listOfFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", ofType];
    
    NSArray* listOfFilesForCurrentType = [listOfFiles filteredArrayUsingPredicate:predicate];
    NSPredicate *predicateForCurrentQuestion = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", [NSString stringWithFormat:@"Qid%@", currentQuestion.stringValue]];
    return [listOfFilesForCurrentType filteredArrayUsingPredicate:predicateForCurrentQuestion];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    
    switch (section)
    {
        case 0:
            if([imageFiles count] > 0){
                sectionName = @"Images";
            }
            else if ([videoFiles count] > 0){
                sectionName = @"Videos";
            }
            else{
                sectionName = @"Voice";
            }
            break;
        case 1:
            if ([videoFiles count] > 0){
                sectionName = @"Videos";
            }
            else{
                sectionName = @"Voice";
            }
            break;
        case 2:
            sectionName = @"Voice";
            break;
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    NSInteger numSections = 0;
    if ([imageFiles count] > 0){
        numSections++;
    }
    if ([videoFiles count] > 0){
        numSections++;
    }
    if([soundFiles count] > 0){
        numSections++;
    }
    NSLog(@"num sections: %ld", (long)numSections);
    return numSections;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSString* titleOfHeader = [[NSString alloc] init];
    titleOfHeader = [self tableView:tableView titleForHeaderInSection:section];
    NSLog(@"Header returned: %@", titleOfHeader);
    NSInteger numRows = 0;
    
    if ([titleOfHeader isEqualToString:@"Images"]){
        numRows = [imageFiles count];
    } else if ([titleOfHeader isEqualToString:@"Videos"]){
        numRows = [videoFiles count];
    } else if ([titleOfHeader isEqualToString:@"Voice"]){
        numRows = [soundFiles count];
    }
    NSLog(@"Rows of section %ld: %ld",(long)section, (long)numRows);
    return numRows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ImageCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UILabel *label = nil;
    UIImageView* imageView = nil;
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        label = [[UILabel alloc] initWithFrame:CGRectZero];
        [label setLineBreakMode:NSLineBreakByWordWrapping];
        [label setNumberOfLines:0];
        [label setFont:[UIFont systemFontOfSize:12.0]];
        [label setTag:1];
        
        [[label layer] setBorderWidth:0.0f];
        
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [imageView setTag:2];
        [[cell contentView] addSubview:imageView];
        [[cell contentView] addSubview:label];
    }
    
    // Configure the cell...
    
    
    NSString* text = @"test";
    
    //CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
    
    //CGSize size = [finalString sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    
    if (!label)
        label = (UILabel*)[cell viewWithTag:1];
    
    if(!imageView)
        imageView = (UIImageView*)[cell viewWithTag:2];
    
    imageView.image = [[UIImage alloc] initWithData:[[NSData alloc] initWithContentsOfFile:[self getFileLocation:indexPath]]];
    
    imageView.frame = CGRectMake(CELL_CONTENT_MARGIN, CELL_CONTENT_MARGIN, 80 , 80 );

    [label setFrame:CGRectMake(imageView.frame.size.width + imageView.frame.origin.x*2, 20, 100, 40)];
    [label setText:text];
    
    cell.frame = CGRectMake(0, 0, 300, MAX(label.frame.size.height, imageView.frame.size.height));
    
    return cell;
    
    //cell.textLabel.text = @"test\ntest";
    //[cell.textLabel sizeToFit];
}

-(NSString*) getFileLocation: (NSIndexPath*) indexPath
{
    NSInteger section = indexPath.section;
    NSString* fileName = [[NSString alloc] init];
    
    switch (section)
    {
        case 0:
            if([imageFiles count] > 0){
                fileName = [imageFiles objectAtIndex:indexPath.row];
            }
            else if ([videoFiles count] > 0){
                fileName = [videoFiles objectAtIndex:indexPath.row];
            }
            else{
                fileName = [soundFiles objectAtIndex:indexPath.row];
            }
            break;
        case 1:
            if ([videoFiles count] > 0){
                fileName = [videoFiles objectAtIndex:indexPath.row];
            }
            else{
                fileName = [soundFiles objectAtIndex:indexPath.row];
            }
            break;
        case 2:
            fileName = [soundFiles objectAtIndex:indexPath.row];
            break;
        default:
            fileName = @"";
            break;
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    NSString *folderPath = [[documentsDirectoryPath stringByAppendingPathComponent:[[QuestionList sharedInstance] fileNameToBeSavedAs]] stringByAppendingString:@"/"];
    NSString *filePath = [folderPath stringByAppendingString:fileName];
    
    return filePath;

}

//
////Called everytime users selects a row.
////Save all rows with checkmarks, that are later used as users response.
//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
//{
//    
//    [QuestionList sharedInstance].nextQuestionID = [[NSNumber alloc] initWithInt:indexPath.row];
//    NSString *firstQuestionType = [[[[QuestionList sharedInstance] questionList] objectAtIndex:indexPath.row] objectForKey:@"answer-type"];
//    
//    if ([firstQuestionType isEqualToString:@"short-answer"]){
//        
//        [self performSegueWithIdentifier:@"ShortAnswer" sender:self];
//        
//    }else if ([firstQuestionType isEqualToString:@"true/false"]){
//        
//        [self performSegueWithIdentifier:@"TrueFalse" sender:self];
//        
//    }else if ([firstQuestionType isEqualToString:@"multiple-choice"]){
//        
//        [self performSegueWithIdentifier:@"MultipleChoice" sender:self];
//        
//    }
//}
//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // this method is called for each cell and returns height
//    
//    NSString* text = [self getString:(int)indexPath.row];
//    
//    //CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
//    
//    //CGSize size = [finalString sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
//    CGSize size = [text sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:FONT_SIZE]}];
//    
//    CGFloat height = MAX(size.height, 44.0f);
//    
//    return height + (CELL_CONTENT_MARGIN * 2);
    return 80;
}
//
//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
//    if([segue.identifier isEqualToString:@"ShortAnswer"]){
//        DisplayShortAnswerQuestion *editQuestion = [segue destinationViewController];
//        editQuestion.EditQuestion = YES;
//    }else if([segue.identifier isEqualToString:@"TrueFalse"]){
//        DisplayTrueFalseQuestion *editQuestion = [segue destinationViewController];
//        editQuestion.EditQuestion = YES;
//    }else if([segue.identifier isEqualToString:@"MultipleChoice"]){
//        DisplayMultipleChoiceQuestion *editQuestion = [segue destinationViewController];
//        editQuestion.EditQuestion = YES;
//    }
//}
//
//-(NSString*)getString:(int) questionID{
//    NSArray* questions = [[QuestionList sharedInstance] questionList];
//    NSDictionary* oneQuestion = [questions objectAtIndex:questionID];
//    NSString* questionString = [oneQuestion objectForKey:@"question"];
//    NSMutableString *userAnswer = [[NSMutableString alloc]init];
//    NSString* commentEntered = [[oneQuestion objectForKey:@"user-answer"] objectForKey:@"comment"];
//    if ([[oneQuestion objectForKey:@"answer-type"] isEqualToString:@"short-answer"]){
//        userAnswer = [[oneQuestion objectForKey:@"user-answer"] objectForKey:@"short-answer"];
//    }else{
//        NSArray* selectedAnswerInListForm = [[oneQuestion objectForKey:@"user-answer"] objectForKey:@"check-boxes"];
//        for (NSString* eachAnswer in selectedAnswerInListForm){
//            [userAnswer appendFormat:@"\n%@", eachAnswer];
//        }
//    }
//    
//    NSString* finalString = [questionString stringByAppendingString:@"\n\nAnswers\n"];
//    finalString = [finalString stringByAppendingString:userAnswer];
//    if ([commentEntered length] != 0){
//        finalString = [finalString stringByAppendingString:@"\n\nComment\n"];
//        finalString = [finalString stringByAppendingString:commentEntered];
//    }
//    return finalString;
//}
//
//- (IBAction)DoneButtonPressed:(id)sender {
//    [self performSegueWithIdentifier:@"Done" sender:self];
//}
//

@end
