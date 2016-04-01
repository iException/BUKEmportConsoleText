//
//  ImportOutput.m
//  ImportOutput
//
//  Created by lifubo on 16/3/31.
//  Copyright © 2016年 baixing. All rights reserved.
//



#import "NSObject_Extension.h"
#import "ExportConsoleText.h"

@implementation NSObject (Xcode_Plugin_Template_Extension)

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[ExportConsoleText alloc] initWithBundle:plugin];
        });
    }
}
@end
