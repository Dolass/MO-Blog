MoBlog简单博客程序
本程序仅作为MoAspEnginer的示例程序，只包含基本的博客功能

一、基本环境需求

本程序调试环境为Windows 2003+IIS6.0以及Windows 7+IIS7.5，IIS6及以上版本均可以正常运行；
请勿使用非IIS的web服务器调试，例如NetBox等；
请启用相关文件夹的写入权限，包括

/__file__	#博客附件目录
/Album		#相册目录
/Cache		#缓存目录，如果开启MO_CACHE选项
/Data		#数据库目录
/Images/Upload	#博客图片目录

二、帮助

管理地址：http://您的域名/?m=login&a=login
管理员：moblog 密码：moblog

帮助文档地址：http://www.9fn.net/help/

更新日志：http://www.9fn.net/update.html

三、声明

1、本程序作为MoAspEnginer的示例程序而作，程序细节部分未完全考虑，例如后台表单数据的验证等;前台页面的数据验证已做详细处理
2、本程序默认运行在根目录下，如需运行在子目录，请修改404.asp的配置项，例如，如果要运行在目录moblog下，则配置项如下

MO_APP_NAME = "App"	'随意的英文名字，建议使用字母和数字的组合
MO_ROOT = "/moblog/"	'default.asp所在的目录
MO_CORE = "/moblog/Mo/"	'核心所在的路径
MO_APP = "/moblog/App/"	'你的当前App所在的路径

同时，为了网站安全，建议修改App/Config/Mo.Conf.DB.asp中DB_Path的值，修改数据库的存放路径，数据库默认在Data目录下

3、本程序目前仅支持ACCESS数据库，MSSQL数据库尚未测试
4、核心变量必须是Mo，请勿修改为其他名字，即“Dim Mo : Set Mo = New MoAspEnginer : Mo.Run() : Set Mo = Nothing”这一句代码里面的Mo是固定的

四、联系交流
QQ群：MoBlog内部交流(127430216)