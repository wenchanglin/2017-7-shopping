//
//  NewsTCell2.m
//  885logistics
//
//  Created by Blues on 17/1/9.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "NewsTCell2.h"
#import "NewsModel.h"
#import "NewsViewController.h"


@implementation NewsTCell2

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)paddingMsgDetail:(NewsModel *)model {

    if (_myModel != model) {
        _myModel = model;
    }
    self.contentLb.text = _myModel.content;
    self.dateLb.text = [LYHelper justDateStringWithInterval:_myModel.createTime];
    if ([_myModel.type isEqualToString:@"申请加友"]) {
         if ([_myModel.msgOption isEqualToString:@"已通知"]) {
             self.bk2.hidden = YES;
             self.bk3.hidden = NO;
         }else {
             self.bk2.hidden = NO;
             self.bk3.hidden = YES;
         }
    }else {
        self.bk2.hidden = YES;
        self.bk3.hidden = YES;
    }
}

- (IBAction)cancelClicked:(id)sender {
    [self handleMsgWithOption:@"拒绝"];
}

- (IBAction)sureClicked:(id)sender {
    [self handleMsgWithOption:@"同意"];
}

- (void)handleMsgWithOption:(NSString *)option {
    
    NSDictionary *param = @{@"mid":_myModel.fkMsgId,
                            @"option":option
                            };
    // NSLog(@"___%@",param);
    
    [[LYAPIManager sharedInstance] POST:@"transportion/messageCenter/updateMessageSys" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"__%@",result);
        [LYAPIManager showMessageForUser:result[@"msg"]];
        
        if ([result[@"errcode"] integerValue] == 0) {
            _myModel.msgOption = @"已通知";
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.5 animations:^{
                    self.bk2.hidden = YES;
                    self.bk3.hidden = NO;
                } completion:^(BOOL finished) {
                    
                }];
            });
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        // NSLog(@"___%@",error);
    }];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
