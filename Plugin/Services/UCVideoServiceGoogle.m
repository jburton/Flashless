//
//  UCVideoServiceGoogle.m
//  Flashless
//
//  Created by Christoph on 04.09.09.
//  Copyright Useless Coding 2009.
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


#import "UCVideoServiceGoogle.h"

@implementation UCVideoServiceGoogle

- (void)dealloc
{
	[super dealloc];
}

#pragma mark -

- (NSString *)label
{
	return @"Google Video";
}

- (void)findURLs
{
	NSString * videoFile = nil;
	NSString * thumbnail = nil;

	NSScanner * scan = [NSScanner scannerWithString:[self queryString]];
	[scan scanUpToString:@"docid=" intoString:NULL];
	if([scan scanString:@"docid=" intoString:NULL])
		{
		[scan scanUpToString:@"&" intoString:&videoID];
		}
	[videoID retain];
	if(videoID!=nil)
		{
		[self foundAVideo:YES];
		[self foundOriginal:[NSURL URLWithString:[NSString stringWithFormat:@"http://video.google.com/videoplay?docid=%@", videoID]]];
		}

	[scan setScanLocation:0];
	[scan scanUpToString:@"videoURL=" intoString:NULL];
	if([scan scanString:@"videoURL=" intoString:NULL])
		{
		[scan scanUpToString:@"&" intoString:&videoFile];
		}
	if(videoFile!=nil)
		{
		[self foundDownload:[NSURL URLWithString:[videoFile stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
		}

	[scan setScanLocation:0];
	[scan scanUpToString:@"thumbnailUrl=" intoString:NULL];
	if([scan scanString:@"thumbnailUrl=" intoString:NULL])
		{
		[scan scanUpToString:@"&" intoString:&thumbnail];
		}
	if(thumbnail!=nil)
		{
		[self foundPreview:[NSURL URLWithString:[thumbnail stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
		}
}

@end