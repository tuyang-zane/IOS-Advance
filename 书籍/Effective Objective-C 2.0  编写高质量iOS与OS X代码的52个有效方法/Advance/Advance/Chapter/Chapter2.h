//
//  Chapter2.h
//  Advance
//
//  Created by tuyang on 2026/4/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 1. 枚举写在最最上面
/*
 这是 iOS 专用的定义枚举的标准写法
 if (type == 0) {
 } else if (type == 1) {
 } else if (type == 2) {
 }

 if (type == EOCEmployeeTypeDeveloper) {
     // 做开发的事
 }
 */
NS_ENUM(NSUInteger, EOCEmployeeType) {
    EOCEmployeeTypeDeveloper,
    EOCEmployeeTypeDesigner,
    EOCEmployeeTypeFinance,
};


@interface Chapter2 : NSObject
{// 成员变量
    @public
    NSString * _firstname;
    NSString * _twoname;
    
    @private
    NSString * _date;
}
@property NSString * firstname;
@property NSString * lastname;
@property (nonatomic, getter=isOn) BOOL on;

@end

NS_ASSUME_NONNULL_END
