
//
//  ReportViewController.m
//  885logistics
//
//  Created by Blues on 17/2/28.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "ReportViewController.h"
#import "PostModel.h"
#import "KindsModel.h"
#import "KindCCell.h"

@interface ReportViewController ()<UITextViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *nickName;
@property (weak, nonatomic) IBOutlet UICollectionView *collectView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *layout;
@property (weak, nonatomic) IBOutlet UITextField *telTf;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *msgLabel;
@property (weak, nonatomic) IBOutlet UIView *textBk;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) NSString *kindID;
@property (nonatomic, weak) UIView *perView;

@end

@implementation ReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerNotification];
}

- (void)initData {

    self.kindID = @"";
    self.dataArr = [[NSMutableArray alloc] init];
    if (NotNilAndNull(_model.userName)) {
        self.nickName.text = _model.userName;
    }
    [self queryDataFromServer];
}

- (void)createViews {
    
    self.navigationItem.title = @"举报";

    [self createRightItem];
    [self.textBk bringSubviewToFront:self.msgLabel];
    
    self.layout.itemSize = CGSizeMake((kScreenSize.width - 20.f - 15.f)/4.f, 30.f);
    self.layout.minimumLineSpacing = 8.f;
    self.layout.minimumInteritemSpacing = 5.f;
    self.layout.sectionInset = UIEdgeInsetsMake(5.f, 10.f, 0, 10.f);
    [self.collectView  registerNib:[UINib nibWithNibName:@"KindCCell" bundle:nil] forCellWithReuseIdentifier:@"KindCCell"];
}

- (void)createRightItem {

    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStyleDone target:self action:@selector(sureClicked)];
    right.tintColor = [UIColor whiteColor];
    [right setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:15.f],NSFontAttributeName, nil] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItems = @[right];
}

- (void)sureClicked {
    
    if (IsNilOrNull(_model.fkPostID)) {
        return;
    }
    if (IsNilOrNull(_model.pOre)) {
        return;
    }
    NSString *telNumber = [self.telTf.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (IsEmptyStr(telNumber)) {
        telNumber = @"";
    }
    
    NSString *reason = self.textView.text;
    if (IsEmptyStr(reason)) {
        reason = @"";
    }
    if (IsEmptyStr(_kindID)) {
        [self showMessageForUser:@"请选择举报原因"];
        return;
    }
    
    NSDictionary *param = @{@"fkRepId":_model.fkPostID,
                            @"type":_model.pOre,
                            @"fkUserId":[LYHelper getCurrentUserID],
                            @"fkForumReprea":_kindID,
                            @"reason":reason,
                            @"tel":telNumber
                            };
    [[LYAPIManager sharedInstance] POST:@"transportion/forumPostReport/addForumPostReport" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        [LYAPIManager showMessageForUser:result[@"msg"]];
        if ([result[@"errcode"] integerValue] == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}


- (void)queryDataFromServer {

    [[LYAPIManager sharedInstance] POST:@"transportion/forumRepRea/queryForumRepReaAll" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if ([result[@"errcode"] integerValue] == 0) {
            if (NotNilAndNull(result[@"data"])) {
                NSDictionary *data = result[@"data"];
                if (NotNilAndNull(data[@"iData"])) {
                    NSArray *iData = data[@"iData"];
                    
                    for (NSDictionary *dict in iData) {
                     
                        KindsModel *model = [[KindsModel alloc] init];
                        model.text = dict[@"report"];
                        model.kindID = dict[@"id"];
                        model.isNow = @"0";
                        [self.dataArr addObject:model];
                    }
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectView reloadData];
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    }];
}

#pragma mark - UICollectionViewDelegate & UICollectionDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    KindsModel *model = [self.dataArr objectAtIndex:indexPath.row];
    KindCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"KindCCell" forIndexPath:indexPath];
    [cell.bt setTitle:model.text forState:UIControlStateNormal];
    if ([model.isNow integerValue] == 1) {
        cell.bt.selected = YES;
    }else {
        cell.bt.selected = NO;
    }
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    for (NSInteger i = 0; i < self.dataArr.count; i ++) {
        KindsModel *model = [self.dataArr objectAtIndex:i];
        model.isNow = @"0";
        NSIndexPath *tmpIndex = [NSIndexPath indexPathForRow:i inSection:0];
        KindCCell *ccell = (KindCCell *)[collectionView cellForItemAtIndexPath:tmpIndex];
        ccell.bt.selected = NO;
    }
    
    KindCCell *ccell = (KindCCell *)[collectionView cellForItemAtIndexPath:indexPath];
    ccell.bt.selected = YES;
    KindsModel *model = [self.dataArr objectAtIndex:indexPath.row];
    model.isNow = @"1";
    self.kindID = model.kindID;
}

#pragma mark - UITextViewDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.perView = textField;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    self.msgLabel.text = @"";
    self.perView = textView;
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    if (textView.text.length == 0) {
        self.msgLabel.text = @"请填写您举报的原因";
    }
    return YES;
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {

    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.textView endEditing:YES];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)registerNotification {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


- (void)keyboardWillShow:(NSNotification *) notification{
    
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGRect r = [self.textView.superview convertRect:self.textView.frame toView:self.view];
    CGFloat bottom = kScreenSize.height - r.size.height - r.origin.y;
    if (bottom < keyboardRect.size.height) {

        NSString *animationDurationString = userInfo[UIKeyboardAnimationDurationUserInfoKey];
        NSTimeInterval animationDuration = [animationDurationString doubleValue];
        [UIView animateWithDuration:animationDuration animations:^{
            self.view.frame = CGRectMake(0, bottom - keyboardRect.size.height , kScreenSize.width, kScreenSize.height - 64.f);
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *) notification {
    
    NSDictionary *userInfo = notification.userInfo;
    NSValue *animatinDurationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animatinDurationValue getValue:&animationDuration];
    [UIView animateWithDuration:animationDuration animations:^{
        self.view.frame = CGRectMake(0, 64.f, kScreenSize.width, kScreenSize.height - 64.f);
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
