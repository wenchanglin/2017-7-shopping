//
//  ReleaseView.m
//  885logistics
//
//  Created by Blues on 17/1/5.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "ReleaseView.h"

@implementation ReleaseView

- (void)awakeFromNib {

    [super awakeFromNib];
    self.bk1.layer.masksToBounds = YES;
    self.bk1.layer.cornerRadius = 3.f;
    self.tabView.dataSource = self;
    [self.tabView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"tabCell"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.dataArr1.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tabCell" forIndexPath:indexPath];
    cell.textLabel.text = [self.dataArr1 objectAtIndex:indexPath.row];
    cell.textLabel.backgroundColor = [UIColor groupTableViewBackgroundColor];
    NSString *imgName = [self.dataArr2 objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:imgName];
    cell.contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
