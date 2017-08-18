//
//  WQBackgroundLocate.h
//  WQBackgroundLocateDemo
//
//  Created by shmily on 2017/8/10.
//  Copyright © 2017年 shmily. All rights reserved.
//

#ifndef WQBackgroundLocate_h
#define WQBackgroundLocate_h

#ifdef DEBUG//调试状态，打开LOG功能
#define WQLog(...) NSLog(__VA_ARGS__)
#else//发布状态，关闭LOG功能
#define WQLog(...)
#endif


#endif /* WQBackgroundLocate_h */

