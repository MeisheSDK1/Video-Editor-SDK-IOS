//================================================================================
//
// (c) Copyright Meishe Co. Ltd, 2016. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    Dec 29. 2016
//   Author:        Meishe video team
//================================================================================
#pragma once

#import <Foundation/Foundation.h>
#import "NvsCommonDef.h"

/*! \if ENGLISH
 *  \brief Particle effect context
 *  The particle system is composed of several particle emitters and sub-emitters.
 *  The particle emitter emits particles over time, and the sub-emitter emits particles from the particles emitted by the particle emitter.
 *  \warning In the NvsParticleSystemContext class, all public APIs are used in the UI thread! ! !
 *  \else
 *  \brief 粒子特效上下文
 *  粒子系统的由若干粒子发生器和子粒子发生器构成。粒子发生器会随着时间推移不断发射出粒子，而子粒子发生器则会在粒子发生器发射出的粒子上面发射出粒子。
 *  \warning NvsParticleSystemContext类中，所有public API都在UI线程使用！！！
 *  \endif
 */
NVS_EXPORT @interface NvsParticleSystemContext : NSObject

- (void)setInternalContext:(void *)internalContext;

/*! \if ENGLISH
 *  \brief Set whether to enable the emitter.
 *  \param emitterName emitter name
 *  \param enable enable or disable, default mode is enable.
 *  \else
 *  \brief 设置粒子发生器是否开启
 *  \param emitterName 粒子发生器名字
 *  \param enable 是否启用粒子发生器，默认为开启
 *  \endif
 */
- (void)setEmitterEnabled:(NSString *)emitterName emitterEnable:(bool)enable;

/*! \if ENGLISH
 *  \brief Set the particle emitter's position.
 *  \param emitterName emitter name
 *  \param emitterPositionX particle emitter's X coordinate
 *  \param emitterPositionY particle emitter's Y coordinate
 *  \else
 *  \brief 设置粒子发生器位置
 *  \param emitterName 粒子发生器名字
 *  \param emitterPositionX 粒子发生器X坐标
 *  \param emitterPositionY 粒子发生器Y坐标
 *  \endif
 */
- (void)setEmitterPosition:(NSString *)emitterName emitterPositionX:(float)x emitterPositionY:(float)y;

/*! \if ENGLISH
 *  \brief Apend a path position to the particle emitter curve at the specified time point.
 *  \param emitterName emitter name
 *  \param curveTime time point
 *  \param emitterPositionX particle emitter's X coordinate
 *  \param emitterPositionY particle emitter's Y coordinate
 *  \else
 *  \brief 在指定时间点给粒子发射器曲线添加途径点
 *  \param emitterName 粒子发生器名字
 *  \param curveTime 时间点
 *  \param emitterPositionX 粒子发生器X坐标
 *  \param emitterPositionY 粒子发生器Y坐标
 *  \endif
 */
- (void)appendPositionToEmitterPositionCurve:(NSString *)emitterName curveTime:(float)time emitterPositionX:(float)x emitterPositionY:(float)y;

/*! \if ENGLISH
 *  \brief Set the rate of the particles emitted by the particle emitter.
 *  \param emitterName emitter name
 *  \param emitterGain emission rate gain
 *  \else
 *  \brief 设置粒子发生器发射粒子的速率
 *  \param emitterName 粒子发生器名字
 *  \param emitterGain 发射速率
 *  \endif
 */
- (void)setEmitterRateGain:(NSString *)emitterName emitterGain:(float)gain;

/*! \if ENGLISH
 *  \brief Set the size of the particles emitted by the particle emitter.
 *  \param emitterName emitter name
 *  \param emitterGain emission size gain
 *  \else
 *  \brief 设置粒子发生器发射粒子的大小
 *  \param emitterName 粒子发生器名字
 *  \param emitterGain 粒子大小增益
 *  \endif
 */
- (void)SetEmitterParticleSizeGain:(NSString *)emitterName emitterGain:(float)gain;

@end

