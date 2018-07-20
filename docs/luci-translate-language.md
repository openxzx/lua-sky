# Luci translate language

## Luci support more language, e.g English, Russia and chinese and so on

	make menuconfig

	Luci --> Modules --> Translations -->
	select language type, default auto for English

	make -j13 clean world

## Check /etc/config/luci

	vim /etc/config/luci

## Operated the Openwrt luci web, select differnt language

	System --> Language and Style --> language

## po files

	.po files can enable translation
	.po files can not find, but compiled successful you can look relevant ipk
	Changed feeds.conf's content for your package. e.g src-git luci http://github.com/XzxEmbedded/luci.git

	./script/feeds update -a
	./scrip/feeds install -a
	make -j13 clean world
