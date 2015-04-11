//
//  CommentPhotoViewController.m
//  FuelOperator
//
//  Created by Gary Robinson on 3/29/13.
//  Copyright (c) 2013 GaryRobinson. All rights reserved.
//

#import "CommentPhotoViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface CommentPhotoViewController () <UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>

@property (nonatomic) BOOL readOnly;
@property (nonatomic, strong) FormAnswer *answer;

@property (nonatomic, strong) UIView *fakeNavBar;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *questionLabel;
@property (nonatomic, strong) UITextField *dateField;
@property (nonatomic, strong) UILabel *commentLabel;
@property (nonatomic, strong) UIImageView *commentBackgroundView;
@property (nonatomic, strong) UITextView *commentTextView;
@property (nonatomic, strong) UILabel *repairedLabel;
@property (nonatomic, strong) UISwitch *repairedSwitch;
@property (nonatomic, strong) UILabel *photosLabel;
@property (nonatomic, strong) UILabel *noPhotosLabel;
@property (nonatomic, strong) Photo *photo1;
@property (nonatomic, strong) Photo *photo2;
@property (nonatomic, strong) Photo *photo3;
@property (nonatomic, strong) UIImage *image1;
@property (nonatomic, strong) UIImage *image2;
@property (nonatomic, strong) UIImage *image3;
@property (nonatomic, strong) UIImageView *imageView1;
@property (nonatomic, strong) UIImageView *imageView2;
@property (nonatomic, strong) UIImageView *imageView3;
@property (nonatomic, strong) UIImage *removeImage;
@property (nonatomic, strong) UIButton *removeImageButton1;
@property (nonatomic, strong) UIButton *removeImageButton2;
@property (nonatomic, strong) UIButton *removeImageButton3;
@property (nonatomic, strong) UIButton *takePhotoButton;
@property (nonatomic) NSInteger removeIndex;

@property (nonatomic, strong) UIToolbar *doneKeyboardToolbar;

@property (nonatomic) CGFloat dateHeight;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UIToolbar *doneKeyboardDateToolbar;

@end

@implementation CommentPhotoViewController

- (id)initWithAnswer:(FormAnswer *)answer readOnly:(BOOL)readyOnly
{
    self = [super init];
    if(self)
    {
        self.readOnly = readyOnly;
        self.answer = answer;
        
        NSArray *photos = [self.answer.photos allObjects];
        for(Photo *p in photos)
        {
            if([p.index integerValue] == 0)
            {
                self.photo1 = p;
                self.image1 = [UIImage imageWithData:p.jpgData];
            }
            else if([p.index integerValue] == 1)
            {
                self.photo2 = p;
                self.image2 = [UIImage imageWithData:p.jpgData];
            }
            else if([p.index integerValue] == 2)
            {
                self.photo3 = p;
                self.image3 = [UIImage imageWithData:p.jpgData];
            }
        }
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    [self.view addSubview:self.fakeNavBar];
    [self.view addSubview:self.scrollView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.scrollView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)]];
    
    self.imageView1.image = self.image1;
    self.imageView2.image = self.image2;
    self.imageView3.image = self.image3;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self showPhotos];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView*)fakeNavBar
{
    if(_fakeNavBar == nil)
    {
        _fakeNavBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 65)];
        
        UIImageView *fakeStatusBar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"black-noise"]];
        fakeStatusBar.frame = CGRectMake(0, 0, self.view.bounds.size.width, 20);
        [_fakeNavBar addSubview:fakeStatusBar];
        
        UIImageView *gradient = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav-gradient"]];
        gradient.frame = CGRectMake(0, 20, self.view.bounds.size.width, 45);
        [_fakeNavBar addSubview:gradient];
        
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *cancelImage = [UIImage imageNamed:@"cancel-btn"];
        [cancelButton setImage:cancelImage forState:UIControlStateNormal];
        cancelButton.frame = CGRectMake(8, 26, cancelImage.size.width, cancelImage.size.height);
        [cancelButton addTarget:self action:@selector(cancelTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_fakeNavBar addSubview:cancelButton];
        
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(cancelButton.frame.size.width, 23, 200, 45)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont boldFontOfSize:16];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.text = @"Comment / Photo";
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [_fakeNavBar addSubview:titleLabel];
        
        if(!self.readOnly)
        {
            UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
            UIImage *saveImage = [UIImage imageNamed:@"save-btn"];
            [saveButton setImage:saveImage forState:UIControlStateNormal];
            saveButton.frame = CGRectMake(260, 26, saveImage.size.width, saveImage.size.height);
            [saveButton addTarget:self action:@selector(saveTapped:) forControlEvents:UIControlEventTouchUpInside];
            [_fakeNavBar addSubview:saveButton];
        }
    }
    return _fakeNavBar;
}

