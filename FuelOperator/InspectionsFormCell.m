//
//  InspectionsFormCell.m
//  FuelOperator
//
//  Created by Gary Robinson on 4/19/13.
//  Copyright (c) 2013 GaryRobinson. All rights reserved.
//

#import "InspectionsFormCell.h"

#define ANSWER_WIDTH 46
#define QUESTION_FONT_SIZE 18

@interface InspectionsFormCell ()

@property (nonatomic, strong) UIView *highlightView;
@property (nonatomic, strong) UILabel *questionLabel;
@property (nonatomic, strong) UIImageView *commentNeededImageView;
@property (nonatomic, strong) UIImageView *warningImageView;
@property (nonatomic, strong) UILabel *warningLabel;
@property (nonatomic, strong) UIImageView *commentImageView;
@property (nonatomic, strong) UIButton *answerButton;
@property (nonatomic, strong) UIView *answerSeparator;
@property (nonatomic, strong) UIView *cellSeparator;
@property (nonatomic, weak) id accessoryTarget;

@end

@implementation InspectionsFormCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withTarget:(id)target
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.accessoryTarget = target;
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.contentView.backgroundColor = [UIColor fopOffWhiteColor];
        [self.contentView addSubview:self.questionLabel];
        [self.contentView addSubview:self.commentNeededImageView];
        [self.contentView addSubview:self.warningImageView];
        [self.contentView addSubview:self.warningLabel];
        [self.contentView addSubview:self.commentImageView];
        [self.contentView addSubview:self.answerButton];
        [self.contentView addSubview:self.answerSeparator];
        [self.contentView addSubview:self.cellSeparator];
        [self.contentView addSubview:self.highlightView];
        
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (UIView*)highlightView
{
    if(_highlightView == nil)
    {
        _highlightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 1)];
        _highlightView.backgroundColor = [UIColor whiteColor];
    }
    return _highlightView;
}

- (UILabel*)questionLabel
{
    if(_questionLabel == nil)
    {
        _questionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 230, 30)];
        _questionLabel.backgroundColor = [UIColor clearColor];
        _questionLabel.font = [UIFont regularFontOfSize:QUESTION_FONT_SIZE];
        _questionLabel.textColor = [UIColor fopDarkText];
        _questionLabel.numberOfLines = 0;
    }
    return _questionLabel;
}

- (UIImageView*)commentNeededImageView
{
    if(_commentNeededImageView == nil)
    {
        _commentNeededImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"form-accessory"]];
        _commentNeededImageView.center = CGPointMake(260, INSPECTION_FORM_CELL_HEIGHT/2);
        _commentNeededImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    }
    return _commentNeededImageView;
}

- (UIImageView*)warningImageView
{
    if(_warningImageView == nil)
    {
        _warningImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning"]];
        _warningImageView.center = CGPointMake(15, 31);
        _warningImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    }
    return _warningImageView;
}

- (UILabel*)warningLabel
{
    if(_warningLabel == nil)
    {
        _warningLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 25, 230, 15)];
        _warningLabel.backgroundColor = [UIColor clearColor];
        _warningLabel.font = [UIFont regularFontOfSize:14];
        _warningLabel.textColor = [UIColor redColor];
        _warningLabel.text = @"Add photo documentation";
        _warningLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    }
    return _warningLabel;
}

- (UIImageView*)commentImageView
{
    if(_commentImageView == nil)
    {
        _commentImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"comment"]];
        _commentImageView.center = CGPointMake(15, 34);
        _commentImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    }
    return _commentImageView;
}

