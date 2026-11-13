// Keep the Runner's cached game directory consistent with NSString's path
// normalization, including Gatekeeper's /private/var App Translocation path.
#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#include <errno.h>
#include <mach-o/dyld.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static int fail(BOOL validateOnly, NSString *message, int code) {
    fprintf(stderr, "%s\n", message.UTF8String);
    if (!validateOnly) {
        CFUserNotificationDisplayAlert(0, kCFUserNotificationStopAlertLevel,
            NULL, NULL, NULL, CFSTR("无法启动游戏"), (__bridge CFStringRef)message,
            CFSTR("好"), NULL, NULL, NULL);
    }
    return code;
}

int main(int argc, char **argv) {
    @autoreleasepool {
        // Used by the build smoke test; it never opens a window or runs a game.
        BOOL validateOnly = argc == 2 && strcmp(argv[1], "--fvm-validate") == 0;
        uint32_t size = 0;
        _NSGetExecutablePath(NULL, &size);
        char *buffer = malloc(size);
        if (!buffer || _NSGetExecutablePath(buffer, &size) != 0) {
            free(buffer);
            return fail(validateOnly, @"无法确定游戏位置，请重新解压完整的 .app 后再试。", 70);
        }
        NSString *executable = [[NSFileManager defaultManager]
            stringWithFileSystemRepresentation:buffer length:strlen(buffer)];
        free(buffer);
        NSString *macos = executable.stringByDeletingLastPathComponent;
        NSString *runner = [macos stringByAppendingPathComponent:@"Mac_Runner"].stringByStandardizingPath;
        NSString *resources = [macos stringByAppendingPathComponent:@"../Resources"].stringByStandardizingPath;
        NSString *game = [resources stringByAppendingPathComponent:@"game.ios"];
        NSString *ini = [resources stringByAppendingPathComponent:@"options.ini"];
        if (access(runner.fileSystemRepresentation, X_OK) != 0
            || access(game.fileSystemRepresentation, R_OK) != 0
            || access(ini.fileSystemRepresentation, R_OK) != 0) {
            return fail(validateOnly, @"游戏文件不完整或无法读取。请先完整解压 .app，再重新打开。", 78);
        }
        if (validateOnly) return 0;
        if (chdir(resources.fileSystemRepresentation) != 0) {
            return fail(NO, @"无法读取游戏目录，请将完整的 .app 放到普通文件夹后再试。", 78);
        }
        char **arguments = calloc((size_t)argc + 3, sizeof(char *));
        if (!arguments) return fail(NO, @"内存不足，无法启动游戏。", 70);
        arguments[0] = (char *)runner.fileSystemRepresentation;
        arguments[1] = "-game";
        arguments[2] = (char *)game.fileSystemRepresentation;
        for (int i = 1; i < argc; ++i) arguments[i + 2] = argv[i];
        execv(arguments[0], arguments);
        int error = errno;
        free(arguments);
        return fail(NO, [NSString stringWithFormat:@"无法启动游戏：%s", strerror(error)], 71);
    }
}
