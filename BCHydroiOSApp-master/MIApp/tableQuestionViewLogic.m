//
//  tableQuestionViewLogic.m
//  MIApp
//
//  Created by Gursimran Singh on 2014-04-01.
//  Copyright (c) 2014 BCHydro. All rights reserved.
//

#import "TableQuestionViewLogic.h"
#import "KeyList.h"
#import "DrawRedRectUIView.h"
#import "DrawRectUIView.h"
#import "UIButtonToStoreRowAndColumn.h"
#import "UITextViewToStoreRowAndColumn.h"

@implementation TableQuestionViewLogic
{
    NSDictionary* visibleCells;
    NSMutableDictionary* userAnswers;
    NSDictionary* preFilledAnswers;
    NSArray* columnSizes;
    NSArray* rowSizes;
    NSArray* firstRow;
    NSArray* firstColumn;
    NSArray* rowType;
    NSArray* noCells;
    int numberOfColumns;
    int numberOfRows;
    UIScrollView* tableScrollView;
    UIView* headerView;
    
    BOOL setupForPrint;
    
    float tableWidth;
}

//initialize a logic object
-(id) initWithQuestion:(NSDictionary*) question collectionViewWidth:(float) width sizeForPrint:(BOOL)print scrollView:(UIScrollView*)scollView headerView:(UIView*)header
{
    self = [super init];
    if (self != nil) {
        //save parameters
        tableWidth = width;
        setupForPrint = print;
        tableScrollView = scollView;
        headerView = header;
        
        //setup question
        [self setup:question];
        
        return self;
    }
    return nil;
}


-(void) setup:(NSDictionary*) question
{
    //get table properties
    visibleCells = [[NSDictionary alloc] init];
    numberOfRows = [[question objectForKey:[[KeyList sharedInstance] rowSizeTemplateKey]] intValue];
    numberOfColumns = [[question objectForKey:[[KeyList sharedInstance] columnSizeTemplateKey]] intValue];
    rowType = [question objectForKey:[[KeyList sharedInstance] rowInputTypeTemplateKey]];
    noCells = [question objectForKey:[[KeyList sharedInstance] noCellsTemplateKey]];
    firstRow = [question objectForKey:[[KeyList sharedInstance] firstRowTemplateKey]];
    firstColumn = [question objectForKey:[[KeyList sharedInstance] firstColumnTemplateKey]];
    
    
    //get saved answers to pre populate table
    NSDictionary *answers = [question objectForKey:[[KeyList sharedInstance] userAnswerToBeSavedTemplateKey]];
    preFilledAnswers = [answers objectForKey:[[KeyList sharedInstance] tableQuestionTypeTemplateKey]];
    
    userAnswers = [[NSMutableDictionary alloc] initWithDictionary:preFilledAnswers];
    
    //check which cells not to be displayed
    [self createDictionaryForViewableCells];
    
    
    //calculate row and column sizes
    [self calculateSizesForAllRowsAndColumns];
    
}

//save all cells to a dictionary to be tested later if it is to be displayed
//key for dictionary is "rowNumber,ColumnNumber". The output is either "no", if the
//cell is not to be displayed or null if it doesnt exist.
-(void) createDictionaryForViewableCells
{
    NSMutableDictionary* temp = [[NSMutableDictionary alloc] init];
    for (NSString* eachCell in noCells) {
        [temp setValue:@"No" forKey:eachCell];
    }
    visibleCells = temp;
}

//Calculate the size of each cell in first row and first column
-(void) calculateSizesForAllRowsAndColumns
{
    [self calculateRowSizes];
    [self calculateColumnSizes];
    [self adjustRowSizeForPrint];
}

//Calculate size of each column.
//DOne by caluclating teh size of each cell in the first row
-(void) calculateColumnSizes
{
    columnSizes = [self getColumnSizes];
}

//Calculate size of each row.
//DOne by caluclating teh size of each cell in the first column
-(void) calculateRowSizes
{
    rowSizes = [self getRowSizes];
}


