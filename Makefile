CFLAGS  ?= -O2 -march=native

GNATMAKE = gprbuild -dm -p
GNATCLEAN = gprclean -q
GNATINSTALL = gprinstall

.PHONY: all debug clean

all:
	$(GNATMAKE) -P tools/weechat_emoji.gpr -cargs $(CFLAGS)

debug:
	$(GNATMAKE) -P tools/weechat_emoji.gpr -XMode=debug -cargs $(CFLAGS)

clean:
	$(GNATCLEAN) -P tools/weechat_emoji.gpr
	rm -rf build

install:
	install --mode=644 --preserve-timestamps --strip ./build/lib/ada-emoji.so ~/.weechat/plugins/

uninstall:
	rm ~/.weechat/plugins/ada-emoji.so
