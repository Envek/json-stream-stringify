#!/bin/bash

# Save current version
NODE_VERSION=$(node --version)

source $NVM_DIR/nvm.sh

install() {
	nvm install 10

	# install with node v10
	nvm use 10

	# install deps
	npm ci

	# Restore current version
	nvm use $NODE_VERSION
}

build() {
	# Builds with node v10
	nvm use 10
	
	# actual build
	npm run build
	
	# Restore current version
	nvm use $NODE_VERSION
}

test() {
	npm run test
}

lint() {
	npm run lint
}

coverage() {
	npm run coverage
	npm run coveralls
}

deploy() {
	# copy files for publish
	cp package.json dist/package.json
	cp package-lock.json dist/package-lock.json
	cp README.md dist/README.md
	cp LICENSE dist/LICENSE

	# move into publish directory
	cd dist

	# Set the NPM access token we will use to publish.
	npm config set registry https://registry.npmjs.org/
	npm config set //registry.npmjs.org/:_authToken ${NPM_TOKEN}

	# dry publish run
	npm pack

	# publish only when tagged and not a pull request
	if [[ "${TRAVIS_TAG}" != "" ]] && [[ "${TRAVIS_PULL_REQUEST}" = "false" ]]; then
		npm publish $(ls json-stream-stringify-*.tgz)
	fi
}

# Loop over arguments
for var in "$@"
do
	# Check if the function exists (bash specific)
	if declare -f "$var" > /dev/null
	then
	# call argument
	"$var"
	else
	# Show a helpful error
	echo "'$var' is not a known function name in docker_fn.sh" >&2
	exit 1
	fi
done