//From the text that will appear in first column,
//get the height of each cell which will be used as height of that row
// and the width of column 1
-(NSArray*) getRowSizes
{
    
    NSMutableArray* unadjustedRowSizes = [[NSMutableArray alloc] init];
    
    CGSize largestSize = CGSizeMake(0, 0);
    
    for (int i =0; i < [firstColumn count]; i++) {
        
        NSString* str = [firstColumn objectAtIndex:i];
        //for(NSString *str in firstColumn) {
        
        CGSize size;
        if (setupForPrint) {
            size = CGSizeMake(70, INFINITY);
        }else{
            size = CGSizeMake(125,INFINITY);
        }
        
        CGRect textRect = [str
                           boundingRectWithSize:size
                           options:NSStringDrawingUsesLineFragmentOrigin
                           attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.0f]}
                           context:nil];
        
        [unadjustedRowSizes addObject:[NSValue valueWithCGSize:textRect.size]];
        
        if (largestSize.width < textRect.size.width) {
            largestSize = textRect.size;
        }
    }
    
    
    NSMutableArray* adjustedRowSizes = [[NSMutableArray alloc] init];
    
    for (NSValue* eachSize in unadjustedRowSizes) {
        CGSize each = [eachSize CGSizeValue];
        if (each.width < largestSize.width) {
            each.width = largestSize.width;
        }
        [adjustedRowSizes addObject:[NSValue valueWithCGSize:each]];
    }
    
    return adjustedRowSizes;
}

//From the text that will appear in first row,
//get the width of each cell which will be used as width of that row
// and the height of row 1
-(NSArray*) getColumnSizes
{
    
    float maxWidth = (tableWidth  - [[rowSizes objectAtIndex:1] CGSizeValue].width - ([firstRow count] * 4))/([firstRow count]-1);
    
    NSMutableArray* unadjustedColumnSizes = [[NSMutableArray alloc] init];
    
    CGSize largestSize = CGSizeMake(0, 0);
    
    for(NSString *str in firstRow) {
        
        CGSize size = CGSizeMake(maxWidth,INFINITY);
        
        CGRect textRect = [str
                           boundingRectWithSize:size
                           options:NSStringDrawingUsesLineFragmentOrigin
                           attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.0f]}
                           context:nil];
        
        [unadjustedColumnSizes addObject:[NSValue valueWithCGSize:textRect.size]];
        
        if (largestSize.height < textRect.size.height) {
            largestSize = textRect.size;
        }
    }
    
    NSMutableArray* adjustedColumnSizes = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [unadjustedColumnSizes count]; i++) {
        NSValue* eachSize = [unadjustedColumnSizes objectAtIndex:i];
        CGSize each = [eachSize CGSizeValue];
        if (each.height < largestSize.height) {
            each.height = largestSize.height;
        }
        if (i > 0) {
            each.width = maxWidth;
        }else{
            each.width = [[rowSizes objectAtIndex:1] CGSizeValue].width;
        }
        [adjustedColumnSizes addObject:[NSValue valueWithCGSize:each]];
    }
    
    return adjustedColumnSizes;
}


//If getting ready to print, the size of each row needs to take into account the text entered by the user.
//since all the text needs to be visible, if height of text is grater than row then modify row to be equal
//to this new height.
-(void) adjustRowSizeForPrint
{
    
    if (setupForPrint) {
        
        NSMutableArray* newRowHeights = [[NSMutableArray alloc] init];
        
        [newRowHeights addObject:[rowSizes objectAtIndex:0]];
        
        
        for (int i = 1; i < numberOfRows; i++) {
            
            if ([[rowType objectAtIndex:i] isEqualToString:[[KeyList sharedInstance] textRowTypeTemplateKey]]) {
                
                CGSize largestSize = CGSizeMake(0, 0);
                
                for (int j = 1; j < numberOfColumns; j++) {
                    
                    NSString* str = [userAnswers objectForKey:[NSString stringWithFormat:@"%d,%d", i+1,j+1]];
                    
                    CGSize size = CGSizeMake( [[columnSizes objectAtIndex:j] CGSizeValue].width - 14,INFINITY);
                    
                    CGRect textRect = [str
                                       boundingRectWithSize:size
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.0f]}
                                       context:nil];
                    
                    
                    if (largestSize.height < textRect.size.height) {
                        largestSize = textRect.size;
                    }
                    
                }
                
                if (largestSize.height + 12 > [[rowSizes objectAtIndex:i] CGSizeValue].height) {
                    [newRowHeights addObject:[NSValue valueWithCGSize:largestSize]];
                }else{
                    [newRowHeights addObject:[rowSizes objectAtIndex:i]];
                }
            }else{
                [newRowHeights addObject:[rowSizes objectAtIndex:i]];
            }
            
        }
        
        rowSizes = newRowHeights;
        
    }
}


