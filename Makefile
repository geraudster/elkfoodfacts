OUT_DIR=doc
# Using GNU Make-specific functions here
FILES=$(patsubst %.org,$(OUT_DIR)/%.pdf,$(wildcard elkfoodfacts.org)) $(patsubst %.org,$(OUT_DIR)/%.html,$(wildcard student/*.org instructor/*.org))

.PHONY: all clean install-doc

all: install-doc

install-doc: $(OUT_DIR) $(FILES)

$(OUT_DIR):
	mkdir -v -p $(OUT_DIR)

%.html: %.org
	emacs $< --batch -f package-initialize -f org-html-export-to-html --kill

$(OUT_DIR)/%.html: %.html
	install -v -m 644 -t $(OUT_DIR) $<
	rm $<

%.pdf: %.org
	emacs $< --batch -f package-initialize -f org-beamer-export-to-pdf --kill

$(OUT_DIR)/%.pdf: %.pdf
	install -v -m 644 -t $(OUT_DIR) $<
	rm $<

clean:
	rm $(OUT_DIR)/*.pdf $(OUT_DIR)/*.html
