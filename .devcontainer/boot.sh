#!/bin/bash

echo "Updating RubyGems..."
gem update --system -N

echo "Installing dependencies..."
bundle install

echo "Copying launch..."
mkdir -p .vscode && cp .devcontainer/launch.json .vscode/launch.json

echo "Creating database..."
bin/rails db:prepare 

# echo "Configuring Solargraph"
# bundle exec yard gems

echo "Done!"