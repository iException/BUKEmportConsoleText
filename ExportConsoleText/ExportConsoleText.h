//
//  ImportOutput.m
//  ImportOutput
//
//  Created by lifubo on 16/3/31.
//  Copyright © 2016年 baixing. All rights reserved.
//


#import <AppKit/AppKit.h>

@class ExportConsoleText;

static ExportConsoleText *sharedPlugin;

@interface ExportConsoleText : NSObject

+ (instancetype)sharedPlugin;
- (id)initWithBundle:(NSBundle *)plugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end