- (UIButton*)answerButton
{
    if(_answerButton == nil)
    {
        UIImage *image = [UIImage imageNamed:@"noanswer"];
        _answerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _answerButton.backgroundColor = [UIColor fopOffWhiteColor];
        [_answerButton setImage:image forState:UIControlStateNormal];;
        _answerButton.frame = CGRectMake(self.contentView.bounds.size.width - ANSWER_WIDTH, 0, ANSWER_WIDTH, self.contentView.frame.size.height);
        [_answerButton addTarget:self.accessoryTarget action:@selector(didSelectAccessory:event:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _answerButton;
}

- (UIView*)answerSeparator
{
    if(_answerSeparator == nil)
    {
        _answerSeparator = [[UIView alloc] initWithFrame:CGRectMake(self.contentView.bounds.size.width - ANSWER_WIDTH - 1, 0, 1, INSPECTION_FORM_CELL_HEIGHT)];
        _answerSeparator.backgroundColor = [UIColor fopLightGreyColor];
        _answerSeparator.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    }
    return _answerSeparator;
}

- (UIView*)cellSeparator
{
    if(_cellSeparator == nil)
    {
        _cellSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, self.contentView.frame.size.height - 1, self.contentView.bounds.size.width, 1)];
        _cellSeparator.backgroundColor = [UIColor fopLightGreyColor];
        _cellSeparator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    }
    return _cellSeparator;
}

- (void)setFormAnswer:(FormAnswer *)formAnswer
{
    _formAnswer = formAnswer;
    
    self.questionLabel.text = _formAnswer.formQuestion.question;
    [self.questionLabel sizeToFit];
    CGRect rect = self.questionLabel.frame;
    rect.size.width = 230;
    self.questionLabel.frame = rect;
    
    
    if([_formAnswer.answer integerValue] == kUnanswered)
    {
        [self.answerButton setImage:[UIImage imageNamed:@"noanswer"] forState:UIControlStateNormal];
        self.answerButton.backgroundColor = [UIColor fopOffWhiteColor];
        self.commentNeededImageView.hidden = YES;
        self.warningImageView.hidden = YES;
        self.warningLabel.hidden = YES;
    }
    else if([_formAnswer.answer integerValue] == kYES)
    {
        [self.answerButton setImage:[UIImage imageNamed:@"thumbsup"] forState:UIControlStateNormal];
        self.answerButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"black-noise"]];
        self.commentNeededImageView.hidden = YES;
        self.warningImageView.hidden = YES;
        self.warningLabel.hidden = YES;
    }
    else
    {
        [self.answerButton setImage:[UIImage imageNamed:@"thumbsdown"] forState:UIControlStateNormal];
        self.answerButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"black-noise"]];
        
    }
    
    if([self.formAnswer needsComment] || [self.formAnswer needsPhoto])
    {
        self.commentNeededImageView.hidden = NO;
        self.warningImageView.hidden = NO;
        self.warningLabel.hidden = NO;
    }
    
    if(_formAnswer.photos.count > 0)
    {
        self.commentImageView.hidden = NO;
        self.warningImageView.hidden = YES;
        self.warningLabel.hidden = YES;
    }
    else
        self.commentImageView.hidden = YES;
    
    
    [self setCellHeight];
}


-(void)setCellHeight
{
    CGRect rect = self.contentView.frame;
    CGFloat height = self.questionLabel.frame.origin.y + self.questionLabel.frame.size.height + 10;
    if(height < 40)
        height = 40;
    if([self.formAnswer needsComment] || [self.formAnswer needsPhoto] || self.formAnswer.photos.count > 0)
        height += 20;
    if(height < INSPECTION_FORM_CELL_HEIGHT)
        height = INSPECTION_FORM_CELL_HEIGHT;
    rect.size.height = height;
    self.contentView.frame = rect;
    
    rect = self.answerButton.frame;
    rect.size.height = height;
    self.answerButton.frame = rect;
}

+ (CGFloat)getCellHeightForQuestion:(FormQuestion*)question withAnswer:(FormAnswer*)answer
{
    CGSize labelSize = [question.question sizeWithFont:[UIFont regularFontOfSize:QUESTION_FONT_SIZE] constrainedToSize:CGSizeMake(230.0f, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
	CGFloat height = 10 + labelSize.height + 10;
    if(height < 40)
        height = 40;
    if([answer needsComment] || [answer needsPhoto] || answer.photos.count > 0)
        height += 20;
    if(height < INSPECTION_FORM_CELL_HEIGHT)
        height = INSPECTION_FORM_CELL_HEIGHT;
    return height;
}


@end
