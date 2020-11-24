# Jetson TX2 安装指南
这篇必须用中文写，因为遇到的坑实在是太多了。

# 背景介绍及目标
鉴于TX2长期不使用，而且有两块笔记本硬盘闲置，之前一直有计划将它作为NAS使用。尝试了其板载的SATA接口，可以拖动3.5英寸硬盘。开发板有具备一个`PCI-e x4`接口，我们可以通过一块扩展卡另外扩展出4个SATA口用于接入更多的硬盘。TX2本身具备视频编解码能力以及一些推理能力，因此在视频转码方面有很大的优势。

目标：构建一个四盘位的网络存储空间，并在其上运行视频转码与AI推理。

# 硬件、软件情况
硬件: 4盘位ITX机箱, 电源转接线，Jetson TX2 Developer Kit, USB-WiFi card, 用于刷机的Linux桌面台式机

软件: Jetpack 4.4 DP, Ubuntu 18.04.2 LTS Live ISO

# 操作步骤
由于遇到了许多坑，在搭建过程中需要多次调整目标。下面逐条列举出来。

## 购买机箱
机箱种类繁多，收集了20多种，根据体积和价格选了一款4盘位机箱。估计配套电源不容易购买，因此在买机箱的时候购买了带电源的那一款。
## 购买扩展卡
PCI-e转SATA有两大类别，一种是带开关可以选RAID模式，一种不带开关，考虑到之前树莓派+1硬盘盒做过存储，以及对于RAID与TX2会不会有兼容性问题，就不选带RAID功能的，选择了Marvel 9225芯片的转接卡。
## 安装TX2进入机箱
机箱的做工不是很好，拆卸不是很顺滑，不过基本功能都有：扩展卡槽、电源开关及LED灯。机箱电源配套的是引出ATX-24Pin, CPU-4Pin, 2xSATA-4Pin. 机箱前置面板引出1xUSB3.0, 1xUSB2.0, 2.54mm(PWR_BTN, RST_BTN, PWR_LED+/-, LAN_LED1/2/3)。因为TX2带风扇高度也不到60mm，塞入机箱没有问题，只不过机箱上部被硬盘位置阻挡，放入开发板的时候空间小不容易操作。TX2有对应的接口可以接入PWR_BTN, RST_BTN, PWR_LED。转接卡也在此时插入。
## 启动系统验证是否可运行
插入TX2自带电源，插入USB键盘鼠标接收器，启动系统，前面板的电源按钮与亮灯可用，系统正常启动。转接卡通过`lspci`命令可以识别。
## 安装SATA线缆
### 坑：SATA数据线缆过硬，难以在狭小的空间内走线。
数据线与扩展卡距离较近，线缆长度过长，需要额外空间绕行。因为线缆比较硬，走线的时候还被机箱划了一下。
### 坑：SATA电源线缆的4Pin公头无法插入机箱的4Pin母座
换了另一个才勉强插入。这应该是制造的时候没注意公差。之前组装电脑的那些光驱连接线就没这种问题。
### 坑：电源启动
因为我不是用的x86主板，因此电源引出的24Pin是空置的，电源无法启动。使用折了的曲别针短接 P16(PS_ON) & P17(GND)可以启动。由于此时仅测试硬盘，没有启动系统，手持一二十秒等硬盘响声不大了之后拿出断电。
## 系统+硬盘整机测试
先给TX2上电开机，然后曲别针使用，硬盘启动。由于手持不稳，抖动断电，调整姿势后重新上电，TX2可认出硬盘。测试硬盘热插拔需要用`hdparm`，而TX2不带，就得联网下载。
### 坑：转接卡发热
在加电之后，即使硬盘不动，转接卡的发热量也是很大的，虽然有散热片，但触摸之后感觉得有60度，温度相当高。
### 坑：WiFi从热点转回客户端模式
之前有计划将TX2变为热点以提供802.11ac网络覆盖，通过一番设置变为了热点模式。断开热点，但是发现无法扫描到任何网络。网络搜索大部分解决方案都是hostapd做热点，但我在/etc找了一圈都没有hostapd与netplan相关文件。换了一个方法去搜如何在TX2当中创建热点，最后找到了开发者论坛当中的页面，通过更改/etc/modprobe.d/bcmdhd.conf当中的`options bcmdhd op_mode=2`可以启用热点，那么删掉这一行就能恢复了。（坑：搜索这个页面的时候开发者论坛无法正常加载）
## 备份数据
原有TX2需要备份数据，我就最简单的将home文件夹放在了一个位置，由于剩余空间不足，无法打包。外接一个USB硬盘将打包后的数据存放。
### 坑：TX2不识别硬盘分区
我的移动硬盘EFI分区格式，TX2的gnome-disks不认识分区列出是个空盘而fdisk可以看到分区表，十分诡异，测试通过转接卡的一块SATA硬盘也是这样的问题。最后找了另外一块移动硬盘拷过去了。

