// Cocoa owns text editing while a game input has focus. In particular, marked
// text must stay inside NSTextInputClient until the input method commits it.
#import <AppKit/AppKit.h>

#include "../FvmNativeSupport/Typedef.h"
#include "../FvmNativeSupport/json.hpp"
#include <algorithm>
#include <string>

using InputJson = nlohmann::json;

@interface FVMTextView : NSTextView <NSTextViewDelegate>
@property(nonatomic, copy) NSString* owner;
@property(nonatomic, copy) NSString* committed;
@property(nonatomic) NSUInteger limit;
@property(nonatomic) BOOL digitsOnly;
@property(nonatomic) BOOL submitted;
@property(nonatomic) BOOL cancelled;
@property(nonatomic) BOOL compositionKey;
@property(nonatomic, strong) NSUndoManager* editingUndoManager;
@property(nonatomic, weak) NSResponder* gameResponder;
- (void)commitText;
@end

namespace {
NSString* FilterText(NSString* source, NSUInteger limit, BOOL digitsOnly) {
    NSMutableString* text = [NSMutableString string];
    __block NSUInteger count = 0;
    [source enumerateSubstringsInRange:NSMakeRange(0, source.length)
        options:NSStringEnumerationByComposedCharacterSequences
        usingBlock:^(NSString* part, NSRange range, NSRange enclosing, BOOL* stop) {
            if (count >= limit) { *stop = YES; return; }
            if ([part rangeOfCharacterFromSet:NSCharacterSet.controlCharacterSet].location != NSNotFound) return;
            if (digitsOnly && (part.length != 1 || [part characterAtIndex:0] < '0' || [part characterAtIndex:0] > '9')) return;
            [text appendString:part];
            ++count;
        }];
    return text;
}

NSUInteger CharacterCount(NSString* text) {
    __block NSUInteger count = 0;
    [text enumerateSubstringsInRange:NSMakeRange(0, text.length)
        options:NSStringEnumerationByComposedCharacterSequences | NSStringEnumerationSubstringNotRequired
        usingBlock:^(NSString* part, NSRange range, NSRange enclosing, BOOL* stop) { ++count; }];
    return count;
}
}

@implementation FVMTextView
- (NSUndoManager*)undoManager {
    // Runner windows need not provide a Cocoa undo manager. Keep editing
    // history local to this input rather than sharing it with the game window.
    if (!self.editingUndoManager) self.editingUndoManager = [NSUndoManager new];
    return self.editingUndoManager;
}

- (void)commitText {
    if (self.hasMarkedText) return;
    NSString* text = FilterText(self.string, self.limit, self.digitsOnly);
    if (![text isEqualToString:self.string]) {
        NSRange selected = self.selectedRange;
        self.string = text;
        self.selectedRange = NSMakeRange(std::min(selected.location, text.length), 0);
    }
    self.committed = text;
}

- (void)insertText:(id)text replacementRange:(NSRange)range {
    NSString* replacement = [text isKindOfClass:NSAttributedString.class] ? [text string] : text;
    NSRange replaced = range;
    if (replaced.location == NSNotFound) replaced = self.hasMarkedText ? self.markedRange : self.selectedRange;
    if (NSMaxRange(replaced) > self.string.length) return;
    NSString* remaining = [self.string stringByReplacingCharactersInRange:replaced withString:@""];
    NSUInteger existing = CharacterCount(remaining);
    NSUInteger available = self.limit > existing ? self.limit - existing : 0;
    replacement = FilterText(replacement, available, self.digitsOnly);
    // Filter before NSTextView registers the undo operation. Truncating the
    // entire storage after a paste would leave undo with an invalid range.
    [super insertText:replacement replacementRange:range];
    [self commitText];
}

- (void)textDidChange:(NSNotification*)notification { [self commitText]; }
- (void)unmarkText { [super unmarkText]; [self commitText]; }

// Runner has no standard Edit menu. Handle the usual key equivalents here so
// Command-V never falls through to GameMaker as the literal letter 'v'.
- (BOOL)performKeyEquivalent:(NSEvent*)event {
    if (!(event.modifierFlags & NSEventModifierFlagCommand)) return [super performKeyEquivalent:event];
    NSString* key = event.charactersIgnoringModifiers.lowercaseString;
    if ([key isEqualToString:@"a"]) [self selectAll:nil];
    else if ([key isEqualToString:@"c"]) [self copy:nil];
    else if ([key isEqualToString:@"x"]) [self cut:nil];
    else if ([key isEqualToString:@"v"]) [self pasteAsPlainText:nil];
    else if ([key isEqualToString:@"z"]) {
        if (event.modifierFlags & NSEventModifierFlagShift) [self.undoManager redo];
        else [self.undoManager undo];
    } else return [super performKeyEquivalent:event];
    return YES;
}