//return total height of table
-(float)getTotalHeight{
    float totalHeight = 0;
    for (int i = 1; i < numberOfRows; i++) {
        totalHeight += [[rowSizes objectAtIndex:i] CGSizeValue].height + 20;
    }
    return totalHeight;
}


//show table
-(void) displayTable
{
    [self displayHeader];
    [self displayBody];
}


//display header view
-(void)displayHeader
{
    float start = 0;
    
    // for every column add a box and text
    for (int i =0; i < [firstRow count]; i++) {
        NSString* string = [firstRow objectAtIndex:i];
        
        // add a box of width the size of text and height as heighht os text + 20
        DrawRectUIView* test = [[DrawRectUIView alloc] initWithFrame:CGRectMake(start, 0, [[columnSizes objectAtIndex:i]CGSizeValue].width+4, [[columnSizes objectAtIndex:0] CGSizeValue].height+ 20)];
        test.backgroundColor = [UIColor whiteColor];
        
        //add a label which contains the text
        UILabel* label = [[UILabel alloc]  initWithFrame:CGRectMake(2, (([[columnSizes objectAtIndex:0] CGSizeValue].height + 20 ) - [[columnSizes objectAtIndex:i] CGSizeValue].height)/2, [[columnSizes objectAtIndex:i] CGSizeValue].width, [[columnSizes objectAtIndex:i] CGSizeValue].height)];
        start = start + [[columnSizes objectAtIndex:i] CGSizeValue].width+4;
        label.font = [UIFont systemFontOfSize:12];
        label.text = string;
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        [test addSubview:label];
        [headerView addSubview:test];
    }
    
}


//display body of table
-(void) displayBody
{
    for (int row = 1; row < numberOfRows; row++) {
        for (int column = 0; column < numberOfColumns; column++) {
            [self addCellAtRow: row atColumn: column];
        }
    }
}


//add cell at row and column
-(void) addCellAtRow:(int)row atColumn:(int) column
{
    
    
    //get position of cell
    CGRect positionOfCell = [self getPositionOfRow:row column:column];
    
    //check if cell is to be displayed or not
    NSString* cell = [NSString stringWithFormat:@"%d,%d", row+1, column];
    if ([[visibleCells objectForKey:cell] isEqualToString:@"No"]) {
        DrawRedRectUIView* test = [[DrawRedRectUIView alloc] initWithFrame:positionOfCell];
        test.backgroundColor = [UIColor grayColor];
        [tableScrollView addSubview:test];
        return;
    }
    
    //Add a black boundary to cell
    DrawRectUIView* test =[[DrawRectUIView alloc] initWithFrame:positionOfCell];
    test.backgroundColor = [UIColor whiteColor];
    test.tag = 100;
    
    
    //if first cell in the row then add row title else add answer field (either textview or check box)
    if (column == 0) {
        float height = [[rowSizes objectAtIndex:row] CGSizeValue].height;
        
        UILabel* rowTitle = [[UILabel alloc] initWithFrame:CGRectMake(2, (positionOfCell.size.height - (height))/2, [[columnSizes objectAtIndex:0] CGSizeValue].width, height)];
        rowTitle.font = [UIFont systemFontOfSize:12.0f];
        rowTitle.tag = 200;
        rowTitle.text = [firstColumn objectAtIndex:row];
        rowTitle.numberOfLines = 0;
        rowTitle.textAlignment = NSTextAlignmentCenter;
        [test addSubview:rowTitle];
    }else{
        
        NSString* key = [NSString stringWithFormat:@"%d,%d", row+1, column+1];
        //check if this row is text field or check box
        //Add text view
        if ([[rowType objectAtIndex:row] isEqualToString:[[KeyList sharedInstance] textRowTypeTemplateKey]]) {
            UITextViewToStoreRowAndColumn* addAnswer = [[UITextViewToStoreRowAndColumn alloc] initWithFrame:CGRectMake(5, 5, test.frame.size.width - 8, test.frame.size.height - 8)];
            addAnswer.tag = 300;
            addAnswer.row = row+1;
            addAnswer.column = column+1;
            [test addSubview:addAnswer];
            addAnswer.delegate = self;
            
            //check if this cell was filled and load value from memory
            if ([preFilledAnswers objectForKey:key] != NULL) {
                addAnswer.text = [preFilledAnswers objectForKey:key];
            }
            
        }
        //Add check box
        else if ([[rowType objectAtIndex:row] isEqualToString:[[KeyList sharedInstance] checkBoxRowTypeTemplateKey]]){
            UIButtonToStoreRowAndColumn* checkBox = [UIButtonToStoreRowAndColumn buttonWithType:UIButtonTypeCustom];
            [checkBox setFrame:CGRectMake(5, 5, test.frame.size.width - 8, test.frame.size.height - 8)];
            [checkBox setImage:[UIImage imageNamed:@"checkBoxSelected"] forState:UIControlStateSelected];
            [checkBox addTarget:self action:@selector(buttonCheckBoxSelected:) forControlEvents:UIControlEventTouchUpInside];
            checkBox.tag = 400;
            [test addSubview:checkBox];
            checkBox.row = row+1;
            checkBox.column = column+1;
            
            //check if this cell was filled and load value from memory
            if ([preFilledAnswers objectForKey:key] != NULL) {
                if ([[preFilledAnswers objectForKey:key] isEqualToString:@"yes"]) {
                    [checkBox setSelected:YES];
                }else{
                    [checkBox setImage:[UIImage imageNamed:@"checkBoxUnSelected"] forState:UIControlStateNormal];
                    [checkBox setSelected:NO];
                }
            }
        }
    }
    
    [tableScrollView addSubview:test];
    
    
}

