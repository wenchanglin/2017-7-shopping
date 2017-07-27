//
//  PickPDTController.m
//  CustomFurniture
//
//  Created by Blues on 16/11/3.
//  Copyright © 2016年 LTD.wenchanglin. All rights reserved.
//

#import "PickPDTController.h"


@interface PickPDTController () <UIPickerViewDelegate,UIPickerViewDataSource> {

}

@property (weak, nonatomic) IBOutlet UIPickerView *pickView;
@property (weak, nonatomic) IBOutlet UIButton *sureBt;
@property (weak, nonatomic) IBOutlet UIButton *cancelBt;

@property (nonatomic, strong) NSMutableArray *provinces;
@property (nonatomic, strong) NSMutableArray *cityArray;    // 城市数据
@property (nonatomic, strong) NSMutableArray *areaArray;    // 区信息
@property (nonatomic, strong) NSMutableArray *selectedArray;

@property (nonatomic, strong) NSArray *fileArray;


@end

@implementation PickPDTController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareData];
}

- (void)cameSetHideBlock:(HideBlock)block {
    self.hideBlock = block;
}

- (void)cameSetMy:(PDTBlock)block {
    self.pdtBlock = block;
}

- (void)cameSetserBlock:(SerPDTBlock)sBlock {
    self.serBlock = sBlock;
}


- (IBAction)disClicked:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:^{ }];
}

- (IBAction)sureClicked:(UIButton *)sender {
    
    NSString *province = @"";
    NSString *city = @"";
    NSString *area = @"";
    
    NSInteger index = [self.pickView selectedRowInComponent:0];
    NSInteger index1 = [self.pickView selectedRowInComponent:1];
    NSInteger index2 = [self.pickView selectedRowInComponent:2];
    province = self.provinces[index];
    city = self.cityArray[index1];
    
    if (self.areaArray.count) {
        area = self.areaArray[index2];
    }
    
    NSString *pdtStr = [NSString stringWithFormat:@"%@%@%@",province,city,area];
    
    if (pdtStr.length) {
        
        NSDictionary *pdt = @{@"pdt":pdtStr};
        
         [self dismissViewControllerAnimated:YES completion:^{
         
             if (self.pdtBlock) {
                 self.pdtBlock(pdt);
             }
         }];
    }
    
    
    
}

- (IBAction)cancelClicked:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{ }];
}


- (void)prepareData {
    
    self.provinces = [NSMutableArray new];
    self.cityArray = [NSMutableArray new];
    self.areaArray = [NSMutableArray new];

    self.selectedArray = [NSMutableArray new];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"area" ofType:@"plist"];
    self.fileArray = [[NSArray alloc] initWithContentsOfFile:path];
    
    [self.fileArray enumerateObjectsUsingBlock:^(NSDictionary  *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.provinces addObject:obj[@"state"]];
    }];
    NSMutableArray *citys = [NSMutableArray arrayWithArray:[self.fileArray firstObject][@"cities"]];
    [citys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.cityArray addObject:obj[@"city"]];
    }];
    self.areaArray = [NSMutableArray arrayWithArray:[citys firstObject][@"areas"]];
}


#pragma mark - UIPicker Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (component == 0) {
        return self.provinces.count;
    }else if (component == 1) {
        return self.cityArray.count;
    }else{
        return self.areaArray.count;
    }
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{

    if (component == 0) {
        
        self.selectedArray = self.fileArray[row][@"cities"];
        [self.cityArray removeAllObjects];
        
        [self.selectedArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.cityArray addObject:obj[@"city"]];
        }];
        self.areaArray = [NSMutableArray arrayWithArray:[self.selectedArray firstObject][@"areas"]];
        [pickerView reloadComponent:1];
        [pickerView reloadComponent:2];
        [pickerView selectRow:0 inComponent:1 animated:YES];
        [pickerView selectRow:0 inComponent:2 animated:YES];
        
    }else if (component == 1) {
        
        if (self.selectedArray.count == 0) {
            self.selectedArray = [self.fileArray firstObject][@"cities"];
        }
        self.areaArray = [NSMutableArray arrayWithArray:[self.selectedArray objectAtIndex:row][@"areas"]];
        [pickerView reloadComponent:2];
        [pickerView selectRow:0 inComponent:2 animated:YES];
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    
    UILabel *lable = [[UILabel alloc]init];
    lable.textAlignment = NSTextAlignmentCenter;
    lable.font = [UIFont systemFontOfSize:15.f];
    
    if (component == 0) {

        lable.text = self.provinces[row];
    }else if (component == 1) {
        lable.text = self.cityArray[row];
    }else {
        if (self.areaArray.count) {
            lable.text = self.areaArray[row];
        }else {
            lable.text = @"";
        }
    }
    return lable;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
