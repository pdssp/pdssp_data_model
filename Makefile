.PHONY: help install pdf pdf-local html html-local site serve clean open

# STAC Planet — PDSSP Data Model (DM)
#
# Unlike archi_doc/ and op_doc/ (asciidoctor-diagram + local PlantUML, gems
# installed with --user-install), this doc uses Bundler + asciidoctor-kroki
# against the public kroki.io service for diagrams — that's how it was set
# up in the source pdssp-data-model project, kept as-is here.

DOC        := pdssp-data-model
INDEX      := document.adoc
SITE_DIR   := site
PORT       := 8002

KROKI_URL       := https://kroki.io
KROKI_URL_LOCAL := http://localhost:8000
BUNDLE          := bundle exec

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

install: ## Install Ruby gems via Bundler (local to this directory, no sudo)
	bundle config --local path .bundle/gems
	bundle install
	bundle binstubs --all

pdf: ## Build the PDF (pdssp-data-model.pdf), diagrams rendered via kroki.io
	$(BUNDLE) asciidoctor-pdf -r asciidoctor-kroki -a kroki-server-url=$(KROKI_URL) -a allow-uri-read -a kroki-fetch-diagram --theme resources/style/pdssp-theme.yml -a pdf-fontsdir=resources/fonts -o $(DOC).pdf $(INDEX)

pdf-local: ## Build the PDF using a local Kroki server (see KROKI_URL_LOCAL)
	$(BUNDLE) asciidoctor-pdf -r asciidoctor-kroki -a kroki-server-url=$(KROKI_URL_LOCAL) -a allow-uri-read -a kroki-fetch-diagram --theme resources/style/pdssp-theme.yml -a pdf-fontsdir=resources/fonts -o $(DOC).pdf $(INDEX)

html: ## Build a single-page HTML version (pdssp-data-model.html)
	$(BUNDLE) asciidoctor -r asciidoctor-kroki -a kroki-server-url=$(KROKI_URL) -a allow-uri-read -a kroki-fetch-diagram -a theme=resources/style/pdssp-theme-html.yml -a toc=left -o $(DOC).html $(INDEX)

html-local: ## Build the HTML version using a local Kroki server
	$(BUNDLE) asciidoctor -r asciidoctor-kroki -a kroki-server-url=$(KROKI_URL_LOCAL) -a allow-uri-read -a kroki-fetch-diagram -a theme=resources/style/pdssp-theme-html.yml -a toc=left -o $(DOC).html $(INDEX)

site: html ## Assemble a browsable website into site/ (open site/index.html)
	@mkdir -p $(SITE_DIR)
	@cp $(DOC).html $(SITE_DIR)/index.html
	@cp -r images $(SITE_DIR)/ 2>/dev/null || true
	@echo "Site ready: $(SITE_DIR)/index.html"

serve: site ## Build the site and serve it locally at http://127.0.0.1:$(PORT)
	cd $(SITE_DIR) && python3 -m http.server $(PORT)

open: pdf ## Build the PDF and open it with the default viewer
	xdg-open $(DOC).pdf

clean: ## Remove generated PDF, HTML, website, and diagram caches
	rm -rf $(DOC).pdf $(DOC).html $(SITE_DIR) .asciidoctor
