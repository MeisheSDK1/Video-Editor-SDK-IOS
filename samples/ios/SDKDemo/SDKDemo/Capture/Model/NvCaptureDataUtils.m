//
//  NvCaptureDataUtils.m
//  SDKDemo
//
//  Created by 李勇 on 2022/8/2.
//  Copyright © 2022 meishe. All rights reserved.
//

#import "NvCaptureDataUtils.h"
//"capture.skin.color" = "肤色";
@implementation NvCaptureDataUtils

+ (NSArray *)getCaptureBeautifulSkinTitleArray:(BOOL)matte{
    
    return matte ? @[NvLocalString(@"Strength", @"磨皮"),
                     NvLocalString(@"Strength", @"返回"),
                     NvLocalString(@"Strength Mode 1", @"磨皮1"),
                     NvLocalString(@"Strength Mode 2", @"磨皮2"),
                     NvLocalString(@"Strength Mode 3", @"磨皮3"),
                     NvLocalString(@"Strength Mode 4", @"磨皮4"),
                     NvLocalString(@"capture.skin.color", @"肤色"),
                     NvLocalString(@"capture.skin.color", @"返回"),
                     NvLocalString(@"Skin Color 1", @"冷白"),
                     NvLocalString(@"Skin Color 2", @"粉白"),
                     NvLocalString(@"Skin Color 3", @"暖白"),
                     NvLocalString(@"Skin Color 4", @"美黑"),
                     NvLocalString(@"Shiny", @"去油光"),
                     NvLocalString(@"Rosy", @"红润")] : @[
                         NvLocalString(@"Strength", @"磨皮"),
                         NvLocalString(@"Strength", @"返回"),
                         NvLocalString(@"Strength Mode 1", @"磨皮1"),
                         NvLocalString(@"Strength Mode 2", @"磨皮2"),
                         NvLocalString(@"Strength Mode 3", @"磨皮3"),
                         NvLocalString(@"Strength Mode 4", @"磨皮4"),
                         NvLocalString(@"capture.skin.color", @"肤色"),
                         NvLocalString(@"capture.skin.color", @"返回"),
                         NvLocalString(@"Skin Color 1", @"冷白"),
                         NvLocalString(@"Skin Color 2", @"粉白"),
                         NvLocalString(@"Skin Color 3", @"暖白"),
                         NvLocalString(@"Skin Color 4", @"美黑"),
                         NvLocalString(@"Rosy", @"红润")
                     ];
}

+ (NSArray *)getCaptureBeautifulSkinCoverArray:(BOOL)matte{
    return matte ? @[       @"capture_skin_grinding_sum",
                            @"capture_skin_grinding_return",
                            @"NvCaptureBeautyStrength",
                            @"NvCaptureBeautyStrength",
                            @"NvCaptureBeautyStrength",
                            @"NvCaptureBeautyStrength",
                            @"NvCaptureBeautyWhitening",
                            @"capture_skin_grinding_return",
                            @"NvCaptureBeautyStrength",
                            @"NvCaptureBeautyStrength",
                            @"NvCaptureBeautyStrength",
                            @"NvCaptureBeautyStrength",
                            @"NvCaptureBeautyShiny",
                            @"NvCaptureBeautyReddening"] : @[
                                @"capture_skin_grinding_sum",
                                @"capture_skin_grinding_return",
                                @"NvCaptureBeautyStrength",
                                @"NvCaptureBeautyStrength",
                                @"NvCaptureBeautyStrength",
                                @"NvCaptureBeautyStrength",
                                @"NvCaptureBeautyWhitening",
                                @"capture_skin_grinding_return",
                                @"NvCaptureBeautyStrength",
                                @"NvCaptureBeautyStrength",
                                @"NvCaptureBeautyStrength",
                                @"NvCaptureBeautyStrength",
                                @"NvCaptureBeautyReddening"];
}

