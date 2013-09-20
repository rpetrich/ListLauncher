THEOS_DEVICE_IP=192.168.0.100

include /opt/theos/makefiles/common.mk
WEAK_NAME = ListLauncher
ListLauncher_FILES = Tweak.xm
ListLauncher_FRAMEWORKS = UIKit
ListLauncher_LIBRARIES = applist, substrate

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	@install.exec "killall -9 SpringBoard"