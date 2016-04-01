//
//  ImportOutput.m
//  ImportOutput
//
//  Created by lifubo on 16/3/31.
//  Copyright © 2016年 baixing. All rights reserved.
//

#import "ExportConsoleText.h"
#import "IDEConsoleTextView.h"
#import "BRButton.h"

@interface ExportConsoleText()

@property (nonatomic, strong, readwrite) NSBundle *bundle;//模版自带不知道是干什么的
@property (nonatomic, strong) IDEConsoleTextView *consoleTextView;//显示输出的view

@end

@implementation ExportConsoleText

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if ((self = [super init])) {
        // reference to plugin's bundle, for resource access
        self.bundle = plugin;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didViewFrameDidChangeNotification:)
                                                     name:NSViewFrameDidChangeNotification
                                                   object:nil];
    }
    return self;
}

#pragma mark - lifecycle -

- (void)didViewFrameDidChangeNotification:(NSNotification*)noti
{
    if([noti.object isKindOfClass:NSClassFromString(@"IDEConsoleTextView")] && self.consoleTextView == nil) {
        //找到consoleTextView 并保存，然后要把一个按钮添加到consoleTextView下面的菜单中,并添加事件
        self.consoleTextView = (IDEConsoleTextView *)noti.object;
        NSView *barView = self.consoleTextView.superview.superview.superview.subviews[0];
        BRButton *outputBtn = [[BRButton alloc] initWithFrame:CGRectMake(80, 0, 80, barView.frame.size.height)];
        outputBtn.textString = @"Export";
        outputBtn.textColor = [NSColor blackColor];
        outputBtn.backgroundColor = [NSColor clearColor];
        [outputBtn addGestureRecognizer:[[NSClickGestureRecognizer alloc] initWithTarget:self action:@selector(exportConsoleText)]];
        [self.consoleTextView.superview.superview.superview addSubview:outputBtn];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - event handler -
//导出数据
- (void)exportConsoleText
{
    NSAlert *alertView = [[NSAlert alloc] init];
    [alertView addButtonWithTitle:@"保存本地"];
    [alertView addButtonWithTitle:@"直接打开"];
    [alertView addButtonWithTitle:@"取消"];
    [alertView setMessageText:@"请选择打开方式"];
    [alertView beginSheetModalForWindow:[self.consoleTextView window] completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == 1002) {//点击取消按钮
            return;
        }
        NSMutableAttributedString *consoleText = [self.consoleTextView.textStorage valueForKey:@"contents"];
        
        if (returnCode == 1000) {//点击保存本地
            //保存文件的面板
            [self saveFile:consoleText.mutableString];
        } else if (returnCode == 1001) {//点击直接打开
            NSString *tempPath = NSTemporaryDirectory();
            NSString *filePath = [tempPath stringByAppendingPathComponent:@"output.html"];
            [consoleText.mutableString writeToURL:[NSURL fileURLWithPath:filePath] atomically:YES encoding:NSUTF8StringEncoding error:nil];
            [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
            [[NSWorkspace sharedWorkspace] openFile:filePath withApplication:@"Safari"];
        }
    }];
}

#pragma mark - private -
//把文件保存到本地
- (void)saveFile:(NSString *)consoleTextString
{
    NSSavePanel* saveDlg = [NSSavePanel savePanel];
    saveDlg.nameFieldStringValue = @"output";
    [saveDlg beginSheetModalForWindow:[self.consoleTextView window]completionHandler:^(NSInteger result) {
        if (result == 1) {//点击确定
            NSURL *filePath = [saveDlg URL];
            if(![filePath.pathExtension isEqualToString:@"html"])
            {
                filePath = [filePath URLByAppendingPathExtension:@"html"];
            }
            NSInteger i = 1;
            //判断文件是否存在
            NSFileManager *fileManage = [NSFileManager defaultManager];
            NSString *filePathString = [filePath.absoluteString substringFromIndex:7];
            NSString *subString = [filePathString stringByDeletingPathExtension];
            while ([fileManage fileExistsAtPath:filePathString]) {
                filePathString = [filePathString stringByDeletingPathExtension];
                filePath = [[NSURL alloc] initFileURLWithPath:[subString stringByAppendingString:[NSString stringWithFormat:@"(%@).html",@(i)]]];
                
                filePathString = [subString stringByAppendingString:[NSString stringWithFormat:@"(%@).html",@(i++)]];
            }
            [consoleTextString writeToURL:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
        
    }];
}

@end
