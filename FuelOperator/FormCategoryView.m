//
//  FormCategoryView.m
//  FuelOperator
//
//  Created by Gary Robinson on 8/27/13.
//  Copyright (c) 2013 GaryRobinson. All rights reserved.
//

#import "FormCategoryView.h"
#import "InspectionsFormCell.h"
#import "CommentPhotoViewController.h"

#define HEADER_HEIGHT 25
#define BUTTON_HEIGHT 47
#define PROGRESS_HEIGHT 25
#define NAV_BAR_HEIGHT 40

@interface FormCategoryView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *formAnswers;

@property (nonatomic, strong) NSMutableArray *categories;
@property (nonatomic, strong) NSMutableArray *questionsPerCategory;

@end

@implementation FormCategoryView

- (id)initWithFrame:(CGRect)frame singleCategory:(BOOL)single
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.singleCategory = single;
        [self addSubview:self.tableView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(answersUpdated:) name:@"answersUpdated" object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = self.bounds;
    rect.size.height -= BUTTON_HEIGHT;
    self.tableView.frame = self.bounds;
}

- (UITableView *)tableView
{
    if(_tableView == nil)
    {
        _tableView = [[UITableView alloc] initWithFrame:self.bounds];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor fopOffWhiteColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (void)setFormQuestions:(NSArray *)formQuestions
{
    _formQuestions = formQuestions;
    
    //?? need to sort out the categories
    if(!self.singleCategory)
    {
        self.categories = [[NSMutableArray alloc] init];
        self.questionsPerCategory = [[NSMutableArray alloc] init];
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"questionID" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];

        NSString *curCategory = @"";
        for(NSUInteger i=0; i<_formQuestions.count; i++)
        {
            FormQuestion *q = [_formQuestions objectAtIndex:i];
            NSString *catName = q.subCategory;
            if(q.subCategory && q.componentID)
                catName = [NSString stringWithFormat:@"%@ %@ - %@", q.mainCategory, q.componentID, q.subCategory];
            if(![catName isEqualToString:curCategory])
            {
                curCategory =  catName;
                [self.categories addObject:curCategory];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(mainCategory = %@) AND (subCategory = %@)", q.mainCategory, q.subCategory];
                if(q.subCategory && q.componentID)
                    predicate = [NSPredicate predicateWithFormat:@"(mainCategory = %@) AND (subCategory = %@) AND (componentID = %@)", q.mainCategory, q.subCategory, q.componentID];
                NSArray *sectionQuestions = [_formQuestions filteredArrayUsingPredicate:predicate];
                NSArray *sortedQuestions = [sectionQuestions sortedArrayUsingDescriptors:sortDescriptors];
                [self.questionsPerCategory addObject:sortedQuestions];
            }
        }
    }
    
    //make sure all the answers are created
    NSMutableArray *answers = [[NSMutableArray alloc] initWithCapacity:_formQuestions.count];
    for(FormQuestion *q in _formQuestions)
    {
        //?? need to download these from the server, only do this if there's no answer on the server
        FormAnswer *a = q.formAnswer;
        if(!a)
        {
            a = [FormAnswer MR_createEntity];
            a.answer = [NSNumber numberWithInt:kUnanswered];
            a.inspection = self.inspection;
            a.formQuestion = q;
        }
        [answers addObject:a];
    }
    self.formAnswers = [NSArray arrayWithArray:answers];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
//    [[OnlineService sharedService] getUpdatedAnswers:self.formAnswers];
}

- (void)answersUpdated:(id)sender
{
    [self.formCategoryDelegate updateProgressView];
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(self.singleCategory)
        return 1;
    else
        return self.categories.count;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(self.singleCategory)
        return nil;
    
    CGRect rect = CGRectMake(0, 0, tableView.bounds.size.width, HEADER_HEIGHT);
    UIView *headerView = [[UIView alloc] initWithFrame:rect];
    headerView.backgroundColor = [UIColor fopYellowColor];
    
    rect.origin.x = 5;
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:rect];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.font = [UIFont boldFontOfSize:18];
    headerLabel.textAlignment = NSTextAlignmentLeft;
    headerLabel.numberOfLines = 1;
    headerLabel.text = [self.categories objectAtIndex:section];
    [headerLabel sizeToFit];
    headerLabel.frame = CGRectMake(5, 5, tableView.bounds.size.width - 5, headerLabel.frame.size.height);
    
    [headerView addSubview:headerLabel];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(self.singleCategory)
        return 0;
    
    return HEADER_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.singleCategory)
        return self.formQuestions.count;
    else
    {
        NSArray *questions = [self.questionsPerCategory objectAtIndex:section];
        return questions.count;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FormQuestion *question;
    if(self.singleCategory)
        question = [self.formQuestions objectAtIndex:indexPath.row];
    else
    {
        NSArray *questions = [self.questionsPerCategory objectAtIndex:indexPath.section];
        question = [questions objectAtIndex:indexPath.row];
    }
    
    return [InspectionsFormCell getCellHeightForQuestion:question withAnswer:question.formAnswer];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"inspectionsFormCell";
    
    InspectionsFormCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [[InspectionsFormCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier withTarget:self];
    
    FormAnswer *answer;
    if(self.singleCategory)
        answer = [self.formAnswers objectAtIndex:indexPath.row];
    else
    {
        NSArray *questions = [self.questionsPerCategory objectAtIndex:indexPath.section];
        FormQuestion *question = [questions objectAtIndex:indexPath.row];
        answer = question.formAnswer;
    }
    
    cell.formAnswer = answer;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FormAnswer *answer;
    if(self.singleCategory)
        answer = [self.formAnswers objectAtIndex:indexPath.row];
    else
    {
        NSArray *questions = [self.questionsPerCategory objectAtIndex:indexPath.section];
        FormQuestion *question = [questions objectAtIndex:indexPath.row];
        answer = question.formAnswer;
    }
    
//    if([answer.answer integerValue] == kNO)
        [self.formCategoryDelegate editCommentPhotosForAnswer:answer];
}

- (void)didSelectAccessory:(id)sender event:(id)event
{
    if([self.inspection.submitted boolValue])
        return;
    
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    
    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: currentTouchPosition];
    
    FormAnswer *answer;
    if(self.singleCategory)
        answer = [self.formAnswers objectAtIndex:indexPath.row];
    else
    {
        NSArray *questions = [self.questionsPerCategory objectAtIndex:indexPath.section];
        FormQuestion *question = [questions objectAtIndex:indexPath.row];
        answer = question.formAnswer;
    }
    
    answer.dateModified = [NSDate date];
    
    //update the question state according to the tap
    NSInteger state = [answer.answer integerValue] + 1;
    if(state > kNO)
        state = kUnanswered;
    answer.answer = [NSNumber numberWithInt:state];
    
    //?? save answer to server
    if([answer isAnswered])
    {
        [[OnlineService sharedService] postAnswer:answer];
    }
    else
        answer.submittted = @(NO);
    
    
    //show the changes
    [self.formCategoryDelegate updateProgressView];
    [self.tableView reloadData];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