- (void)keyDown:(NSEvent*)event {
    if ((event.modifierFlags & NSEventModifierFlagCommand) && [self performKeyEquivalent:event]) return;
    self.compositionKey = self.hasMarkedText;
    [super keyDown:event];
    self.compositionKey = NO;
}

- (void)doCommandBySelector:(SEL)selector {
    if (selector == @selector(insertNewline:) || selector == @selector(insertNewlineIgnoringFieldEditor:)) {
        // Return used to choose an IME candidate is not a form submission.
        if (!self.compositionKey && !self.hasMarkedText) self.submitted = YES;
    } else if (selector == @selector(cancelOperation:)) {
        if (!self.compositionKey && !self.hasMarkedText) self.cancelled = YES;
    } else if (selector == @selector(insertTab:) || selector == @selector(insertBacktab:)) {
        // Inputs are single-line. Do not insert a tab or let it reach gameplay.
    } else [super doCommandBySelector:selector];
}
@end

namespace {
FVMTextView* editor;
NSScrollView* clip;
NSMutableDictionary<NSString*, NSDictionary*>* retired;

NSString* InputString(const InputJson& request, const char* key, const char* fallback = "") {
    const auto text = request.value(key, std::string(fallback));
    return [NSString stringWithUTF8String:text.c_str()] ?: @"";
}

NSDictionary* Snapshot(BOOL active) {
    // The caret is expressed in Unicode scalars, like GML's string_length,
    // instead of NSString's UTF-16 offsets.
    NSUInteger end = std::min(editor.selectedRange.location, editor.string.length);
    NSString* prefix = [editor.string substringToIndex:end];
    NSUInteger caret = [prefix lengthOfBytesUsingEncoding:NSUTF32LittleEndianStringEncoding] / 4;
    return @{@"ok": @YES, @"active": @(active), @"text": editor.committed ?: @"",
             @"caret": @(caret), @"composing": @(editor.hasMarkedText),
             @"submitted": @(editor.submitted), @"cancelled": @(editor.cancelled)};
}

void CloseEditor() {
    if (!editor) return;
    [editor.inputContext discardMarkedText];
    [editor unmarkText];
    [editor commitText];
    if (!retired) retired = [NSMutableDictionary dictionary];
    retired[editor.owner] = Snapshot(NO);
    NSWindow* window = editor.window;
    if (window.firstResponder == editor) [window makeFirstResponder:editor.gameResponder ?: window.contentView];
    [clip removeFromSuperview];
    clip = nil;
    editor = nil;
}

NSColor* InputColor(int color) {
    // GameMaker uses $BBGGRR.
    return [NSColor colorWithSRGBRed:(color & 255) / 255.0
        green:((color >> 8) & 255) / 255.0 blue:((color >> 16) & 255) / 255.0 alpha:1];
}

void LayoutEditor(const InputJson& request) {
    if (!request.contains("width")) return;
    NSView* parent = clip.superview;
    const NSRect bounds = parent.bounds;
    const double width = std::max(1.0, request.value("width", 0.2) * bounds.size.width);
    const double height = std::max(1.0, request.value("height", 0.05) * bounds.size.height);
    double y = request.value("y", 0.0) * bounds.size.height;
    if (!parent.isFlipped) y = bounds.size.height - y - height;
    clip.frame = NSMakeRect(bounds.origin.x + request.value("x", 0.0) * bounds.size.width,
                            bounds.origin.y + y, width, height);
    const double fontSize = std::max(1.0, request.value("font_size", 0.03) * bounds.size.height);
    if (editor.font.pointSize != fontSize) editor.font = [NSFont systemFontOfSize:fontSize];
    NSColor* color = InputColor(request.value("color", 0));
    if (![editor.textColor isEqual:color]) editor.textColor = color;
    editor.insertionPointColor = editor.textColor;
    if (editor.frame.size.width < width || editor.frame.size.height != height) {
        editor.frame = NSMakeRect(0, 0, width, height);
    }
    editor.minSize = NSMakeSize(width, height);
    editor.textContainerInset = NSMakeSize(0, std::max(0.0, (height - [editor.layoutManager defaultLineHeightForFont:editor.font]) / 2));
    [editor scrollRangeToVisible:editor.selectedRange];
}

NSDictionary* InputRequest(const InputJson& request) {
    const auto operation = request.value("op", std::string("poll"));
    NSString* owner = InputString(request, "owner");
    if (owner.length == 0) return @{@"ok": @NO, @"error": @"Missing input owner"};
    if (operation == "begin" && (!editor || ![owner isEqualToString:editor.owner])) {
        CloseEditor();
        NSWindow* window = NSApp.keyWindow ?: NSApp.mainWindow;
        if (!window.contentView) return @{@"ok": @NO, @"error": @"No game window"};
        [retired removeObjectForKey:owner];
        clip = [[NSScrollView alloc] initWithFrame:NSZeroRect];
        clip.drawsBackground = NO;
        clip.borderType = NSNoBorder;
        clip.hasVerticalScroller = NO;
        clip.hasHorizontalScroller = NO;
        editor = [[FVMTextView alloc] initWithFrame:NSZeroRect];
        editor.owner = owner;
        editor.limit = std::clamp(request.value("limit", 64), 0, 4096);
        editor.digitsOnly = request.value("digits", false);
        editor.gameResponder = window.firstResponder;
        editor.richText = NO;
        editor.importsGraphics = NO;
        editor.drawsBackground = NO;
        editor.allowsUndo = YES;
        editor.automaticQuoteSubstitutionEnabled = NO;
        editor.automaticDashSubstitutionEnabled = NO;
        editor.automaticTextReplacementEnabled = NO;
        editor.automaticSpellingCorrectionEnabled = NO;
        editor.continuousSpellCheckingEnabled = NO;
        editor.horizontallyResizable = YES;
        editor.verticallyResizable = NO;
        editor.textContainer.widthTracksTextView = NO;
        editor.textContainer.containerSize = NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX);
        editor.textContainer.lineFragmentPadding = 0;
        editor.delegate = editor;
        [editor setAccessibilityLabel:InputString(request, "label", "游戏文本输入")];
        editor.string = InputString(request, "text");
        [editor commitText];
        editor.selectedRange = NSMakeRange(editor.string.length, 0);
        clip.documentView = editor;
        [window.contentView addSubview:clip positioned:NSWindowAbove relativeTo:nil];
        LayoutEditor(request);
        [window makeFirstResponder:editor];
    }
    if (!editor || ![owner isEqualToString:editor.owner]) {
        NSDictionary* result = retired[owner] ?: @{@"ok": @NO, @"active": @NO};
        [retired removeObjectForKey:owner];
        return result;
    }
    if (operation == "end") {
        CloseEditor();
        NSDictionary* result = retired[owner];
        [retired removeObjectForKey:owner];
        return result;
    }
    if (operation == "set") {
        [editor.inputContext discardMarkedText];
        [editor unmarkText];
        editor.string = InputString(request, "text");
        [editor commitText];
        editor.selectedRange = NSMakeRange(editor.string.length, 0);
        [editor.undoManager removeAllActions];
    }
    LayoutEditor(request);
    NSDictionary* result = Snapshot(editor.window.firstResponder == editor);
    editor.submitted = NO;
    editor.cancelled = NO;
    return result;
}
} // namespace

GmlCallable const char* MacTextInput(const char* json) {
    static thread_local std::string response;
    try {
        const auto request = InputJson::parse(json ? json : "{}");
        __block NSData* data;
        void (^action)(void) = ^{
            @autoreleasepool {
                NSDictionary* result;
                try {
                    result = InputRequest(request);
                } catch (const std::exception& error) {
                    result = @{@"ok": @NO, @"error": [NSString stringWithUTF8String:error.what()] ?: @"Invalid input request"};
                }
                data = [NSJSONSerialization dataWithJSONObject:result options:0 error:nil];
            }
        };
        if ([NSThread isMainThread]) action();
        else dispatch_sync(dispatch_get_main_queue(), action);
        response.assign(static_cast<const char*>(data.bytes), data.length);
    } catch (const std::exception& error) {
        response = InputJson({{"ok", false}, {"error", error.what()}}).dump();
    }
    return response.c_str();
}
