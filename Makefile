JEKYLL_DOCKER_IMAGE ?= jekyll/jekyll:3.7

# Run jekyll in development mode
run: _data/projects.json
	docker run --rm -it \
		-p 4000:4000 -p 4001:4001 \
		-v="$(PWD)/vendor/bundle:/usr/local/bundle" \
		-v "$(PWD):/srv/jekyll" \
		$(JEKYLL_DOCKER_IMAGE) -- \
		jekyll serve --livereload --livereload-port 4001

# Build (output is in _site)
build: _data/projects.json
	docker run --rm -it \
		-v="$(PWD)/vendor/bundle:/usr/local/bundle" \
		-v "$(PWD):/srv/jekyll" \
		$(JEKYLL_DOCKER_IMAGE) -- \
		jekyll build

# Push new changes to the live site
publish: _data/projects.json
	$(eval ROOT_DIR = $(shell pwd -P))
	git -C "$(ROOT_DIR)" add -A
	@if git -C "$(ROOT_DIR)" diff-index --cached --quiet HEAD --; then\
		echo "no changes detected";\
	else \
		echo "committing changes...";\
		git -C "$(ROOT_DIR)" -c user.email="cncf-rook-info@lists.cncf.io" -c user.name="Rook" commit --message="docs snapshot for rook version \`$(DOCS_VERSION)\`"; \
		echo "pushing changes..."; \
		git -C "$(ROOT_DIR)" push; \
		echo "rook.github.io changes published"; \
	fi

# Generate projects.json
_data/projects.json: node_modules docs $(wildcard docs/*)
	node preprocess.js
	@touch _data/projects.json

# Install node_modules
node_modules: package.json package-lock.json
	npm ci
	@touch node_modules
