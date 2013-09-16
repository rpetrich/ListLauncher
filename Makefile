include /Users/zac/theos/makefiles/common.mk

TWEAK_NAME = ListLauncher
ListLauncher_FILES = Tweak.xm
ListLauncher_FRAMEWORKS = UIKit
ListLauncher_LIBRARIES = applist

include $(THEOS_MAKE_PATH)/tweak.mk

