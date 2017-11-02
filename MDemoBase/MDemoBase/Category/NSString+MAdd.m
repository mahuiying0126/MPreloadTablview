//
//  NSString+MAdd.m
//  MDemoBase
//
//  Created by yizhilu on 2017/11/2.
//  Copyright © 2017年 Magic. All rights reserved.
//

#import "NSString+MAdd.h"

@implementation NSString (MAdd)

+(NSString *)exchangeHTMLToString:(NSString *)html{
    NSScanner *theScanner = [NSScanner scannerWithString:html];
    NSString *text = nil;
    while ([theScanner isAtEnd] == NO)
    {
        [theScanner scanUpToString:@"<" intoString:NULL] ;
        [theScanner scanUpToString:@">" intoString:&text] ;
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@""];
        if ([html containsString:@"</p><p>"]) {
            NSString *replace = [html stringByReplacingOccurrencesOfString:@"</p><p>" withString:@"\n"];
            html = replace;
        }
        if ([html containsString:@"&nbsp;"]){
            NSString *replace = [html stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
            html = replace;
        }
        if ([html containsString:@"_ueditor_page_break_tag_"]){
            NSString *replace = [html stringByReplacingOccurrencesOfString:@"_ueditor_page_break_tag_" withString:@" "];
            
            html = replace;
        }
    }
    return [html stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}
@end
