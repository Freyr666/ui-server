BUILD = ocamlbuild
FLAGS = -use-ocamlfind -plugin-tag 'package(js_of_ocaml.ocamlbuild)'

build: frontend backend
	@echo "Done"

common:
	$(BUILD) $(FLAGS) common/common.cma
	$(BUILD) $(FLAGS) common/common.cmxs

home: common
	$(BUILD) $(FLAGS) jsoo/home.byte
	js_of_ocaml --opt 3 +weak.js -o resources/js/home.js _build/jsoo/home.byte

frontend: home

backend: common
	$(BUILD) $(FLAGS) src/main.native

doc: build

test: build

all: build

clean:
	$(BUILD) -clean

.PHONY: build doc test all clean
