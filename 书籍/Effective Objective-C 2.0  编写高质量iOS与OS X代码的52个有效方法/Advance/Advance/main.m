//
//  main.m
//  Advance
//
//  Created by 小涂和小周的mac on 2026/4/9.
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        
        // 因为 b 是运行时创建的字符串，不在常量区，地址不同！
        NSString *a = @"123";
        NSString *b = [NSString stringWithFormat:@"12%d",3];

        if (a == b) {
            NSLog(@"Hello, World!");
        }
    }
    return EXIT_SUCCESS;
}