更新：在安装了 partprobe 之后，执行 `sudo partprobe -s /dev/sda` 强制重新检测分区，这样可以看到/dev/sda* 这样的分区了

## 购买电源线
由于短接电源不是长久之计，鉴于已经跑通系统，之后要购买电源短接线才行。考虑到现有供电TX2和硬盘是分开的，而TX2开发板的说明当中提到VCC_IN可以为5.5~19.5V，因此使用DC 12V直接供电应该也可以。通过搜索发现TX2的接头大小为5.5x2.5。这样一来具备电源短接和DC插头输出的就两家了，找了一家购买。顺带考虑到以后机箱风扇散热与转接卡散热，遂购买转接头。我以为是显卡转接线就行，没想到所谓的显卡接口是PH2.0而TX2板载小风扇是1.25mm的，还是不兼容。电源线是24Pin转4个DC和一个开关。我本来觉得4个DC已经很多了没必要，结果发现现有设备还是需要的：TX2一个，NUC一个，Edison一个，这都是可以直接插上去的。而诺基亚的无线充电板也是12V，只不过接口是个小的口没法直接插上。DC 12V在小功率电器上面用途很广泛啊，不少LED灯带也是12V的，怪不得之后ATX电源规范建议用10Pin就够了。
## 刷机之前
### 坑：SDKManager仅支持Linux
因为家用设备都是Windows的，因此想在Surface上开一个虚拟机。使用Hyper-V，启动之前做的Live系统，发现GUI界面偶尔显示不全，无法继续。后查明是内存不足导致的。换到桌面机器内存足够了，可以进入Live。但在安装SDKManager的时候它有一个依赖库libXt11缺少，系统没有，想着是源有问题，然而没人提供这个包在哪个源里边。遂进行系统安装。
### 坑：nvidia链接跳转
由于是在中文，链接会自动跳转到.cn域名下，该域名不知是证书不对还是内容没有镜像，导致deb包下载下来只有42字节，而非正常的89M。一番折腾之后，下载好了，在虚拟机系统装好的环境下安装，可以自动补齐依赖库。打开sdkm，在第三步查看License的时候有Oops，同样因为跳转原有无法连接获取License，自然也没法进行下一步了。查看论坛之后可以得知这一步是在下某个json（从而得知TX2依赖包都有哪些），而该链接会跳转，跳转之后的结果就是访问被拒绝。无奈，只能通过一番折腾之后，在公司电脑上先保存那些依赖包然后传回Surface的Download文件夹，然后因为HyperV是自己装的系统，不具备共享文件夹的能力，因此用scp传到台式机的VM内，发现速度只有100K，遂切换为scp到台式机WSL下然后scp到VM内。

数据转移流程：公司电脑--->Surface--->台式机WSL--->台式机VM/台式机分区