- (void)cancelTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveTapped:(id)sender
{
    [self.commentTextView resignFirstResponder];
    
    if([self.answer.formQuestion isDate] && self.answer.dateAnswer)
        self.answer.answer = @(kYES);
    
    //comments
    self.answer.comment = self.commentTextView.text;
    self.answer.repairedOnSite = [NSNumber numberWithBool:self.repairedSwitch.on];
    [self.formCategoryDelegate updateProgressView];
    
    //images
    if(self.image1)
    {
        if(!self.photo1)
            self.photo1 = [Photo MR_createEntity];
        
        self.photo1.index = [NSNumber numberWithInt:0];
        self.photo1.jpgData = UIImageJPEGRepresentation(self.image1, 1.0);
        self.photo1.uploaded = [NSNumber numberWithBool:NO];
        self.photo1.formAnswer = self.answer;
    }
    else if(self.photo1)
    {
        //image got deleted in UI, remove it from core data
        [[NSManagedObjectContext MR_defaultContext] deleteObject:self.photo1];
    }
    
    if(self.image2)
    {
        if(!self.photo2)
            self.photo2 = [Photo MR_createEntity];
        
        self.photo2.index = [NSNumber numberWithInt:1];
        self.photo2.jpgData = UIImageJPEGRepresentation(self.image2, 1.0);
        self.photo2.uploaded = [NSNumber numberWithBool:NO];
        self.photo2.formAnswer = self.answer;
    }
    else if(self.photo2)
    {
        //image got deleted in UI, remove it from core data
        [[NSManagedObjectContext MR_defaultContext] deleteObject:self.photo2];
    }
    
    if(self.image3)
    {
        if(!self.photo3)
            self.photo3 = [Photo MR_createEntity];
        
        self.photo3.index = [NSNumber numberWithInt:2];
        self.photo3.jpgData = UIImageJPEGRepresentation(self.image3, 1.0);
        self.photo3.uploaded = [NSNumber numberWithBool:NO];
        self.photo3.formAnswer = self.answer;
    }
    else if(self.photo3)
    {
        //image got deleted in UI, remove it from core data
        [[NSManagedObjectContext MR_defaultContext] deleteObject:self.photo3];
    }
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIScrollView*)scrollView
{
    if(_scrollView == nil)
    {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 65, self.view.bounds.size.width, self.view.bounds.size.height - 65)];
        _scrollView.backgroundColor = [UIColor fopOffWhiteColor];
        
        [_scrollView addSubview:self.questionLabel];
        [_scrollView addSubview:self.dateField];
        [_scrollView addSubview:self.commentLabel];
        [_scrollView addSubview:self.commentBackgroundView];
        [_scrollView addSubview:self.commentTextView];
        [_scrollView addSubview:self.repairedLabel];
        [_scrollView addSubview:self.repairedSwitch];
        [_scrollView addSubview:self.photosLabel];
        [_scrollView addSubview:self.noPhotosLabel];
        [_scrollView addSubview:self.imageView1];
        [_scrollView addSubview:self.removeImageButton1];
        [_scrollView addSubview:self.imageView2];
        [_scrollView addSubview:self.removeImageButton2];
        [_scrollView addSubview:self.imageView3];
        [_scrollView addSubview:self.removeImageButton3];
        [_scrollView addSubview:self.takePhotoButton];
        
        [self showPhotos];
    }
    return _scrollView;
}

