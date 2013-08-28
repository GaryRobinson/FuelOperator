//
//  FormCategoryView.h
//  FuelOperator
//
//  Created by Gary Robinson on 8/27/13.
//  Copyright (c) 2013 GaryRobinson. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FormCategoryDelegate <NSObject>

- (void)updateProgressView;
- (void)editCommentPhotosForAnswer:(FormAnswer *)formAnswer;

@end

@interface FormCategoryView : UIView

@property (nonatomic, weak) id <FormCategoryDelegate> formCategoryDelegate;

@property (nonatomic, strong) Inspection *inspection;
@property (nonatomic, strong) NSArray *formQuestions;

@end