+ (NSArray *)getCaptureBeautifulSkinCoverSelectedArray:(BOOL)matte{
    return matte ? @[@"capture_skin_grinding_sum",
                     @"capture_skin_grinding_return",
                     @"NvCaptureBeautyStrength_s",
                     @"NvCaptureBeautyStrength_s",
                     @"NvCaptureBeautyStrength_s",
                     @"NvCaptureBeautyStrength_s",
                     @"NvCaptureBeautyWhitening_s",
                     @"capture_skin_grinding_return",
                     @"NvCaptureBeautyStrength_s",
                     @"NvCaptureBeautyStrength_s",
                     @"NvCaptureBeautyStrength_s",
                     @"NvCaptureBeautyStrength_s",
                     @"NvCaptureBeautyShiny_s",
                     @"NvCaptureBeautyReddening_s"] : @[
                         @"capture_skin_grinding_sum",
                         @"capture_skin_grinding_return",
                         @"NvCaptureBeautyStrength_s",
                         @"NvCaptureBeautyStrength_s",
                         @"NvCaptureBeautyStrength_s",
                         @"NvCaptureBeautyStrength_s",
                         @"NvCaptureBeautyWhitening_s",
                         @"capture_skin_grinding_return",
                         @"NvCaptureBeautyStrength_s",
                         @"NvCaptureBeautyStrength_s",
                         @"NvCaptureBeautyStrength_s",
                         @"NvCaptureBeautyStrength_s",
                         @"NvCaptureBeautyReddening_s"];
}

+ (NSArray *)getCaptureBeautifulSkinFxNameArray:(BOOL)matte isContentAI:(BOOL)isContentAI{
    if (isContentAI) {
        return matte ? @[@"",
                         @"",
                         @"Beauty Strength",
                         @"Advanced Beauty Type Zero",
                         @"Advanced Beauty Type One",
                         @"Advanced Beauty Type Two",
                         @"",
                         @"",
                         @"Beauty Whitening 1",
                         @"Beauty Whitening 2",
                         @"Beauty Whitening 3",
                         @"Beauty Whitening 4",
                         @"Shiny",
                         @"Beauty Reddening"] : @[
                             @"",
                             @"",
                             @"Beauty Strength",
                             @"Advanced Beauty Type Zero",
                             @"Advanced Beauty Type One",
                             @"Advanced Beauty Type Two",
                             @"",
                             @"",
                             @"Beauty Whitening 1",
                             @"Beauty Whitening 2",
                             @"Beauty Whitening 3",
                             @"Beauty Whitening 4",
                             @"Beauty Reddening"];
    }
    
    return matte ? @[@"",
                     @"",
                     @"Strength",
                     @"Strength",
                     @"Strength",
                     @"Strength",
                     @"",
                     @"",
                     @"Beauty Whitening",
                     @"Beauty Whitening",
                     @"Beauty Whitening",
                     @"Beauty Whitening",
                     @"Shiny",
                     @"Reddening"] : @[
                         @"",
                         @"",
                         @"Strength",
                         @"Strength",
                         @"Strength",
                         @"Strength",
                         @"",
                         @"",
                         @"Beauty Whitening",
                         @"Beauty Whitening",
                         @"Beauty Whitening",
                         @"Beauty Whitening",
                         @"Reddening"] ;
}

