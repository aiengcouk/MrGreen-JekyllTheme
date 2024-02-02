.PHONY: all serve build deploy check check-commits clean no_jekyll

PROD_PATH = public_html
LOCAL_PATH = _site
CP = scp -r
DEL = rm -rf
MV = mv
JEKYLL := jekyll
CACHE_DIRS := .sass-cache .jekyll-metadata
PROD_CREDENTIALS := $(shell cat ~/.config/.prod-credentials 2>/dev/null)

ifeq (, $(shell which $(JEKYLL)))
no_jekyll:
	@printf '\n\n%s\n\n\n' "No $(JEKYLL) in PATH:"; \
	echo "$(PATH)"; \
	printf '\n\n%s\n\n\n' "Please install Jekyll: https://jekyllrb.com/docs/installation/"
endif

all: clean serve

serve:
	$(JEKYLL) serve --watch --host 0.0.0.0 --safe --incremental

build:
	$(JEKYLL) build

deploy: check-commits clean build
	ifndef PROD_CREDENTIALS
		$(error PROD_CREDENTIALS is not set)
	endif
	$(MV) $(LOCAL_PATH) $(PROD_PATH)
  $(CP) $(PROD_PATH) $(PROD_CREDENTIALS):

check:
	@echo "Checking ..."
	@$(JEKYLL) build
	@htmlproofer $(LOCAL_PATH) --check-html --disable-external --empty-alt-ignore

check-commits:
	@git diff-index --quiet HEAD -- || (echo "Can't deploy before commit all changes." && exit 1)

clean:
	@$(JEKYLL) clean
	@$(DEL) $(PROD_PATH) $(LOCAL_PATH) $(CACHE_DIRS)
