//
//  LKGoogleTranslator.m
//  GoogleTranslator
//

#import "LKGoogleTranslator.h"
#import "JSON.h"

#define URL_STRING @"http://ajax.googleapis.com/ajax/services/language/translate?v=1.0&langpair="
#define TEXT_VAR @"&q="

@implementation LKGoogleTranslator

- (NSString *)urlencode:(NSString *)url
{
    NSArray *escapeChars = [NSArray arrayWithObjects:@";" , @"/" , @"?" , @":" ,
							@"@" , @"&" , @"=" , @"+" ,
							@"$" , @"," , @"[" , @"]",
							@"#", @"!", @"'", @"(", 
							@")", @"*", nil];
	
    NSArray *replaceChars = [NSArray arrayWithObjects:@"%3B" , @"%2F" , @"%3F" ,
							 @"%3A" , @"%40" , @"%26" ,
							 @"%3D" , @"%2B" , @"%24" ,
							 @"%2C" , @"%5B" , @"%5D", 
							 @"%23", @"%21", @"%27",
							 @"%28", @"%29", @"%2A", nil];
	
    int len = [escapeChars count];
	
    NSMutableString *temp = [url mutableCopy];
	
    int i;
	
    for(i = 0; i < len; i++)
    {
        [temp replaceOccurrencesOfString:[escapeChars objectAtIndex:i]
							  withString:[replaceChars objectAtIndex:i]
								 options:NSLiteralSearch
								   range:NSMakeRange(0, [temp length])];
    }
	
    NSString *result = [NSString stringWithString:temp];
	
	[temp release];
	
    return result;
}

// OD: modified to use POST to prevent length error
- (NSString*)translateText:(NSString*)sourceText fromLanguage:(NSString*)sourceLanguage toLanguage:(NSString*)targetLanguage
{
	NSString* urlString = @"http://ajax.googleapis.com/ajax/services/language/translate";

	NSMutableString *bodyString = [NSMutableString stringWithString:@"v=1.0&langpair="];
	
	[bodyString appendString:sourceLanguage];
	[bodyString appendString:@"|"];
	[bodyString appendString:targetLanguage];
	[bodyString appendString:TEXT_VAR];
	NSString *encodedString = [sourceText stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
	[bodyString appendString:[self urlencode:encodedString]];
	
	NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
									cachePolicy:NSURLRequestUseProtocolCachePolicy
								timeoutInterval:60.0];
	[request setHTTPMethod:@"POST"];
	[request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
	
	//create the body
	NSMutableData *postBody = [NSMutableData data];
	
	[postBody appendData:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
	
	[request setHTTPBody:postBody];
	
	NSHTTPURLResponse* response = nil; NSError* error = nil;
	NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error: &error];
	
	if(data == nil)
	{
		NSLog(@"Could not connect to translate.");
		
		return nil;
	}
	else
	{
		NSString *contents = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
		
		NSNumber *responseStatus = [[contents JSONValue] objectForKey:@"responseStatus"];
		
		if([responseStatus integerValue] != 200) 
		{
			NSLog(@"Response status: %d", [responseStatus integerValue]);
			
			return nil;
		}
		
		return [self translateCharacters:[[[contents JSONValue] objectForKey:@"responseData"] objectForKey:@"translatedText"]];
	}
}

- (NSString *)translateCharacters:(NSString*)text
{	
	if(text == nil)
	{
		return nil;
	}
	
	NSMutableString* translatedText = [NSMutableString string];
	NSRange range = [text rangeOfString: @"&#"];
	int processedSoFar = 0;
	
	while (range.location != NSNotFound)
	{
		int pos = range.location;
		[translatedText appendString:[text substringWithRange:NSMakeRange(processedSoFar, pos - processedSoFar)]];
		range = [text rangeOfString:@";" options: 0 range:NSMakeRange(pos + 2, [text length] - pos - 2)];
		int code = [[text substringWithRange: NSMakeRange(pos + 2, range.location - pos - 2)] intValue];
		[translatedText appendFormat:@"%C", (unichar) code];
		processedSoFar = range.location + 1;
		range = [text rangeOfString:@"&#" options:0 range:NSMakeRange(processedSoFar, [text length] - processedSoFar)];
	}
	
	[translatedText appendString:[text substringFromIndex:processedSoFar]];
	
	return translatedText;
}

@end