+ (NSArray *)getBeautifulSkinTitleArray:(BOOL)matte{
    if([NvBaseUtils enableAIBeauty]) {
        return matte ? @[NvLocalString(@"Strength", @"磨皮"),
                         NvLocalString(@"Strength", @"返回"),
                         NvLocalString(@"Strength Mode 1", @"磨皮1"),
                         NvLocalString(@"Strength Mode 2", @"磨皮2"),
                         NvLocalString(@"Strength Mode 3", @"磨皮3"),
                         NvLocalString(@"Strength Mode 4", @"磨皮4"),
                         NvLocalString(@"AI Concealer", @"AI磨皮"),
                         NvLocalString(@"interval", @"间隔"),
                         NvLocalString(@"Whiten mode B", @"美白B"),
                         NvLocalString(@"Shiny", @"去油光"),
                         NvLocalString(@"Rosy", @"红润"),
                         NvLocalString(@"Color correction", @"校色"),
                         NvLocalString(@"Amount", @"锐度")] : @[
                             NvLocalString(@"Strength", @"磨皮"),
                             NvLocalString(@"Strength", @"返回"),
                             NvLocalString(@"Strength Mode 1", @"磨皮1"),
                             NvLocalString(@"Strength Mode 2", @"磨皮2"),
                             NvLocalString(@"Strength Mode 3", @"磨皮3"),
                             NvLocalString(@"Strength Mode 4", @"磨皮4"),
                             NvLocalString(@"AI Concealer", @"AI磨皮"),
                             NvLocalString(@"interval", @"间隔"),
                             NvLocalString(@"Whiten mode B", @"美白B"),
                             NvLocalString(@"Rosy", @"红润"),
                             NvLocalString(@"Color correction", @"校色"),
                             NvLocalString(@"Amount", @"锐度")];
    }
    return matte ? @[NvLocalString(@"Strength", @"磨皮"),
                     NvLocalString(@"Strength", @"返回"),
                     NvLocalString(@"Strength Mode 1", @"磨皮1"),
                     NvLocalString(@"Strength Mode 2", @"磨皮2"),
                     NvLocalString(@"Strength Mode 3", @"磨皮3"),
                     NvLocalString(@"Strength Mode 4", @"磨皮4"),
                     NvLocalString(@"interval", @"间隔"),
                     NvLocalString(@"Whiten mode B", @"美白B"),
                     NvLocalString(@"Shiny", @"去油光"),
                     NvLocalString(@"Rosy", @"红润"),
                     NvLocalString(@"Color correction", @"校色"),
                     NvLocalString(@"Amount", @"锐度")] : @[
                         NvLocalString(@"Strength", @"磨皮"),
                         NvLocalString(@"Strength", @"返回"),
                         NvLocalString(@"Strength Mode 1", @"磨皮1"),
                         NvLocalString(@"Strength Mode 2", @"磨皮2"),
                         NvLocalString(@"Strength Mode 3", @"磨皮3"),
                         NvLocalString(@"Strength Mode 4", @"磨皮4"),
                         NvLocalString(@"interval", @"间隔"),
                         NvLocalString(@"Whiten mode B", @"美白B"),
                         NvLocalString(@"Rosy", @"红润"),
                         NvLocalString(@"Color correction", @"校色"),
                         NvLocalString(@"Amount", @"锐度")];
}
+ (NSArray *)getBeautifulSkinCoverArray:(BOOL)matte{
    if([NvBaseUtils enableAIBeauty]) {
        return matte ? @[       @"capture_skin_grinding_sum",@"capture_skin_grinding_return",@"NvCaptureBeautyStrength",@"NvCaptureBeautyStrength",@"NvCaptureBeautyStrength",@"NvCaptureBeautyStrength",@"NvCaptureBeautyStrength",@"",@"NvCaptureBeautyWhitening",@"NvCaptureBeautyShiny",@"NvCaptureBeautyReddening",@"NvCaptureBeautyFilter1",@"NvCaptureBeautySharpen1"] : @[       @"capture_skin_grinding_sum",@"capture_skin_grinding_return",@"NvCaptureBeautyStrength",@"NvCaptureBeautyStrength",@"NvCaptureBeautyStrength",@"NvCaptureBeautyStrength",@"NvCaptureBeautyStrength",@"",@"NvCaptureBeautyWhitening",@"NvCaptureBeautyReddening",@"NvCaptureBeautyFilter1",@"NvCaptureBeautySharpen1"];
    }
    return matte ? @[       @"capture_skin_grinding_sum",@"capture_skin_grinding_return",@"NvCaptureBeautyStrength",@"NvCaptureBeautyStrength",@"NvCaptureBeautyStrength",@"NvCaptureBeautyStrength",@"",@"NvCaptureBeautyWhitening",@"NvCaptureBeautyShiny",@"NvCaptureBeautyReddening",@"NvCaptureBeautyFilter1",@"NvCaptureBeautySharpen1"] : @[       @"capture_skin_grinding_sum",@"capture_skin_grinding_return",@"NvCaptureBeautyStrength",@"NvCaptureBeautyStrength",@"NvCaptureBeautyStrength",@"NvCaptureBeautyStrength",@"",@"NvCaptureBeautyWhitening",@"NvCaptureBeautyReddening",@"NvCaptureBeautyFilter1",@"NvCaptureBeautySharpen1"];
}
+ (NSArray *)getBeautifulSkinCoverSelectedArray:(BOOL)matte{
    if([NvBaseUtils enableAIBeauty]) {
        return matte ? @[@"capture_skin_grinding_sum",@"capture_skin_grinding_return",@"NvCaptureBeautyStrength_s",@"NvCaptureBeautyStrength_s",@"NvCaptureBeautyStrength_s",@"NvCaptureBeautyStrength_s",@"NvCaptureBeautyStrength_s",@"",@"NvCaptureBeautyWhitening_s",@"NvCaptureBeautyShiny_s",@"NvCaptureBeautyReddening_s",@"NvCaptureBeautyFilter1_s",@"NvCaptureBeautySharpen1_s"] : @[@"capture_skin_grinding_sum",@"capture_skin_grinding_return",@"NvCaptureBeautyStrength_s",@"NvCaptureBeautyStrength_s",@"NvCaptureBeautyStrength_s",@"NvCaptureBeautyStrength_s",@"NvCaptureBeautyStrength_s",@"",@"NvCaptureBeautyWhitening_s",@"NvCaptureBeautyReddening_s",@"NvCaptureBeautyFilter1_s",@"NvCaptureBeautySharpen1_s"];
    }
    return matte ? @[@"capture_skin_grinding_sum",@"capture_skin_grinding_return",@"NvCaptureBeautyStrength_s",@"NvCaptureBeautyStrength_s",@"NvCaptureBeautyStrength_s",@"NvCaptureBeautyStrength_s",@"",@"NvCaptureBeautyWhitening_s",@"NvCaptureBeautyShiny_s",@"NvCaptureBeautyReddening_s",@"NvCaptureBeautyFilter1_s",@"NvCaptureBeautySharpen1_s"] : @[@"capture_skin_grinding_sum",@"capture_skin_grinding_return",@"NvCaptureBeautyStrength_s",@"NvCaptureBeautyStrength_s",@"NvCaptureBeautyStrength_s",@"NvCaptureBeautyStrength_s",@"",@"NvCaptureBeautyWhitening_s",@"NvCaptureBeautyReddening_s",@"NvCaptureBeautyFilter1_s",@"NvCaptureBeautySharpen1_s"];
}
+ (NSArray *)getBeautifulSkinFxNameArray:(BOOL)matte isContentAI:(BOOL)isContentAI{
    if (isContentAI) {
        if([NvBaseUtils enableAIBeauty]) {
            return matte ? @[@"",@"",@"Beauty Strength",@"Advanced Beauty Type Zero",@"Advanced Beauty Type One",@"Advanced Beauty Type Two",@"Advanced Beauty Type Three",@"none", @"Beauty Whitening",@"Shiny", @"Beauty Reddening",@"ColorCorrect",@"Default Sharpen Enabled" ] : @[@"",@"",@"Beauty Strength",@"Advanced Beauty Type Zero",@"Advanced Beauty Type One",@"Advanced Beauty Type Two",@"Advanced Beauty Type Three",@"none", @"Beauty Whitening", @"Beauty Reddening",@"ColorCorrect",@"Default Sharpen Enabled" ];
        }
        return matte ? @[@"",@"",@"Beauty Strength",@"Advanced Beauty Type Zero",@"Advanced Beauty Type One",@"Advanced Beauty Type Two",@"none", @"Beauty Whitening",@"Shiny", @"Beauty Reddening",@"ColorCorrect",@"Default Sharpen Enabled" ] : @[@"",@"",@"Beauty Strength",@"Advanced Beauty Type Zero",@"Advanced Beauty Type One",@"Advanced Beauty Type Two",@"none", @"Beauty Whitening", @"Beauty Reddening",@"ColorCorrect",@"Default Sharpen Enabled" ];
    }
    if([NvBaseUtils enableAIBeauty]) {
        return matte ? @[@"",@"",@"Strength",@"Strength",@"Strength",@"Strength",@"Strength",@"", @"Whitening",@"Shiny", @"Reddening",@"ColorCorrect",@"Default Sharpen Enabled"] : @[@"",@"",@"Strength",@"Strength",@"Strength",@"Strength",@"Strength",@"", @"Whitening", @"Reddening",@"ColorCorrect",@"Default Sharpen Enabled"] ;
    }
    
    return matte ? @[@"",@"",@"Strength",@"Strength",@"Strength",@"Strength",@"", @"Whitening",@"Shiny", @"Reddening",@"ColorCorrect",@"Default Sharpen Enabled"] : @[@"",@"",@"Strength",@"Strength",@"Strength",@"Strength",@"", @"Whitening", @"Reddening",@"ColorCorrect",@"Default Sharpen Enabled"] ;
}

