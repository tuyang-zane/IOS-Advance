//
//  main.m
//  Objective-C高级编程 iOS与OS X多线程和内存管理
//
//  Created by tuyang on 2026/4/9.
//

#import <Foundation/Foundation.h>
#import "Chapter1.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        Chapter1 * c = [[Chapter1 alloc]init];
        [c retainCount];
        
        [Chapter1 unsafeunretained];
        NSLog(@"Hello, World!");
    }
    return EXIT_SUCCESS;
}
