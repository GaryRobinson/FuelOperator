//
//  LoginViewController.m
//  FuelOperator
//
//  Created by Gary Robinson on 3/13/13.
//  Copyright (c) 2013 GaryRobinson. All rights reserved.
//

#import "LoginViewController.h"
#import "InnerShadowView.h"
#import "AppDelegate.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface LoginViewController ()  <UITextFieldDelegate>

@property (nonatomic, strong) UILabel *appTitle;
@property (nonatomic, strong) InnerShadowView *loginFormView;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UIActivityIndicatorView *loginActivityView;

@property (nonatomic, strong) UIToolbar *doneKeyboardToolbar;

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"black-noise"]];
    
    [self.view addSubview:self.appTitle];
    [self.view addSubview:self.loginFormView];
    [self.view addSubview:self.usernameTextField];
    [self.view addSubview:self.passwordTextField];
    [self.view addSubview:self.loginButton];
    [self.view addSubview:self.loginActivityView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UILabel*)appTitle
{
    if(_appTitle == nil)
    {
        _appTitle = [[UILabel alloc] initWithFrame:CGRectZero];
        _appTitle.backgroundColor = [UIColor clearColor];
        _appTitle.text = @"FUEL OPERATOR";
        _appTitle.font = [UIFont lightFontOfSize:36];
        _appTitle.textColor = [UIColor fopLightGreyColor];
        _appTitle.numberOfLines = 1;
        [_appTitle sizeToFit];
        _appTitle.center = CGPointMake(self.view.frame.size.width/2., 80);
    }
    return _appTitle;
}

- (InnerShadowView*)loginFormView
{
    if(_loginFormView == nil)
    {
        _loginFormView = [[InnerShadowView alloc] initWithFrame:CGRectMake(39, 120, 242, 108)];
        _loginFormView.backgroundColor = [UIColor whiteColor];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, _loginFormView.frame.size.height/2., _loginFormView.frame.size.width, 1)];
        lineView.backgroundColor = [UIColor fopDarkText];
        [_loginFormView addSubview:lineView];
    }
    return _loginFormView;
}

- (UITextField*)usernameTextField
{
    if(_usernameTextField == nil)
    {
        _usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(50, 132, 220, 40)];
        _usernameTextField.delegate = self;
        _usernameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        _usernameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _usernameTextField.placeholder = @"User Name";
        _usernameTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"previousUserName"];
        _usernameTextField.font = [UIFont regularFontOfSize:24];
        _usernameTextField.textColor = [UIColor darkTextColor];
        
        _usernameTextField.inputAccessoryView = self.doneKeyboardToolbar;
    }
    return _usernameTextField;
}

- (UITextField*)passwordTextField
{
    if(_passwordTextField == nil)
    {
        _passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(50, 185, 220, 40)];
        _passwordTextField.delegate = self;
        _passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        _passwordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _passwordTextField.placeholder = @"Password";
        _passwordTextField.secureTextEntry = YES;
        _passwordTextField.font = [UIFont regularFontOfSize:24];
        _passwordTextField.textColor = [UIColor darkTextColor];
        
        _passwordTextField.inputAccessoryView = self.doneKeyboardToolbar;
    }
    return _passwordTextField;
}

- (UIToolbar *)doneKeyboardToolbar
{
    if(_doneKeyboardToolbar == nil)
    {
        _doneKeyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 35)];
        _doneKeyboardToolbar.translucent = YES;
        UIBarButtonItem* doneBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissKeyboard:)];
        _doneKeyboardToolbar.tintColor = [UIColor fopDarkText];
        [_doneKeyboardToolbar setItems:[NSArray arrayWithObjects:doneBarButton, nil]];
    }
    return _doneKeyboardToolbar;
}

- (void)dismissKeyboard:(id)sender
{
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (UIButton*)loginButton
{
    if(_loginButton == nil)
    {
        _loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *loginImage = [UIImage imageNamed:@"btn-login"];
        [_loginButton setImage:loginImage forState:UIControlStateNormal];
        _loginButton.frame = CGRectMake(0, 0, loginImage.size.width, loginImage.size.height);
        _loginButton.center = CGPointMake(self.view.bounds.size.width/2., 284/*self.view.bounds.size.height/2.*/);
        [_loginButton addTarget:self action:@selector(loginTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loginButton;
}

- (UIActivityIndicatorView *)loginActivityView
{
    if(_loginActivityView == nil)
    {
        _loginActivityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _loginActivityView.center = CGPointMake(self.loginButton.center.x, self.loginButton.center.y + 60);
        _loginActivityView.hidesWhenStopped = YES;
        [_loginActivityView stopAnimating];
    }
    return _loginActivityView;
}

-(void)loginTapped:(id)sender
{
    [self dismissKeyboard:self];
    
    self.view.userInteractionEnabled = NO;
    [self.loginActivityView startAnimating];
    
    BOOL network = YES;
//    BOOL network = NO;
    if(network)
    {
        //parse out base url from userName, if its there
        NSString *baseURL = nil;
        NSString *userName = self.usernameTextField.text;
        NSUInteger atIndex = [userName rangeOfString:@"@"].location;
        if(atIndex != NSNotFound)
        {
            baseURL = [[userName substringFromIndex:atIndex+1] stringByAppendingString:@"/"];
            if([baseURL rangeOfString:@"://"].location == NSNotFound)
            {
                NSString *httpPrefix = @"http://";
                baseURL = [httpPrefix stringByAppendingString:baseURL];
            }
            userName = [userName substringToIndex:atIndex];
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginDone:) name:@"loginDone" object:nil];
        [[OnlineService sharedService] attemptLogin:userName password:self.passwordTextField.text baseURL:baseURL];
    }
    else
        [self attemptLoginOffline];
}

- (void)loginDone:(NSNotification *)notification
{
    self.view.userInteractionEnabled = YES;
    [self.loginActivityView stopAnimating];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"loginDone" object:nil];
    
    NSNumber *sucess = notification.userInfo[@"Success"];
    NSNumber *tryOffline = notification.userInfo[@"TryOffline"];
    if([sucess boolValue] == YES)
    {
        [[NSUserDefaults standardUserDefaults] setObject:self.usernameTextField.text forKey:@"previousUserName"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self loginSucceeded];
    }
    else if([tryOffline boolValue] == YES)
    {
        [self attemptLoginOffline];
    }
    else
        [self loginFailed];
    
}

- (void)attemptLoginOffline
{
    BOOL loggedIn = NO;
    User *offlineUser = [User MR_findFirstByAttribute:@"login" withValue:self.usernameTextField.text];
    if(offlineUser)
    {
        //?? prompt if user wants to login offline
        
        NSString *decryptedPassword = [NSString decrypt:offlineUser.password];
        if([decryptedPassword isEqualToString:self.passwordTextField.text])
        {
            [User login:offlineUser];
            loggedIn = YES;
        }
    }
    
    if(loggedIn)
        [self loginSucceeded];
    else
        [self loginFailed];
}

- (void)loginSucceeded
{
    AppDelegate *appD = [[UIApplication sharedApplication] delegate];
    [appD loginCompleted:self];
}

- (void)loginFailed
{
    [SVProgressHUD showImage:nil status:@"Login failed"];
}

@end