#pragma mark - 美型数据 Beauty type data
+ (NSArray *)getShapeTitleArray:(BOOL)containAI {
    return containAI ? @[NvLocalString(@"NarrowFace", @"窄脸"),NvLocalString(@"SmallFace", @"小脸"),NvLocalString(@"Slim Cheeks", @"瘦脸"),NvLocalString(@"Forhead", @"额头"),NvLocalString(@"Jaw", @"下巴"),NvLocalString(@"interval", @"间隔"), NvLocalString(@"Eye-Capture", @"大眼"),NvLocalString(@"Canthus", @"眼角"),NvLocalString(@"interval", @"间隔"), NvLocalString(@"Slim Nose", @"瘦鼻"),NvLocalString(@"High Nose", @"长鼻"),NvLocalString(@"interval", @"间隔"), NvLocalString(@"Mouth-Capture", @"嘴型"),NvLocalString(@"Corners of The Mouth", @"嘴角")] : @[NvLocalString(@"Slim Cheeks", @"瘦脸"), NvLocalString(@"Eye-Capture", @"大眼"), NvLocalString(@"Jaw", @"下巴"), NvLocalString(@"Forhead", @"额头"), NvLocalString(@"Slim Nose", @"瘦鼻"), NvLocalString(@"Mouth-Capture", @"嘴型")];
}

