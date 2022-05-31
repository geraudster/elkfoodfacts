OUT_DIR=docs
# Using GNU Make-specific functions here
FILES=$(patsubst %.org,$(OUT_DIR)/%.pdf,elkfoodfacts.org) $(patsubst %.org,$(OUT_DIR)/%.html,elkfoodfacts.org)

.PHONY: all clean install-doc

all: install-doc

install-doc: $(OUT_DIR) $(FILES)

$(OUT_DIR):
	mkdir -v -p $(OUT_DIR)

%.html: %.org
	emacs $< --batch -f package-initialize -f org-html-export-to-html --kill

%.pdf: %.org
	emacs $< --batch -f package-initialize -f org-beamer-export-to-pdf --kill

clean:
	rm -f $(OUT_DIR)/*.pdf $(OUT_DIR)/*.html $(OUT_DIR)/*.tex
