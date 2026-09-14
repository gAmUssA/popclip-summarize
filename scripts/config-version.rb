#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Print the version shown in the extension's settings heading
# (identifier `versionhead`). Used by `make release` and the release workflow
# to refuse a tag that doesn't match what users will see.

require "yaml"

config = YAML.load_file(File.expand_path("../AISummarize.popclipext/Config.yaml", __dir__))
heading = config["options"].find { |o| o["identifier"] == "versionhead" }
abort "Config.yaml has no versionhead heading" unless heading
version = heading["label"][/\b(\d+\.\d+\.\d+)\b/, 1]
abort "versionhead label has no x.y.z version: #{heading["label"].inspect}" unless version
puts version
