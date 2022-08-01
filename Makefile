.PHONY: all clean install uninstall

all:
	alr build --validation

clean:
	alr clean
	rm -rf build

install:
	install --mode=644 --preserve-timestamps --strip ./build/lib/ada-emoji.so ~/.weechat/plugins/

uninstall:
	rm ~/.weechat/plugins/ada-emoji.so
