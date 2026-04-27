//
//  Test.h
//  Objective-C高级编程 iOS与OS X多线程和内存管理
//
//  Created by 小涂和小周的mac on 2026/4/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Test : NSObject
{
    id __strong _obj;
}

- (void)setObjetc:(id __strong)obj;
@end

NS_ASSUME_NONNULL_END