//Save the text user entered
- (void)textViewDidEndEditing:(UITextView *)textView
{
    UITextViewToStoreRowAndColumn* text = (UITextViewToStoreRowAndColumn*)textView;
    [userAnswers setObject:text.text forKey:[NSString stringWithFormat:@"%d,%d", text.row, text.column]];
}

//Toggle button state to display check box or not
-(void) buttonCheckBoxSelected: (id) sender
{
    UIButtonToStoreRowAndColumn* button = (UIButtonToStoreRowAndColumn*)sender;
    
    [button setImage:[UIImage imageNamed:@"checkBoxUnSelected"] forState:UIControlStateNormal];
    
    // If checked, uncheck and visa versa
    [button setSelected:![button isSelected]];
    
    if ([button isSelected]) {
        [userAnswers setObject:@"yes" forKey:[NSString stringWithFormat:@"%d,%d", button.row, button.column]];
    }else{
        [userAnswers setObject:@"no" forKey:[NSString stringWithFormat:@"%d,%d", button.row, button.column]];
    }
    
}

//calculate position of cell at row and column
-(CGRect) getPositionOfRow:(int)row column:(int)column
{
    float height = [[rowSizes objectAtIndex:row] CGSizeValue].height + 20;
    float width = [[columnSizes objectAtIndex:column] CGSizeValue].width + 4;
    float x = 0;
    float y = 0;
    for (int i=1; i < row; i++) {
        y += [[rowSizes objectAtIndex:i] CGSizeValue].height + 20;
    }
    for (int i=0; i < column; i++) {
        x += [[columnSizes objectAtIndex:i] CGSizeValue].width + 4;
    }
    return CGRectMake(x,y,width, height);
}


//return all user answers
-(NSMutableDictionary*) getUserAnswers
{
    return  userAnswers;
}


//get the height of header
-(float)getHeaderHeight
{
    return [[rowSizes objectAtIndex:0] CGSizeValue].height + 20;
}

//check if user answered all questions
-(BOOL) checkUserAnswersValid
{
    for (int i = 2; i <= numberOfRows; i++) {
        for (int j = 2; j <= numberOfColumns; j++) {
            NSString* key = [NSString stringWithFormat:@"%d,%d", i,j];
            if ((([userAnswers objectForKey:key] == NULL) || ([[userAnswers objectForKey:key] length] == 0)) && ([visibleCells objectForKey:key] == NULL)){
                return NO;
            }
        }
    }
    return YES;
    
}
@end