参考链接：[问题可能难以解决](https://askubuntu.com/questions/35223/syntax-for-socks-proxy-in-apt-conf)，[就是方法特别难找](https://serverfault.com/questions/482318/apt-get-proxy-for-specific-repos)
### 坑：SDKManager需要35G用于编译TX2的环境
SDKM里边只提到了6G下载和5G的环境编译，完全没有提到35G这么大。这个数据是通过查看SDKM的log发现的，查看log会看到需要35xxxMB而实际空闲34xxxMB。这个相对来说还容易一些，就是虚拟机硬盘扩容一下。考虑到Ubuntu自身占10G，因此需要一块至少50G的硬盘。

更新：50G不够，需要60G。软件包5G，此时剩余空间40G可以进行编译镜像。编译镜像完成后刷机失败，此时有18G占用，剩余29G无法进行下次刷机操作（小于35G）
### 坑：Hyper-V不支持PCI Passthrough
使用SDKM+离线之后的文件包们，进行编译与部署。当编译完TX2的镜像之后，部署出现了问题：SDKM需要通过PCI检测TX2的存在，TX2通过microUSB接口暴露一个网卡一个串口和L4TREADME分区，而缺少PCI Passthrough直接导致检测不到，刷机失败。需要更换为物理机。
### 坑：SDKManager需要GUI界面
恰好有一台物理机，是NUC，因为没有Windows授权而使用了Ubuntu，但当时考虑到该设备以后作为管理设备存在，没有部署桌面系统，遂无法安装。

在发愁怎么才能有图形界面Linux的时候，以及前面遇到硬盘分区不识别的坑，在Windows下查看了分区信息，发现了台式机在当时为了维护而留下的一个Ubuntu ISO Live系统，前面说了依赖包无法安装是缺少库，而这个库在Live环境下找不到。想到了之前我用Live环境通过testdisk来拯救分区的情况，那时候testdisk记得就是apt-get install就可以。于是在中文不存在引擎上搜索"how to install testdisk in ubuntu live"，第一条就指向了Ubuntu的help，里边说要先enable the Universe repository，嗯，终于迈出了一步。
### 坑：HDMI输出
SDKManager需要1440x900的分辨率，太小的话则界面显示错乱。而NVIDIA显卡在Live环境下默认只有基本驱动1024x768，于是需要切换到Intel集成显卡来达到1080P的输出。
### 坑：WiFi6不支持
买了Intel AX200的无线网卡用于网络接入，而18.04没有带该设备的驱动，无法上网只能通过之前USB网卡来解决。
### 坑：编译TX2 Linux镜像需要ext文件系统
物理机内的ISO启动挂载本地NTFS，编译Linux的话权限不行，就得特地开辟一块空间然后mount上来。
```
truncate -s 50G sdkm.img
mkfs.ext4 sdkm.img
mount -o loop sdkm.img /mnt
```
然后将编译位置设置为/mnt即可。

## 安装Jetpack
### 注意：默认版型是AGX Xavier
需要手动切换为TX2，否则会在后面报一个包的HASH错误。因为Xavier有DLA而TX2没有DLA，他们在TRT这个包上面是不同的。

大概在10分钟的时候如果还没有做好image会有提示是否要等待，我看创建镜像的进度条在95%了并且还一直前进，就继续等。毕竟读写的是机械硬盘并且是我用文件挂载的方式进来的内容。20分钟过去了99.6%，看日志是在解包各种deb，一个一个做的都很慢，这一点上机械硬盘不如固态硬盘。

### 坑：自动刷机无效
制作好镜像之后开始选择刷机方式，连接USB线之后物理机可以看到设备。自动刷机填写账户密码，可以连接但不知为何还是等待超时之后报错。看日志是command finished successfully + Failed to use 'Automatic setup'。不过还是用手动刷机好了，先关机，按住rec之后在开机，等个几秒松开rec。回到软件上点"Flash"开始刷机。

### 注意：刷机之后的首次配置
在刷机之后TX2会重启，进入配置界面。由于我只有一台显示器，因此切换过去并接入鼠标键盘。幸好我有usb hub，可以把一个usb口扩展出来。然后发现终端显示的是A start job is running for End-user configuration after initial OEM installation。论坛里说的是按reset就行，果然好使。[cnblogs](https://www.cnblogs.com/harrymore/p/11643155.html)上有人说过类似的问题，而且说不定自动刷机无效也与这个有关。接下来就是安装各种SDK，比如CUDA,TRT,Multimedia等等。 安装CUDA过程中报错，看了log应该是tmp_NV_L4T_CUDA_TARGET_POST_INSTALL_COMP.sh运行出错了，原因跟前面一样，就是更新的时候链接跳转导致的错误。

### 坑：WiFi断线
因为用了USB-WiFi，不确定为什么就断线了，需要SDKM retry才行。

### 坑：远程桌面连接
之前版本的TX2远程桌面总是崩掉，打不开，用xrdp也不行，尝试安装mate-core也解决不了。开发者论坛上面可以看看：https://forums.developer.nvidia.com/t/l4t-jetpack-4-4-dp-desktop-sharing-and-bluetooth-bugs/127745/6

`sudo vi /usr/share/glib-2.0/schemas/org.gnome.Vino.gschema.xml`

增加下面一段
```
    <key name='enabled' type='b'>
      <summary>Enable remote access to the desktop</summary>
      <description>
        If true, allows remote access to the desktop via the RFB
        protocol. Users on remote machines may then connect to the
        desktop using a VNC viewer.
      </description>
      <default>false</default>
    </key>
```
然后
`sudo glib-compile-schemas /usr/share/glib-2.0/schemas`
应用设置；

并执行
`gsettings set org.gnome.Vino require-encryption false`
关闭加密，否则会提示服务器端加密方法不匹配一类的错误。

最后执行`/usr/lib/vino/vino-server`常驻前台就可以进行远程连接了，设立为服务也不麻烦这里不再列出。

## 总结 & 想法
总算是设立完了！耗时10天的休闲时间，踩得坑真多。如果拥有网络、多显示器键鼠、大的工作台，足够容量的固态硬盘，3个小时搞定一点问题没有！

在干活当中发现NAS需要一套完整的数据方案，比如硬盘的RAID方式与系统软件的结合，用何种文件系统格式，外部数据如何通信等等。目前来说TX2不是专为设计的，再考虑到硬盘组成是非常杂乱的，因此还是考虑将这个设备先将就着用，每块硬盘存各自的数据。过几年可以上NAS之后，将所有数据迁移出去，这里只保存转换后的低码率视频与图片，文档也都是pdf

## TODO
替换电源，可以考虑12V单一制式。

