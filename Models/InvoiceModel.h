//
//  InvoiceModel.h
//  885logistics
//
//  Created by Blues on 17/1/19.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "BaseModel.h"

@interface InvoiceModel : BaseModel

@property (nonatomic, copy) NSString *leftStr;
@property (nonatomic, assign) NSInteger whichOne;
@property (nonatomic, copy) NSString *goRight;
@property (nonatomic, copy) NSString *placeStr;
@property (nonatomic, copy) NSString *editStr;

@end