- (UILabel*)questionLabel
{
    if(_questionLabel == nil)
    {
        _questionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 25, self.view.bounds.size.width - 20, 30)];
        _questionLabel.backgroundColor = [UIColor clearColor];
        _questionLabel.font = [UIFont boldFontOfSize:20];
        _questionLabel.textColor = [UIColor fopDarkGreyColor];
        _questionLabel.text = self.answer.formQuestion.question;
        _questionLabel.numberOfLines = 0;
        [_questionLabel sizeToFit];
    }
    return _questionLabel;
}

- (UITextField *)dateField
{
    if(_dateField == nil)
    {
        CGRect frame = CGRectZero;
        self.dateHeight = 0;
        if([self.answer.formQuestion isDate])
        {
            frame = CGRectMake(10, 35 + self.questionLabel.frame.size.height, self.view.frame.size.width-20, 30);
            self.dateHeight = 40;
        }
        _dateField = [[UITextField alloc] initWithFrame:frame];
        _dateField.delegate = self;
        _dateField.autocorrectionType = UITextAutocorrectionTypeNo;
        _dateField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _dateField.textColor = [UIColor darkTextColor];
        _dateField.backgroundColor = [UIColor whiteColor];
        
        if([self.answer.formQuestion isDate] && self.answer.dateAnswer)
        {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MM/dd/yy"];
            _dateField.text = [formatter stringFromDate:self.answer.dateAnswer];
        }
        
        _dateField.inputView = self.datePicker;
        _dateField.inputAccessoryView = self.doneKeyboardDateToolbar;
    }
    return _dateField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (UIDatePicker *)datePicker
{
    if(_datePicker == nil)
    {
        _datePicker = [[UIDatePicker alloc] init];
        _datePicker.datePickerMode = UIDatePickerModeDate;
        _datePicker.backgroundColor = [UIColor clearColor];
    }
    return _datePicker;
}

- (UIToolbar *)doneKeyboardDateToolbar
{
    if(_doneKeyboardDateToolbar == nil)
    {
        _doneKeyboardDateToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
        _doneKeyboardDateToolbar.translucent = YES;
        UIBarButtonItem* doneBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTapped:)];
        _doneKeyboardDateToolbar.tintColor = [UIColor fopDarkText];
        [_doneKeyboardDateToolbar setItems:[NSArray arrayWithObjects:doneBarButton, nil]];
    }
    return _doneKeyboardDateToolbar;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField == self.dateField)
    {
        self.answer.dateAnswer = self.datePicker.date;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM/dd/yy"];
        self.dateField.text = [formatter stringFromDate:self.answer.dateAnswer];
    }
}

- (void)doneTapped:(id)sender
{
    if([self.dateField isFirstResponder])
    {
        self.answer.dateAnswer = self.datePicker.date;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM/dd/yy"];
        self.dateField.text = [formatter stringFromDate:self.answer.dateAnswer];
        [self.dateField resignFirstResponder];
    }
}

- (UILabel*)commentLabel
{
    if(_commentLabel == nil)
    {
        _commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 35 + self.questionLabel.frame.size.height + self.dateHeight, self.view.bounds.size.width - 20, 30)];
        _commentLabel.backgroundColor = [UIColor clearColor];
        _commentLabel.font = [UIFont boldFontOfSize:20];
        _commentLabel.textColor = [UIColor fopDarkGreyColor];
        _commentLabel.text = @"Comments";
    }
    return _commentLabel;
}

- (UIImageView*)commentBackgroundView
{
    if(_commentBackgroundView == nil)
    {
        UIImage *commentBackgroundImage = [UIImage imageNamed:@"commentBackground"];
        commentBackgroundImage = [commentBackgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 12, 12)];
        
        _commentBackgroundView = [[UIImageView alloc] initWithImage:commentBackgroundImage];
        _commentBackgroundView.contentMode = UIViewContentModeScaleToFill;
        _commentBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _commentBackgroundView.frame = CGRectMake(10, 65 + self.questionLabel.frame.size.height + self.dateHeight, self.view.bounds.size.width - 20, 130);
        
        _commentBackgroundView.layer.cornerRadius = 5;//10;
        _commentBackgroundView.layer.masksToBounds = YES;
    }
    return _commentBackgroundView;
}