+ (NSArray *)getShapeCoverArray:(BOOL)containAI  {
    return containAI ? @[@"NvCaptureBeautyTypeNarrowFace",@"NvCaptureBeautyTypeSmallFace",@"NvCaptureBeautyTypeFace",@"NvCaptureBeautyTypeForehead",@"NvCaptureBeautyTypeChin", @"", @"NvCaptureBeautyTypeEye",  @"NvCaptureBeautyTypeCanthus", @"", @"NvCaptureBeautyTypeNose",@"NvCaptureBeautyTypeProboscis",@"", @"NvCaptureBeautyTypeMouth",   @"NvCaptureBeautyTypeMouthCorner"] : @[@"NvCaptureBeautyTypeFace", @"NvCaptureBeautyTypeEye", @"NvCaptureBeautyTypeChin", @"NvCaptureBeautyTypeForehead", @"NvCaptureBeautyTypeNose", @"NvCaptureBeautyTypeMouth"];
}

+ (NSArray *)getShapeSelectedCoverArray:(BOOL)containAI  {
    return containAI ? @[@"NvCaptureBeautyTypeNarrowFace_s",@"NvCaptureBeautyTypeSmallFace_s",@"NvCaptureBeautyTypeFace_s",@"NvCaptureBeautyTypeForehead_s", @"NvCaptureBeautyTypeChin_s",@"",@"NvCaptureBeautyTypeEye_s", @"NvCaptureBeautyTypeCanthus_s", @"",  @"NvCaptureBeautyTypeNose_s",@"NvCaptureBeautyTypeProboscis_s",@"", @"NvCaptureBeautyTypeMouth_s",    @"NvCaptureBeautyTypeMouthCorner_s"] : @[@"NvCaptureBeautyTypeFace_s", @"NvCaptureBeautyTypeEye_s", @"NvCaptureBeautyTypeChin_s", @"NvCaptureBeautyTypeForehead_s", @"NvCaptureBeautyTypeNose_s", @"NvCaptureBeautyTypeMouth_s"];
}

+ (NSArray *)getShapeFxNameArray  {
    return @[@"Face Mesh Face Width Custom Package Id",@"Face Mesh Face Length Custom Package Id",@"Face Mesh Face Size Custom Package Id", @"Face Mesh Forehead Height Custom Package Id", @"Face Mesh Chin Length Custom Package Id",@"", @"Face Mesh Eye Size Custom Package Id",@"Face Mesh Eye Corner Stretch Custom Package Id", @"", @"Face Mesh Nose Width Custom Package Id",@"Face Mesh Nose Length Custom Package Id",@"", @"Face Mesh Mouth Size Custom Package Id",  @"Face Mesh Mouth Corner Lift Custom Package Id"];
}

+ (NSMutableArray *)getShapePackagePaths {
    NSArray *packageArr = @[@"96550C89-A5B8-42F0-9865-E07263D0B20C.3.facemesh",@"B85D1520-C60F-4B24-A7B7-6FEB0E737F15.3.facemesh",@"63BD3F32-D01B-4755-92D5-0DE361E4045A.3.facemesh",@"A351D77A-740D-4A39-B0EA-393643159D99.4.facemesh",@"FF2D36C5-6C91-4750-9648-BD119967FE66.3.facemesh",@"",@"71C4CF51-09D7-4CB0-9C24-5DE9375220AE.3.facemesh",@"B0B7A240-48B9-4983-B2C8-690FFA7211EB.2.facemesh",@"",@"8D676A5F-73BD-472B-9312-B6E1EF313A4C.3.facemesh",@"3632E2FF-8760-4D90-A2B6-FFF09C117F5D.3.facemesh",@"",@"A80CC861-A773-4B8F-9CFA-EE63DB23EEC2.3.facemesh",@"CD69D158-9023-4042-AEAD-F8E9602FADE9.3.facemesh"];
    NSMutableArray *packagePaths = [NSMutableArray array];
    NSString *shapePath = [[NSBundle mainBundle] pathForResource:@"beautyShapeData" ofType:@"bundle"];
    [packageArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *str = (NSString *)obj;
        if (str.length > 0) {
            [packagePaths addObject:[shapePath stringByAppendingPathComponent:obj]];
        }else {
            [packagePaths addObject:obj];
        }
        
    }];
    return packagePaths;
}

