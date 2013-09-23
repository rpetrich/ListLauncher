THEOS_DEVICE_IP=192.168.0.100

TWEAK_NAME = ListLauncher
ListLauncher_FILES = Tweak.xm
ListLauncher_FRAMEWORKS = UIKit
ListLauncher_LIBRARIES = applist

# ListLauncher_CFLAGS = -L/opt/theos/lib
# ListLauncher_FILES= -L/opt/theos/lib/
# ListLauncher_OBJ_FILES= -L/opt/theos/lib
# ListLauncher_LDFLAGS = -L/opt/theos/lib
# ListLauncher_CFLAGS = -I../
# ListLauncher_LDFLAGS = -L../$(FW_OBJ_DIR)
# ADDITIONAL_LDFLAGS = -L/opt/theos/lib/
# ListLauncher_OBJCCFlAGS= -L/opt/theos/lib/

include /opt/theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	@install.exec "killall -9 SpringBoard"