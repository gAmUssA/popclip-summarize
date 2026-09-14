#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Cross-file consistency checks for the extension, run by `make check`.
#
# The same facts live in several places — Config.yaml, the action wrappers,
# and the Swift engines — because each file must stand alone when PopClip or
# swiftc runs it. This catches them drifting apart.

require "yaml"

EXT = File.expand_path("../AISummarize.popclipext", __dir__)
CONFIG = YAML.load_file(File.join(EXT, "Config.yaml"))
OPTIONS = CONFIG["options"].to_h { |o| [o["identifier"], o] }
ENGINES = %w[claude-summarize.swift responses-summarize.swift apple-intelligence.swift].freeze

$failures = []

def fail!(message)
  $failures << message
end

def read(name)
  File.read(File.join(EXT, name))
end

# 1. Every option an engine or wrapper reads is declared in Config.yaml.
#    PopClip passes undeclared options as nothing, so a typo reads as "unset".
references = Hash.new { |h, k| h[k] = [] }
Dir[File.join(EXT, "*.{sh,swift}")].sort.each do |path|
  source = File.read(path)
  file = File.basename(path)
  source.scan(/POPCLIP_OPTION_([A-Z0-9_]+)/) { |(id)| references[id] << file }
  source.scan(/\boption\("([A-Z0-9_]+)"\)/) { |(id)| references[id] << file }
  source.scan(/\b(?:keyOption|modelOption|customModelOption): "([A-Z0-9_]+)"/) { |(id)| references[id] << file }
end
references.each do |id, files|
  next if OPTIONS.key?(id.downcase)

  fail!("option #{id.downcase} is read by #{files.uniq.join(', ')} but not declared in Config.yaml")
end

# 2. Each provider's default model agrees across Config, wrapper, and engine,
#    and is one of the Model picker's values.
defaults = {
  "model" => {
    wrapper: "summarize-claude.sh",
    engine_file: "claude-summarize.swift",
    engine: read("claude-summarize.swift")[/option\("MODEL"\)\.isEmpty \? "([^"]+)"/, 1],
  },
}
read("responses-summarize.swift").scan(
  /modelOption: "([A-Z0-9_]+)",\s*customModelOption: "[A-Z0-9_]+",\s*defaultModel: "([^"]+)"/
) do |(id, model)|
  wrapper = Dir[File.join(EXT, "summarize-*.sh")].map { |p| File.basename(p) }
                                                 .find { |f| read(f).include?("POPCLIP_OPTION_#{id}:-") }
  defaults[id.downcase] = { wrapper: wrapper, engine_file: "responses-summarize.swift", engine: model }
end

defaults.each do |id, where|
  option = OPTIONS[id] or next fail!("model option #{id} is not declared in Config.yaml")
  config_default = option["default value"]
  unless Array(option["values"]).include?(config_default)
    fail!("#{id}: default #{config_default.inspect} is not one of its values")
  end

  wrapper_default = where[:wrapper] && read(where[:wrapper])[/POPCLIP_OPTION_#{id.upcase}:-([^}]+)\}/, 1]
  { "Config.yaml" => config_default, where[:wrapper] || "wrapper (not found)" => wrapper_default,
    where[:engine_file] => where[:engine] }.each do |place, value|
    next if value == config_default

    fail!("#{id}: default is #{config_default.inspect} in Config.yaml but #{value.inspect} in #{place}")
  end
end

# 3. The prompt block is identical in every engine — the engines are meant to
#    differ only in transport, so summaries stay comparable.
blocks = ENGINES.to_h do |name|
  block = read(name)[/var instructionLines = \[\n(.*?)\n\]/m, 1]
  fail!("#{name}: no `var instructionLines = [ ... ]` block found") unless block
  [name, block&.lines&.map(&:strip)]
end
reference_name, reference = blocks.first
blocks.drop(1).each do |name, block|
  next if block.nil? || reference.nil? || block == reference

  (reference - block).each { |line| fail!("prompt: #{name} lacks line from #{reference_name}: #{line}") }
  (block - reference).each { |line| fail!("prompt: #{name} has line not in #{reference_name}: #{line}") }
  fail!("prompt: #{name} orders its lines differently from #{reference_name}") if (block - reference).empty? && (reference - block).empty?
end

if $failures.empty?
  puts "    #{references.size} option references, #{defaults.size} default models, #{blocks.size} prompt blocks agree"
else
  $failures.each { |f| warn "    FAIL: #{f}" }
  exit 1
end