- (UITextView*)commentTextView
{
    if(_commentTextView == nil)
    {
        _commentTextView = [[UITextView alloc] initWithFrame:CGRectMake(15, 65 + self.questionLabel.frame.size.height + self.dateHeight, self.view.bounds.size.width - 30, 130)];
        _commentTextView.backgroundColor = [UIColor clearColor];
        _commentTextView.layer.cornerRadius = 10;
        _commentTextView.layer.masksToBounds = YES;
        _commentTextView.font = [UIFont regularFontOfSize:18];
        _commentTextView.textColor = [UIColor fopDarkGreyColor];
        _commentTextView.text = self.answer.comment;
        _commentTextView.delegate = self;
        _commentTextView.inputAccessoryView = self.doneKeyboardToolbar;
        
        if(self.readOnly)
            _commentTextView.userInteractionEnabled = NO;
    }
    return _commentTextView;
}

- (UIToolbar *)doneKeyboardToolbar
{
    if(_doneKeyboardToolbar == nil)
    {
        _doneKeyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 35)];
        _doneKeyboardToolbar.translucent = YES;
        _doneKeyboardToolbar.tintColor = [UIColor fopDarkText];
        UIBarButtonItem* doneBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissKeyboard:)];
        UIBarButtonItem* flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem* clearBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(clearComment:)];
        [_doneKeyboardToolbar setItems:[NSArray arrayWithObjects:doneBarButton, flexibleSpace, clearBarButton, nil]];
    }
    return _doneKeyboardToolbar;
}

- (void)clearComment:(id)sender
{
    self.commentTextView.text = @"";
}

- (void)dismissKeyboard:(id)sender
{
    [self.commentTextView resignFirstResponder];
}

- (UILabel *)repairedLabel
{
    if(_repairedLabel == nil)
    {
        _repairedLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 215 + self.questionLabel.frame.size.height + self.dateHeight, self.view.bounds.size.width - 20, 35)];
        _repairedLabel.font = [UIFont boldFontOfSize:20];
        _repairedLabel.textColor = [UIColor fopDarkGreyColor];
        _repairedLabel.text = @"Repaired On-Site?";
    }
    return _repairedLabel;
}

- (UISwitch *)repairedSwitch
{
    if(_repairedSwitch == nil)
    {
        _repairedSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 20 - 50, 215 + self.questionLabel.frame.size.height + self.dateHeight, 50, 35)];
        _repairedSwitch.on = [self.answer.repairedOnSite boolValue];
        if(self.readOnly)
            _repairedSwitch.userInteractionEnabled = NO;
    }
    return _repairedSwitch;
}

- (UILabel*)photosLabel
{
    if(_photosLabel == nil)
    {
        _photosLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 250 + self.questionLabel.frame.size.height + self.dateHeight, self.view.bounds.size.width - 20, 30)];
        _photosLabel.backgroundColor = [UIColor clearColor];
        _photosLabel.font = [UIFont boldFontOfSize:20];
        _photosLabel.textColor = [UIColor fopDarkGreyColor];
        _photosLabel.text = @"Photos";
    }
    return _photosLabel;
}

- (UILabel*)noPhotosLabel
{
    if(_noPhotosLabel == nil)
    {
        _noPhotosLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 280 + self.questionLabel.frame.size.height + self.dateHeight, self.view.bounds.size.width - 20, 20)];
        _noPhotosLabel.backgroundColor = [UIColor clearColor];
        _noPhotosLabel.font = [UIFont regularFontOfSize:16];
        _noPhotosLabel.textColor = [UIColor fopDarkGreyColor];
        _noPhotosLabel.text = @"There are currently no photos attached to this question.";
        _noPhotosLabel.numberOfLines = 0;
        [_noPhotosLabel sizeToFit];
    }
    return _noPhotosLabel;
}

- (UIImage*)removeImage
{
    if(_removeImage == nil)
    {
        _removeImage = [UIImage imageNamed:@"removeButtonImage"];
    }
    return _removeImage;
}

