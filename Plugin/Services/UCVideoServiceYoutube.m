//
//  UCVideoServiceYoutube.m
//  Flashless
//
//  Created by Christoph on 03.09.2009.
//  Copyright 2009-2010 Useless Coding.
/*
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without restriction,
 including without limitation the rights to use, copy, modify, merge,
 publish, distribute, sublicense, and/or sell copies of the Software,
 and to permit persons to whom the Software is furnished to do so,
 subject to the following conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 */


#import "UCVideoServiceYoutube.h"

@implementation UCVideoServiceYoutube

- (NSString *)label
{
	return @"YouTube";
}

- (BOOL)canFindDownload
{
	return videoID!=nil;
}

- (void)prepare
{
	videoID = [flashVars objectForKey:@"video_id"];
	if(videoID==nil) {
		NSString * scanString = [self pathString];
		if(scanString==nil) {
			[self foundNoDownload];
			return;
		}
		[[self class] scan:scanString from:@"/v/" to:@"&" into:&videoID];
		if(videoID==nil) {
			[[self class] scan:scanString from:@"/e/" to:@"&" into:&videoID];
		}
		if(videoID==nil) {
			scanString = [self queryString];
			if(scanString==nil) {
				[self foundNoDownload];
				return;
			}
			[[self class] scan:scanString from:@"v=" to:@"&" into:&videoID];
		}
		if(videoID==nil) {
			[[self class] scan:scanString from:@"video_id=" to:@"&" into:&videoID];
		}
	}
	if(videoID==nil) {
		[self foundNoDownload];
		return;
	}
	[videoID retain];
}

- (void)findURLs
{
	if(videoID==nil) { return; }
	[self foundAVideo:YES];
	[self foundOriginal:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@", videoID]]];
	[self foundPreview:[NSURL URLWithString:[NSString stringWithFormat:@"http://i1.ytimg.com/vi/%@/hqdefault.jpg", videoID]]];
	NSString * fmtMap = [flashVars objectForKey:@"fmt_url_map"];
	if(fmtMap!=nil) {
		[self foundDownload:[self downloadURLwithVideoID:videoID fmtMap:fmtMap]];
	}
}

- (void)findDownloadURL
{
	if(![self canFindDownload]) {
		[self foundNoDownload];
		return;
	}
	NSString * fmtMap = [flashVars objectForKey:@"fmt_url_map"];
	if(fmtMap!=nil) {
		[self foundDownload:[self downloadURLwithVideoID:videoID fmtMap:fmtMap]];
	} else {
		[self retrieveHint:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.youtube.com/get_video_info?video_id=%@", videoID]]];
	}
}

- (void)receivedHint:(NSString *)hint
{
	if(hint==nil) {
		[self foundNoDownload];
		return;
	}
	NSString * fmtMap = nil;
	[[self class] scan:hint from:@"url_encoded_fmt_stream_map=" to:@"&" into:&fmtMap];
	if(fmtMap==nil) {
		[self foundNoDownload];
	} else {
		NSURL *foundURL = [self downloadURLwithVideoID:videoID fmtMap:fmtMap];
		if (foundURL)
			[self foundDownload:foundURL];
		else
			[self foundNoDownload];
	}
}

- (NSURL *)downloadURLwithVideoID:(NSString *)theID fmtMap:(NSString *)theMap
{
	theMap = [theMap stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString * fmtMap = [theMap stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSScanner * scan = [NSScanner scannerWithString:fmtMap];
	NSString * urlString = nil;
	
	// We assume that formats are sorted descending
	while(![scan isAtEnd] && urlString==nil) {
		[scan scanUpToString:@"url=" intoString:NULL];
		[scan scanString:@"url=" intoString:NULL];
		[scan scanUpToString:@";" intoString:&urlString];
		NSRange loc = [urlString rangeOfString:@"&type=video/mp4" options:NSAnchoredSearch | NSBackwardsSearch];
		if (loc.location != NSNotFound)
			break;
	}
	return (urlString ? [NSURL URLWithString:urlString] : nil);
}

@end