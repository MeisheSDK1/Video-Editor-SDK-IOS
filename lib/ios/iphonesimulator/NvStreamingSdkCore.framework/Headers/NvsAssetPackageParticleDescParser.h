//================================================================================
//
// (c) Copyright Meishe Co. Ltd, 2017. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    Jan 23. 2017
//   Author:        Meishe video team
//================================================================================
#pragma once

#import <Foundation/Foundation.h>
#import "NvsCommonDef.h"

/*! \anchor PARTICLE_TYPE */
/*! \if ENGLISH
 *  @name Particle type
 *  \else
 *  @name 粒子类型
 *  \endif
 */
typedef enum
{
    NvsParticleType_Normal = 0,         //!< \if ENGLISH Particle effect without interaction. \else 没有交互的基本粒子类型 \endif
    NvsParticleType_Touch,              //!< \if ENGLISH Particle effect controlled by touch screen. \else 触摸屏幕进行交互的粒子类型 \endif
    NvsParticleType_Gesture,            //!< \if ENGLISH Particle effect controlled by gesture. \else 手势进行交互的粒子类型 \endif
    NvsParticleType_Eye,                //!< \if ENGLISH Particle effect controlled by eye. \else 眼睛进行交互的类型 \endif
    NvsParticleType_Mouth,              //!< \if ENGLISH Particle effect controlled by mouth. \else 嘴巴进行交互的粒子类型 \endif
} NvsParticleType;


/*! \anchor EMITTER_PLACE */
/*! \if ENGLISH
 *  @name the particle emitter position type
 *  \else
 *  @name 粒子发生器放置的位置类型
 *  \endif
 */
typedef enum
{
    NvsEmitterPlace_Left = 0,       //!< \if ENGLISH The particle emitter is on the left of the current position. \else 粒子发生器在当前部位的左边 \endif
    NvsEmitterPlace_Right,          //!< \if ENGLISH The particle emitter is on the right of the current position. \else 粒子发生器在当前部位的右边 \endif
    NvsEmitterPlace_Top,            //!< \if ENGLISH The particle emitter is above the current position. \else 粒子发生器在当前部位的上边 \endif
    NvsEmitterPlace_Bottom,         //!< \if ENGLISH The particle emitter is below the current position. \else 粒子发生器在当前部位的下边 \endif
    NvsEmitterPlace_Center          //!< \if ENGLISH The particle emitter is in the middle of the current position. \else 粒子发生器在当前部位的中间 \endif
} NvsEmitterPlace;



/*! \if ENGLISH
 *  \brief Particle effect package parsing class.
 *  \warning In the NvsAssetPackageParticleDescParser class, all public APIs are used in the UI thread! ! !
 *  \else
 *  \brief 粒子特效包解析类
 *  \warning NvsAssetPackageParticleDescParser类中，所有public API都在UI线程使用！！！
 *  \endif
 */
NVS_EXPORT @interface NvsAssetPackageParticleDescParser : NSObject


- (instancetype)initWithEffectDesc:(NSString *)desc;

/*! \if ENGLISH
 *  \brief Get particle type.
 *  \return Return the particle type.Please refer to [Particle type](@ref PARTICLE_TYPE).
 *  \else
 *  \brief 获取粒子类型。
 *  \return 返回粒子类型。请参见[粒子类型](@ref PARTICLE_TYPE)
 *  \endif
 */
- (NvsParticleType) getParticleType;

/*! \if ENGLISH
 *  \brief Get the count of particle partition.
 *  \return Return the count of partition
 *  \else
 *  \brief 获取粒子分片数量
 *  \return 返回分片数量
 *	\endif
 */
-(int) getParticlePartitionCount;

/*! \if ENGLISH
 *  \brief Get the position type of the particle emitter partition with the specified index value.
 *  \param partitionIndex partition index
 *  \return Return the position type
 *  \else
 *  \brief 获取指定索引值的分片粒子发射器的位置类型
 *  \param partitionIndex 分片索引值
 *  \return 返回位置类型
 *	\endif
 */
- (NvsEmitterPlace) getParticlePartitionPlace:(unsigned int)partitionIndex;

/*! \if ENGLISH
 *  \brief Get the name array of the particle emitter partition with the specified index value.
 *  \param partitionIndex partition index
 *  \return Return a array of a partition particle emitter name
 *  \else
 *  \brief 获取指定索引值的分片粒子发射器的名字数组
 *  \param partitionIndex 分片索引值
 *  \return 返回粒子发射器的名字数组
 *	\endif
 */
 - (NSArray *) getParticlePartitionEmitter:(unsigned int)partitionIndex;

/////////////////////////////////////////////////////////////////////////////////
//

/*! \if ENGLISH
 *  \brief Get the position type of the particle emitter at the left eye.Please refer to [Particle position type](@ref EMITTER_PLACE).
 *  \return Return the position type.
 *  \else
 *  \brief 获取左眼处的粒子发射器位置类型
 *  \return 返回位置类型。请参见[粒子位置类型](@ref EMITTER_PLACE)
 *	\endif
 */
- (NvsEmitterPlace) getLeftEyePlace;

/*! \if ENGLISH
 *  \brief Get a array of the particle emitter names at the left eye.
 *  \return Return a array of the particle emitter names
 *  \else
 *  \brief 获取左眼处的粒子发射器的名字数组
 *  \return 返回粒子发生器名字数组
 *	\endif
 */
- (NSArray *) getLeftEyeEmitter;

/*! \if ENGLISH
*  \brief Get the position type of the particle emitter at the right eye.Please refer to [Particle position type](@ref EMITTER_PLACE).
*  \return Return the position type.
 *  \else
 *  \brief 获取右眼处的粒子发射器位置类型
 *  \return 返回位置类型。请参见[粒子位置类型](@ref EMITTER_PLACE)
 *	\endif
 */
-(NvsEmitterPlace) getRightEyePlace;

/*! \if ENGLISH
 *  \brief Get a array of the particle emitter names at the right eye.
 *  \return Return a array of the particle emitter names
 *  \else
 *  \brief 获取右眼处的粒子发射器的名字数组
 *  \return 返回粒子发生器名字数组
 *	\endif
 */
-(NSArray *) getRightEyeEmitter;

@end

