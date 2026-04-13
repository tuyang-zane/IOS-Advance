//
//  Chapter2.h
//  Advance
//
//  Created by tuyang on 2026/4/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

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
