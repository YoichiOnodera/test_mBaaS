//
//  ViewController.m
//  test_mBaaS
//
//  Created by onodera on 2015/02/13.
//  Copyright (c) 2015年 onodera. All rights reserved.
//

#import "ViewController.h"
#import <NCMB/NCMB.h>


@interface ViewController ()
@property (nonatomic) IBOutlet UILabel      *loginStatusLabel;

@property (nonatomic) IBOutlet UITextField  *registerMailAddress1TextField;
@property (nonatomic) IBOutlet UITextField  *registerMailAddress2TextField;
@property (nonatomic) IBOutlet UIButton     *sendButton;

@property (nonatomic) IBOutlet UITextField  *loginMailAddressTextField;
@property (nonatomic) IBOutlet UITextField  *loginPasswordTextField;
@property (nonatomic) IBOutlet UIButton     *loginButton;

@property (nonatomic) IBOutlet UITextField  *updateTextField;
@property (nonatomic) IBOutlet UIButton     *updateButton;

@property (nonatomic) IBOutlet UIScrollView *scrollView;
@end


@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

//    [NCMB setApplicationKey:@"YOUR_APPLICATION_KEY" clientKey:@"YOUR_CLIENT_KEY"];
    [NCMB setApplicationKey:@"0e34ce8f0511d4223784a3dc2e29a016fc0f006f1aaff92e4075966619210aa1" clientKey:@"cc49c24747f43e0fc72da3341dc131e61b46344030f35fcb7dac7ec14d1226c8"];

    [self loginStatusDisplay];

    NSLog(@"x:%.2f, y:%.2f, x:%.2f, y:%.2f", _scrollView.frame.origin.x, _scrollView.frame.origin.y, _scrollView.frame.size.width, _scrollView.frame.size.height);
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, _scrollView.frame.size.height * 2);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/**
 *  メールアドレスで登録するためのメールアドレスを送信します
 *
 *  @param sender
 */
- (IBAction)tapSendButton:(UIButton *)sender
{
    // メールアドレスの厳密チェックはしていません
    if ([_registerMailAddress1TextField.text isEqualToString:_registerMailAddress2TextField.text]) {
        [NCMBUser requestAuthenticationMailInBackground:_registerMailAddress1TextField.text block:^(NSError *error) {
            if (error) {
                NSLog(@"[ERROR]:%@", error);
            }
            else {
                NSLog(@"[SUCCESS]");
            }
        }];
    }
}


/**
 *  登録したメールアドレスとパスワードでログインします
 *
 *  @param sender
 */
- (IBAction)tapLoginButton:(UIButton *)sender
{
    // 現在のユーザー情報を取得
    NCMBUser *user = [NCMBUser currentUser];
    
    if (user) {
        [NCMBUser logOut];
        [self loginStatusDisplay];
    }
    else {
        if ([_loginMailAddressTextField.text length] > 0 && [_loginPasswordTextField.text length] > 0) {
            [NCMBUser logInWithMailAddressInBackground:_loginMailAddressTextField.text password:_loginPasswordTextField.text block:^(NCMBUser *user, NSError *error) {
                if (error) {
                    NSLog(@"[ERROR]:%@", error);
                }
                else {
                    NSLog(@"[SUCCESS]");
                    [self loginStatusDisplay];

                    // ACLを設定
                    NCMBUser *user = [NCMBUser currentUser];
                    NCMBACL  *acl  = [NCMBACL ACLWithUser:[NCMBUser currentUser]];
                    [acl setPublicReadAccess:YES];
                    [acl setPublicWriteAccess:NO];
                    [user setACL:acl];
                    [user save:nil];
                }
            }];
        }
    }
}


/**
 *  会員管理の追加フィールドを更新します
 */
- (IBAction)tapUpdateButton:(UIButton *)sender
{
    // 現在のユーザー情報を取得
    NCMBUser *user = [NCMBUser currentUser];

    NCMBObject *query = [NCMBObject objectWithClassName:@"user"];
    [query setObjectId:user.objectId];
    [query setObject:user.userName forKey:@"userName"];
    [query setObject:_updateTextField.text forKey:@"example"];

    [query saveInBackgroundWithBlock:^(NSError *error) {
        if (error) {
            NSLog(@"[ERROR]:%@", error);
        }
        else {
            NSLog(@"[SUCCESS]");
        }
    }];
}


/**
 *  ログイン状態を表示します
 */
- (void)loginStatusDisplay
{
    // 現在のユーザー情報を取得
    NCMBUser *user = [NCMBUser currentUser];
    
    if (user) {
        _loginStatusLabel.text = [NSString stringWithFormat:@"ログイン:%@/%@", user.sessionToken, [user objectForKey:@"sessionToken"]];
    }
    else {
        _loginStatusLabel.text = @"ログアウト";
    }
}

@end