- (UIImageView*)imageView1
{
    if(_imageView1 == nil)
    {
        _imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(10, 290 + self.questionLabel.frame.size.height + self.dateHeight, 90, 70)];
        _imageView1.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _imageView1;
}

- (UIButton*)removeImageButton1
{
    if(_removeImageButton1 == nil)
    {
        _removeImageButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
        _removeImageButton1.frame = CGRectMake(10, 375 + self.questionLabel.frame.size.height + self.dateHeight, 90, 28);
        [_removeImageButton1 setImage:[UIImage imageNamed:@"removeButtonImage"] forState:UIControlStateNormal];
        [_removeImageButton1 addTarget:self action:@selector(removeImageButton1Tapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _removeImageButton1;
}

- (void)removeImageButton1Tapped:(id)sender
{
    self.removeIndex = 1;
    UIAlertView *alert = [[UIAlertView alloc] init];
	[alert setTitle:@"Delete Photo"];
	[alert setMessage:@"Are you sure?"];
	[alert setDelegate:self];
	[alert addButtonWithTitle:@"Yes"];
	[alert addButtonWithTitle:@"No"];
	[alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0)
	{
        if(self.removeIndex == 1)
        {
            if(self.image2)
            {
                self.image1 = self.image2;
                if(self.image3)
                {
                    self.image2 = self.image3;
                    self.image3 = nil;
                }
                else
                    self.image2 = nil;
            }
            else
                self.image1 = nil;
        }
        else if(self.removeIndex == 2)
        {
            if(self.image3)
            {
                self.image2 = self.image3;
                self.image3 = nil;
            }
            else
                self.image2 = nil;
        }
        else
        {
            self.image3 = nil;
        }
        
        [self showPhotos];
	}
}

- (UIImageView*)imageView2
{
    if(_imageView2 == nil)
    {
        _imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(115, 290 + self.questionLabel.frame.size.height + self.dateHeight, 90, 70)];
        _imageView2.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _imageView2;
}

- (UIButton*)removeImageButton2
{
    if(_removeImageButton2 == nil)
    {
        _removeImageButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
        _removeImageButton2.frame = CGRectMake(115, 375 + self.questionLabel.frame.size.height + self.dateHeight, 90, 28);
        [_removeImageButton2 setImage:[UIImage imageNamed:@"removeButtonImage"] forState:UIControlStateNormal];
        [_removeImageButton2 addTarget:self action:@selector(removeImageButton2Tapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _removeImageButton2;
}

- (void)removeImageButton2Tapped:(id)sender
{
    self.removeIndex = 2;
    UIAlertView *alert = [[UIAlertView alloc] init];
	[alert setTitle:@"Delete Photo"];
	[alert setMessage:@"Are you sure?"];
	[alert setDelegate:self];
	[alert addButtonWithTitle:@"Yes"];
	[alert addButtonWithTitle:@"No"];
	[alert show];
}

- (UIImageView*)imageView3
{
    if(_imageView3 == nil)
    {
        _imageView3 = [[UIImageView alloc] initWithFrame:CGRectMake(220, 290 + self.questionLabel.frame.size.height + self.dateHeight, 90, 70)];
        _imageView3.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _imageView3;
}

- (UIButton*)removeImageButton3
{
    if(_removeImageButton3 == nil)
    {
        _removeImageButton3 = [UIButton buttonWithType:UIButtonTypeCustom];
        _removeImageButton3.frame = CGRectMake(220, 375 + self.questionLabel.frame.size.height + self.dateHeight, 90, 28);
        [_removeImageButton3 setImage:[UIImage imageNamed:@"removeButtonImage"] forState:UIControlStateNormal];
        [_removeImageButton3 addTarget:self action:@selector(removeImageButton3Tapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _removeImageButton3; 
}

//
- (void)removeImageButton3Tapped:(id)sender
{
    self.removeIndex = 3;
    UIAlertView *alert = [[UIAlertView alloc] init];
	[alert setTitle:@"Delete Photo"];
	[alert setMessage:@"Are you sure?"];
	[alert setDelegate:self];
	[alert addButtonWithTitle:@"Yes"];
	[alert addButtonWithTitle:@"No"];
	[alert show];
}

- (UIButton*)takePhotoButton
{
    if(self.readOnly)
        return nil;
    
    if(_takePhotoButton == nil)
    {
        _takePhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [UIImage imageNamed:@"take-photo-btn"];
        [_takePhotoButton setImage:image forState:UIControlStateNormal];
        _takePhotoButton.frame = CGRectMake(10, 320 + self.questionLabel.frame.size.height + self.dateHeight, image.size.width, image.size.height);
        [_takePhotoButton addTarget:self action:@selector(takePhotoTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _takePhotoButton;
}

- (void)takePhotoTapped:(id)sender
{
    //prompt camera or library
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Choose Image Type"
                                          message: @"Would you like to take a new photo with the camera, or choose an existing photo from your library?"
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *existingAction = [UIAlertAction
                                   actionWithTitle:@"Photo Library"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       UIImagePickerController *libraryUI = [[UIImagePickerController alloc] init];
                                       libraryUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                       libraryUI.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
                                       libraryUI.delegate = self;
                                       libraryUI.allowsEditing = YES;
                                       [self presentViewController:libraryUI animated:YES completion:nil];
                                   }];
    
    
    UIAlertAction *newAction = [UIAlertAction
                               actionWithTitle:@"Use Camera"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                                   {
                                       UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
                                       cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
                                       cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
                                       cameraUI.delegate = self;
                                       cameraUI.allowsEditing = YES;
                                       [self presentViewController:cameraUI animated:YES completion:nil];
                                   }
                               }];
    
    
    [alertController addAction:existingAction];
    [alertController addAction:newAction];
    
    alertController.view.tintColor = [UIColor blackColor];
    [self presentViewController:alertController animated:YES completion:nil];

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    //[[picker parentViewController] dismissViewControllerAnimated:YES completion:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *imageToSave = (UIImage *)[info objectForKey:UIImagePickerControllerEditedImage];
    if(!imageToSave)
        imageToSave = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];;
    
    
    if(!self.image1)
        self.image1 = imageToSave;
    else if(!self.image2)
        self.image2 = imageToSave;
    else
        self.image3 = imageToSave;
    
    [self showPhotos];

    //[[picker parentViewController] dismissViewControllerAnimated:YES completion:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showPhotos
{
    self.takePhotoButton.enabled = YES;
    
    if(!self.image1)
    {
        self.noPhotosLabel.hidden = NO;
        self.imageView1.hidden = YES;
        self.removeImageButton1.hidden = YES;
        self.imageView2.hidden = YES;
        self.removeImageButton2.hidden = YES;
        self.imageView3.hidden = YES;
        self.removeImageButton3.hidden = YES;
        
        CGRect rect = self.takePhotoButton.frame;
        rect.origin.y = 320 + self.questionLabel.frame.size.height + self.dateHeight;
        self.takePhotoButton.frame = rect;
    }
    else
    {
        self.noPhotosLabel.hidden = YES;
        self.imageView1.hidden = NO;
        self.removeImageButton1.hidden = NO;
        
        if(self.image2)
        {
            self.imageView2.hidden = NO;
            self.removeImageButton2.hidden = NO;
        }
        else
        {
            self.imageView2.hidden = YES;
            self.removeImageButton2.hidden = YES;
        }
        
        if(self.image3)
        {
            self.imageView3.hidden = NO;
            self.removeImageButton3.hidden = NO;
        }
        else
        {
            self.imageView3.hidden = YES;
            self.removeImageButton3.hidden = YES;
        }
        
        CGRect rect = self.takePhotoButton.frame;
        rect.origin.y = 415 + self.questionLabel.frame.size.height + self.dateHeight;
        self.takePhotoButton.frame = rect;
    }
    
    self.imageView1.image = self.image1;
    self.imageView2.image = self.image2;
    self.imageView3.image = self.image3;
    
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.takePhotoButton.frame.origin.y + self.takePhotoButton.frame.size.height + 10);
}

@end
