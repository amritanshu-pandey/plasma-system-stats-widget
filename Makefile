ID := in.amritanshu.systemstats
DOMAIN := plasma_applet_$(ID)
VERSION := $(shell python3 -c 'import json; print(json.load(open("package/metadata.json"))["KPlugin"]["Version"])')
PLASMOID := build/system-stats-$(VERSION).plasmoid
QML := $(wildcard package/contents/ui/*.qml) package/contents/config/config.qml
PO := $(wildcard po/*.po)

.PHONY: plasmoid install uninstall lint pot update-po translations clean

plasmoid: translations
	mkdir -p build
	rm -f $(PLASMOID)
	cd package && zip -qr ../$(PLASMOID) .
	@echo "Built $(PLASMOID)"

install: translations
	kpackagetool6 -t Plasma/Applet -u package 2>/dev/null || kpackagetool6 -t Plasma/Applet -i package
	@echo "Restart Plasma to load the new version: systemctl --user restart plasma-plasmashell"

uninstall:
	kpackagetool6 -t Plasma/Applet -r $(ID)

lint:
	python3 scripts/lint.py $(QML)

pot:
	xgettext --from-code=UTF-8 --language=JavaScript --add-comments=i18n --add-location=file \
		--keyword= --keyword=i18n:1 --keyword=i18nc:1c,2 --keyword=i18np:1,2 --keyword=i18ncp:1c,2,3 \
		--package-name="System Stats" --package-version=$(VERSION) \
		--msgid-bugs-address=https://github.com/amritanshu-pandey/plasma-system-stats-widget/issues \
		--sort-by-file --output=po/$(DOMAIN).pot $(sort $(QML))

update-po: pot
	for po in $(PO); do msgmerge --quiet --update --backup=none $$po po/$(DOMAIN).pot; done

translations:
	for po in $(PO); do \
		lang=$$(basename $$po .po); \
		mkdir -p package/contents/locale/$$lang/LC_MESSAGES; \
		msgfmt --check --output-file=package/contents/locale/$$lang/LC_MESSAGES/$(DOMAIN).mo $$po; \
	done

clean:
	rm -rf build package/contents/locale
