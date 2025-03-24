VERSION=$(shell jq -r .version package.json)
DATE=$(shell date +%F)

all: src/wip.html

src/wip.html: md/wip.md template.html Makefile
	pandoc -s --css reset.css --css index.css -Vversion=v$(VERSION) -Vdate=$(DATE) -i $< -o $@ --template=template.html --mathjax
