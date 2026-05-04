APPNAME = test-dioxus

## CSS
TAILWIND_INPUT_CSS = ./resources/tailwind.input.css
TAILWIND_CSS = ./assets/css/tailwind.css
#TAILWIND_FROM_INPUT = $(TAILWIND_INPUT_CSS)
TAILWIND_FROM_INPUT =

## JS
CONTROLLER_JS = assets/js/controller.js
CONTROLLER_TS = assets/js/controller.ts
#JS_FROM_TS = $(CONTROLLER_JS)
JS_FROM_TS =

###
all: list

MAKEFILE_LIST = Makefile
# Self-documenting Makefile targets script from Stack Overflow
# Targets with comments on the same line will be listed.
list:
	@LC_ALL=C $(MAKE) -pRrq -f $(firstword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/(^|\n)# Files(\n|$$)/,/(^|\n)# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | grep -E -v -e '^[^[:alnum:]]' -e '^$@$$'

.PHONY: list

clean:
	cargo clean

clean-dx:
	rm -fr target/dx

check:
	cargo check --features server
	cargo check --features web
	cargo check --features desktop
	cargo check --features mobile

clippy:
	cargo clippy --features server
	cargo clippy --features web
	cargo clippy --features desktop
	cargo clippy --features mobile

###
apply-patch:
	cargo patch-crate

android-versionCode:
	cat resources/android/versionCode

android-versionCode-inc:
	vc=$$(cat resources/android/versionCode);vc=$$(($$vc + 1));echo $$vc > resources/android/versionCode
	cat resources/android/versionCode

###
css: $(TAILWIND_FROM_INPUT)

css-watch:
	tailwindcss -i $(TAILWIND_INPUT_CSS) -o $(TAILWIND_CSS) --watch

$(TAILWIND_CSS): $(TAILWIND_INPUT_CSS)
	tailwindcss -i $(TAILWIND_INPUT_CSS) -o $(TAILWIND_CSS)

js: $(JS_FROM_TS)

$(CONTROLLER_JS):
	swc compile $(CONTROLLER_TS) --out-file $(CONTROLLER_JS)

###
build-dep: css js

bundle-web: build-dep clean-dx
	dx bundle --web --release --base-path "/$(APPNAME)"

bundle-desktop: build-dep clean-dx
	dx bundle --desktop --release --package-types appimage

bundle-android-aarch64: build-dep clean-dx
	dx bundle --android --release --target=aarch64-linux-android
	./scripts/apk-icon-assemble-r.sh $(APPNAME) aarch64 resources/android

bundle-android-x86_64: build-dep clean-dx
	dx bundle --android --release --target=x86_64-linux-android
	./scripts/apk-icon-assemble-r.sh $(APPNAME) x86_64 resources/android

bundle-android-wv: build-dep clean-dx
	./scripts/wv-apk-icon-assemble-r.sh $(APPNAME) resources/android ./scripts/android-webview-params.toml

bundle-android-wva: build-dep clean-dx
	./scripts/wva-apk-icon-assemble-r.sh $(APPNAME) resources/android resources/android ./scripts/android-webview-assets-params.toml