+ (NSArray *)getShapeDegreeNameArray:(BOOL)containAI {
    return containAI ? @[@"Face Mesh Face Width Degree",@"Face Mesh Face Length Degree",@"Face Mesh Face Size Degree",@"Forehead Height Warp Degree",@"Face Mesh Chin Length Degree",@"",@"Face Mesh Eye Size Degree",@"Face Mesh Eye Corner Stretch Degree",@"",@"Face Mesh Nose Width Degree",@"Face Mesh Nose Length Degree",@"",@"Face Mesh Mouth Size Degree",@"Face Mesh Mouth Corner Lift Degree"] : @[@"Cheek Thinning", @"Eye Enlarging", @"Intensity Chin", @"Intensity Forhead", @"Intensity Nose", @"Intensity Mouth"];
}


#pragma mark - 微整形数据 microshaping data
+ (NSArray *)getMicroShapeTitleArray {
    return @[NvLocalString(@"Small Head", @"缩头"),
             NvLocalString(@"Cheekbones", @"颧骨"),
             NvLocalString(@"Mandibular-Capture", @"下颌"),
             NvLocalString(@"temple", @"太阳穴"),
             NvLocalString(@"Nasolabial fold", @"法令纹"),
             NvLocalString(@"Dark under-eye circles", @"黑眼圈"),
             NvLocalString(@"Bright eye", @"亮眼"),
             NvLocalString(@"Beautiful teeth", @"美牙"),
             NvLocalString(@"Eye Distance", @"眼距"),
             NvLocalString(@"Eye Angle", @"眼角度"),
             NvLocalString(@"Eye Arc", @"眼弧度"),
             NvLocalString(@"Eye Width", @"眼宽度"),
             NvLocalString(@"Eye Height", @"眼高度"),
             NvLocalString(@"Eye Y Offset", @"眼上下"),
             NvLocalString(@"Philtrum", @"人中"),
             NvLocalString(@"Wide Nose Bridge", @"宽鼻梁"),
             NvLocalString(@"Nose Head Width", @"鼻头"),
             NvLocalString(@"Eyebrow Angle", @"眉角度"),
             NvLocalString(@"Eyebrow Thickness", @"眉粗细"),
             NvLocalString(@"Eyebrow X Offset", @"眉间距"),
             NvLocalString(@"Eyebrow Y Offset", @"眉上下")];
}

+ (NSArray *)getMicroShapeCoverArray {
    return @[@"NvCaptureBeautyTypeShrinkHead",
             @"NvCaptureBeautyTypeZygomatic",
             @"NvCaptureBeautyTypeMandibular",
             @"NvCaptureBeautyTypeTemple",
             @"legal_pattern_unselected",
             @"dark_under-eye_circles_unselected" ,
             @"bright_eye_unselected" ,
             @"beautiful_teeth_unselected",
             @"EyeDistanceWarpUnselected",
             @"EyeAngleWarpUnselected",
             @"eye_arc_unselected",
             @"eye_width_unselected",
             @"eye_height_unselected",
             @"eye_Y_offset_unselected",
             @"PhiltrumLengthWarpUnselected",
             @"NoseBridgeWidthWarpUnselected",
             @"nose_head_width_unselected",
             @"eyebrow_angle_unselected",
             @"eyebrow_thickness_unselected",
             @"eyebrow_X_offset_unselected",
             @"eyebrow_Y_offset_unselected"];
}

+ (NSArray *)getMicroShapeSelectedCoverArray {
    return @[@"NvCaptureBeautyTypeShrinkHead_s",
             @"NvCaptureBeautyTypeZygomatic_s",
             @"NvCaptureBeautyTypeMandibular_s",
             @"NvCaptureBeautyTypeTemple_s",
             @"legal_pattern_selected",
             @"dark_under-eye_circles_selected" ,
             @"bright_eye_selected" ,
             @"beautiful_teeth_selected",
             @"EyeDistanceWarpSelected",
             @"EyeAngleWarpSelected",
             
             @"eye_arc_selected",
             @"eye_width_selected",
             @"eye_height_selected",
             @"eye_Y_offset_selected",
             @"PhiltrumLengthWarpSelected",
             @"NoseBridgeWidthWarpSelected",
             @"nose_head_width_selected",
             @"eyebrow_angle_selected",
             @"eyebrow_thickness_selected",
             @"eyebrow_X_offset_selected",
             @"eyebrow_Y_offset_selected"];
}

