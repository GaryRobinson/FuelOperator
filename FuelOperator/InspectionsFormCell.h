//
//  InspectionsFormCell.h
//  FuelOperator
//
//  Created by Gary Robinson on 4/19/13.
//  Copyright (c) 2013 GaryRobinson. All rights reserved.
//

#import <UIKit/UIKit.h>

#define INSPECTION_FORM_CELL_HEIGHT 50


@interface InspectionsFormCell : UITableViewCell

@property (nonatomic, strong) FormAnswer *formAnswer;

//@property (nonatomic) int state;
//@property (nonatomic, strong) NSString *question;
//@property (nonatomic) int commentState;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withTarget:(id)target;

//+ (CGFloat)getCellHeightForQuestion:(NSString*)question withState:(NSInteger)state withComment:(BOOL)hasComment;
+ (CGFloat)getCellHeightForQuestion:(FormQuestion*)question withAnswer:(FormAnswer*)answer;

@end
