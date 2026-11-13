// Run without displaying a window or changing the user's input source/clipboard.
#import "../FvmNativeSupport/macos/text_input.mm"
#include <cstdlib>
#include <iostream>

static void Check(bool condition, const char* message) {
    if (!condition) { std::cerr << message << '\n'; std::exit(1); }
}

static InputJson Request(InputJson request) {
    request["owner"] = request.value("owner", std::string("test"));
    return InputJson::parse(MacTextInput(request.dump().c_str()));
}

@interface FVMInputTestApplication : NSApplication
@property(nonatomic, strong) NSWindow* testWindow;
@end
@implementation FVMInputTestApplication
- (NSWindow*)mainWindow { return self.testWindow; }
@end

@interface FVMInputTestWindow : NSWindow
@end
@implementation FVMInputTestWindow
- (NSUndoManager*)undoManager { return nil; }
@end

int main() {
    @autoreleasepool {
        FVMInputTestApplication* app = (FVMInputTestApplication*)[FVMInputTestApplication sharedApplication];
        NSWindow* window = [[FVMInputTestWindow alloc] initWithContentRect:NSMakeRect(0, 0, 800, 600)
            styleMask:NSWindowStyleMaskTitled backing:NSBackingStoreBuffered defer:NO];
        app.testWindow = window;
        auto result = Request({{"op", "begin"}, {"text", "玩家"}, {"limit", 4},
            {"x", .1}, {"y", .2}, {"width", .5}, {"height", .1}, {"font_size", .03}});
        Check(result.value("ok", false), "begin failed");
        Check(editor && window.firstResponder == editor, "editor did not acquire focus");
        Check(result["text"] == "玩家", "Unicode initial text lost");
        Check(clip.frame.origin.x == 80 && clip.frame.origin.y == 420, "window coordinate mapping failed");

        [editor setMarkedText:@"nihao" selectedRange:NSMakeRange(5, 0) replacementRange:NSMakeRange(NSNotFound, 0)];
        result = Request({{"op", "poll"}});
        Check(result["composing"] == true && result["text"] == "玩家", "preedit leaked into game state");
        [editor insertText:@"你好" replacementRange:NSMakeRange(NSNotFound, 0)];
        [editor commitText];
        result = Request({{"op", "poll"}});
        Check(result["text"] == "玩家你好", "multi-character IME commit lost");

        editor.compositionKey = YES;
        [editor doCommandBySelector:@selector(insertNewline:)];
        Check(Request({{"op", "poll"}})["submitted"] == false, "IME Return submitted the form");
        editor.compositionKey = NO;
        [editor doCommandBySelector:@selector(insertNewline:)];
        Check(Request({{"op", "poll"}})["submitted"] == true, "plain Return not submitted");
        Check(Request({{"op", "poll"}})["submitted"] == false, "submission was not consumed");

        Request({{"op", "set"}, {"text", "你好😀世界"}});
        Check(Request({{"op", "poll"}})["text"] == "你好😀世", "limit split a Unicode character");
        Request({{"op", "set"}, {"text", ""}});
        [editor insertText:@"一二😀四五六" replacementRange:NSMakeRange(NSNotFound, 0)];
        Check(Request({{"op", "poll"}})["text"] == "一二😀四", "paste did not respect the length limit");
        [editor.undoManager undo];
        Check(Request({{"op", "poll"}})["text"] == "", "undo after a truncated paste failed");
        [editor setMarkedText:@"zhongwen" selectedRange:NSMakeRange(8, 0) replacementRange:NSMakeRange(NSNotFound, 0)];
        Request({{"op", "poll"}, {"text", "stale frame value"}});
        Check(editor.hasMarkedText && [editor.string isEqualToString:@"zhongwen"], "poll overwrote marked text");
        Request({{"op", "set"}, {"text", "重置"}});
        Check(!editor.hasMarkedText && [editor.string isEqualToString:@"重置"], "explicit reset failed");

        Request({{"op", "begin"}, {"owner", "quantity"}, {"text", "12a３\n4"}, {"digits", true}});
        Check(Request({{"op", "poll"}, {"owner", "quantity"}})["text"] == "124", "numeric paste filtering failed");
        result = Request({{"op", "poll"}});
        Check(result["active"] == false && result["text"] == "重置", "focus transfer lost the old text");
        Request({{"op", "end"}, {"owner", "quantity"}});
        Check(editor == nil && clip == nil && window.firstResponder != nil, "cleanup did not restore game responder");
        Check(InputJson::parse(MacTextInput("{broken"))["ok"] == false, "invalid JSON accepted");
        std::cout << "macOS text input: composition, submission, Unicode, limits, focus and cleanup passed\n";
    }
}
