//
//  NvsAIContext.h
//  NvsAIContext
//
//  Created by 董凌晓 on 2021/8/3.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NvsAIContext : NSObject

/*! \if ENGLISH
 *  \brief Verifies the SDK license. Note: This interface must be called before the NvsStreamingContext is initialized.
 *  \param sdkLicenseFilePath SDK license file path
 *  \return Returns BOOL value. YES indicates that the license verification is successful, and NO indicates that the verification fails.
 *  \else
 *  \brief 验证SDK授权文件。注意：授权文件接口必须在NvsAIContext初始化之前调用。
 *  \param sdkLicenseFilePath SDK授权文件路径
 *  \return 返回BOOL值。YES表示授权验证成功，NO则验证失败。
 *  \endif
*/
+ (BOOL)verifySdkLicenseFile:(NSString *)sdkLicenseFilePath;

/*! \endcond */

@end