+ (NSArray *)getMicroShapeFxNameArray {
    return @[@"Warp Head Size Custom Package Id",
             @"Face Mesh Malar Width Custom Package Id",
             @"Face Mesh Jaw Width Custom Package Id",
             @"Face Mesh Temple Width Custom Package Id",
             @"",
             @"",
             @"",
             @"",
             @"Face Mesh Eye Distance Custom Package Id",
             @"Face Mesh Eye Angle Custom Package Id",
             @"Face Mesh Eye Arc Custom Package Id",
             @"Face Mesh Eye Width Custom Package Id",
             @"Face Mesh Eye Height Custom Package Id",
             @"Face Mesh Eye Y Offset Custom Package Id",
             @"Face Mesh Philtrum Length Custom Package Id",
             @"Face Mesh Nose Bridge Width Custom Package Id",
             @"Face Mesh Nose Head Width Custom Package Id",
             @"Face Mesh Eyebrow Angle Custom Package Id",
             @"Face Mesh Eyebrow Thickness Custom Package Id",
             @"Face Mesh Eyebrow X Offset Custom Package Id",
             @"Face Mesh Eyebrow Y Offset Custom Package Id"];
}

+ (NSArray *)getMicroShapeDegreeNameArray {
    return @[@"Head Size Warp Degree",@"Face Mesh Malar Width Degree",
             @"Face Mesh Jaw Width Degree",
             @"Face Mesh Temple Width Degree",
             @"Advanced Beauty Remove Nasolabial Folds Intensity",
             @"Advanced Beauty Remove Dark Circles Intensity",
             @"Advanced Beauty Brighten Eyes Intensity",
             @"Advanced Beauty Whiten Teeth Intensity",
             @"Face Mesh Eye Distance Degree",
             @"Face Mesh Eye Angle Degree",
             @"Face Mesh Eye Arc Degree",
             @"Face Mesh Eye Width Degree",
             @"Face Mesh Eye Height Degree",
             @"Face Mesh Eye Y Offset Degree",
             @"Face Mesh Philtrum Length Degree",
             @"Face Mesh Nose Bridge Width Degree",
             @"Face Mesh Nose Head Width Degree",
             @"Face Mesh Eyebrow Angle Degree",
             @"Face Mesh Eyebrow Thickness Degree",
             @"Face Mesh Eyebrow X Offset Degree",
             @"Face Mesh Eyebrow Y Offset Degree"];
}

+ (NSMutableArray *)getMicroShapePackagePaths {
    NSArray *packageArr = @[
        @"316E3641-98BA-4E07-958E-9ED7D7F75E97.2.warp",
        @"C1C83B8B-8086-49AC-8462-209E429C9B7A.3.facemesh",
        @"E903C455-8E23-4539-9195-816009AFE06A.3.facemesh",
        @"E4790833-BB9D-4EFC-86DF-D943BDC48FA4.3.facemesh",
        @"",
        @"",
        @"" ,
        @"",
        @"80329F14-8BDB-48D1-B30B-89A33438C481.4.facemesh",
        @"54B2B9B4-5A7A-484C-B602-39A4730115A0.4.facemesh",
        @"BF71EA3E-E39E-4EFD-A30E-161C3D9E454D.4.facemesh",
        @"0605A846-200E-443F-B2FF-FE8339C9E571.facemesh",
        @"46B1D78F-DF5D-455A-9F97-C01B6405718F.4.facemesh",
        @"57C0BDDF-E08B-48F0-95FF-7F5171A9E6DF.4.facemesh",
        @"37552044-E743-4A60-AC6E-7AADBA1E5B3B.3.facemesh",
        @"23A40970-CE6F-4684-AF57-F78A0CBB53D1.3.facemesh",
        @"44E11F37-A4E5-44B5-8915-CA42B84F9F09.2.facemesh",
        @"CC86C182-62D7-4F1D-AE9D-F5E4E99977A5.2.facemesh",
        @"C2045DCA-D8C5-4C50-B942-69F749E32E93.2.facemesh",
        @"F77B5F0E-AF43-45DB-96BB-62419B9CECA8.2.facemesh",
        @"90C09073-225B-461D-8645-73CE7825BB33.2.facemesh"];
    NSMutableArray *packagePaths = [NSMutableArray array];
    NSString *microShapePath = [[NSBundle mainBundle] pathForResource:@"beautyShapeData" ofType:@"bundle"];
    [packageArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *str = (NSString *)obj;
        if (str.length > 0) {
            [packagePaths addObject:[microShapePath stringByAppendingPathComponent:obj]];
        }else {
            [packagePaths addObject:obj];
        }
    }];
    return packagePaths;
}

