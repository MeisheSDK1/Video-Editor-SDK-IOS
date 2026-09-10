//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    May 17. 2022
//   Author:        Meishe video team
//================================================================================

#pragma once
#import <Foundation/Foundation.h>
#import "NvsCommonDef.h"

NVS_EXPORT @interface NvsCaptionTextLayout : NSObject

- (int)getLineCount;
- (NvsRect)getBoundingRectAtLine:(int)lineNum;
- (int)getGlyphCountInLine:(int)lineNum;
- (NvsRect)getGlyphBoundingRect:(int)lineNum glyphIndexInLine:(int)glyphIndexInLine;

@end
