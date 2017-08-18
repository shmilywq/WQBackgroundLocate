# WQBackgroundLocate
####这里提供一个后台连续定位功能的demo, 理想情况下,可以在后台一直获取定位信息.

###定位框架
由于系统原因，iOS不允许使用第三方定位，因此高德及百度地图SDK中的定位方法，本质上是对原生定位的二次封装。所以, 使用高德/百度/原生均能实现效果.项目示例使用的是高德
###具体步骤
* 需要在info.plist里添加 NSLocationAlwaysUsageDescription ，允许永久使用GPS的描述

![图片1](http://otqas4grw.bkt.clouddn.com/1502961595603.jpg)

* 配置后台定位

	依次执行：

	1. 左侧目录中选中工程名，开启 TARGETS->Capabilities->Background Modes

	2. 在 Background Modes中勾选 Location updates，如下图所示：
	
	![图片2](http://otqas4grw.bkt.clouddn.com/1503026718386.jpg)

* 关键代码

	1. 设置定位不允许被系统自动暂停
	
		```
		_locationManager.pausesLocationUpdatesAutomatically = NO;
		```
	2. 设置允许在后台定位 (只在iOS 9.0之后起作用)

		```
		_locationManager.allowsBackgroundLocationUpdates = YES;
		```
		
	注: 原生,高德,百度三个都有pausesLocationUpdatesAutomatically和allowsBackgroundLocationUpdates属性,按上述两步设置
	
####写在末尾 不足之处还请指正, 联系方式: wq012819@163.com