+ (NSMutableArray *)getShapeTestData{
    NSMutableArray *testArray = [NSMutableArray array];
    NSString *testBeauty = Beauty_Type_Path;
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:testBeauty]) {
        [fm createDirectoryAtPath:testBeauty withIntermediateDirectories:true attributes:nil error:nil];
    }
    NSArray *contents = [fm contentsOfDirectoryAtPath:testBeauty error:nil];
    
    NSString *tempString = @"";
    for (NSString *string in contents) {
        NSString *path = [testBeauty stringByAppendingPathComponent:string];
        NSArray *dataArray = [fm contentsOfDirectoryAtPath:path error:nil];
        NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc]init];
        [mutableDictionary setValue:[NSNumber numberWithBool:NO] forKey:@"selected"];
        [mutableDictionary setValue:[NSNumber numberWithBool:YES] forKey:@"isOperation"];
        [mutableDictionary setValue:[NSNumber numberWithBool:NO] forKey:@"isBeauty"];
        [mutableDictionary setValue:[NSNumber numberWithInt:1] forKey:@"type"];
        [mutableDictionary setValue:[NSNumber numberWithFloat:0] forKey:@"value"];
        [mutableDictionary setValue:[NSNumber numberWithFloat:0] forKey:@"defaultValue"];

        for (NSString *string_1 in dataArray) {
            if ([string_1 hasSuffix:@"json"]) {
                tempString = [path stringByAppendingPathComponent:string_1];
                NSData *data = [NSData dataWithContentsOfFile:tempString];
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                if (dict[@"fxId"]) {
                    [mutableDictionary setValue:dict[@"fxId"] forKey:@"fxName"];
                }
                if (dict[@"fxName"]) {
                    [mutableDictionary setValue:dict[@"fxName"] forKey:@"degreeName"];
                }
                if (dict[@"name"]) {
                    [mutableDictionary setValue:dict[@"name"] forKey:@"name"];
                }
                if (dict[@"packageId"]) {
                    [mutableDictionary setValue:dict[@"packageId"] forKey:@"uuid"];
                }
            }else if ([string_1 hasSuffix:@"facemesh"]){
                tempString = [path stringByAppendingPathComponent:string_1];
                [mutableDictionary setValue:tempString forKey:@"packageUrl"];
            }
        }
        [testArray addObject:mutableDictionary];
    }
    return testArray;
}

+ (NSMutableArray *)getMicroShapeTestData{
    NSMutableArray *testArray = [NSMutableArray array];
    NSString *testBeauty = Beauty_Microshaping_Path;
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:testBeauty]) {
        [fm createDirectoryAtPath:testBeauty withIntermediateDirectories:true attributes:nil error:nil];
    }
    NSArray *contents = [fm contentsOfDirectoryAtPath:testBeauty error:nil];
    
    NSString *tempString = @"";
    for (NSString *string in contents) {
        NSString *path = [testBeauty stringByAppendingPathComponent:string];
        NSArray *dataArray = [fm contentsOfDirectoryAtPath:path error:nil];
        NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc]init];
        [mutableDictionary setValue:[NSNumber numberWithBool:NO] forKey:@"selected"];
        [mutableDictionary setValue:[NSNumber numberWithBool:YES] forKey:@"isOperation"];
        [mutableDictionary setValue:[NSNumber numberWithBool:NO] forKey:@"isBeauty"];
        [mutableDictionary setValue:[NSNumber numberWithInt:2] forKey:@"type"];
        [mutableDictionary setValue:[NSNumber numberWithFloat:0] forKey:@"value"];
        [mutableDictionary setValue:[NSNumber numberWithFloat:0] forKey:@"defaultValue"];

        for (NSString *string_1 in dataArray) {
            if ([string_1 hasSuffix:@"json"]) {
                tempString = [path stringByAppendingPathComponent:string_1];
                NSData *data = [NSData dataWithContentsOfFile:tempString];
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                if (dict[@"fxId"]) {
                    [mutableDictionary setValue:dict[@"fxId"] forKey:@"fxName"];
                }
                if (dict[@"fxName"]) {
                    [mutableDictionary setValue:dict[@"fxName"] forKey:@"degreeName"];
                }
                if (dict[@"name"]) {
                    [mutableDictionary setValue:dict[@"name"] forKey:@"name"];
                }
                if (dict[@"packageId"]) {
                    [mutableDictionary setValue:dict[@"packageId"] forKey:@"uuid"];
                }
            }else if ([string_1 hasSuffix:@"facemesh"]){
                tempString = [path stringByAppendingPathComponent:string_1];
                [mutableDictionary setValue:tempString forKey:@"packageUrl"];
            }
        }
        [testArray addObject:mutableDictionary];
    }
    
    return testArray;
}

@end
