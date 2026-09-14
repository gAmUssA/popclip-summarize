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
ENGINES = %w[claude-summarize.swift responses-summarize.swift apple-intelligence.swift cli-summarize.swift].freeze

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

  # Every fallback in the wrapper, not just the first: a wrapper can mention the
  # same option in a title as well as in the assignment that matters.
  wrapper_defaults = where[:wrapper] ? read(where[:wrapper]).scan(/POPCLIP_OPTION_#{id.upcase}:-([^}]+)\}/).flatten : []
  fail!("#{id}: no POPCLIP_OPTION_#{id.upcase}:- fallback found in #{where[:wrapper] || 'any wrapper'}") if wrapper_defaults.empty?
  places = [["Config.yaml", config_default], [where[:engine_file], where[:engine]]] +
           wrapper_defaults.map { |value| [where[:wrapper], value] }
  places.each do |place, value|
    next if value == config_default

    fail!("#{id}: default is #{config_default.inspect} in Config.yaml but #{value.inspect} in #{place}")
  end
end

read("cli-summarize.swift").scan(/"([a-z]+)": CLIModel\(model: "([A-Z0-9_]+)", customModel: "[A-Z0-9_]+", defaultModel: "([^"]+)"\)/) do |(cli, id, model)|
  config_default = OPTIONS.dig(id.downcase, "default value")
  next if model == config_default

  fail!("#{id.downcase}: default is #{config_default.inspect} in Config.yaml but #{model.inspect} in cli-summarize.swift (--cli #{cli})")
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

# 4. Each wrapper passes its engine every option the engine reads. run_engine
#    gives an engine only STYLE, EXTRA, and the options its wrapper names, so an
#    omission here reads as "unset" at runtime, not as an error.
SHARED_OPTIONS = %w[STYLE EXTRA].freeze
engine_reads = {
  "claude-summarize.swift" => read("claude-summarize.swift").scan(/\boption\("([A-Z0-9_]+)"\)/).flatten,
  "apple-intelligence.swift" => read("apple-intelligence.swift").scan(/POPCLIP_OPTION_([A-Z0-9_]+)/).flatten,
  "cli-summarize.swift" => read("cli-summarize.swift").scan(/\boption\("([A-Z0-9_]+)"\)/).flatten,
}
# CLI backends read their model options through a table keyed by --cli.
cli_models = read("cli-summarize.swift").scan(
  /"([a-z]+)": CLIModel\(model: "([A-Z0-9_]+)", customModel: "([A-Z0-9_]+)", defaultModel: "([^"]+)"\)/
).to_h { |cli, model, custom, default| [cli, { options: [model, custom], default: default, model: model }] }
providers = read("responses-summarize.swift").scan(/"([a-z]+)": Provider\((.*?)\n    \),/m).to_h do |id, body|
  [id, body.scan(/(?:keyOption|modelOption|customModelOption): "([A-Z0-9_]+)"/).flatten]
end
shared_responses = read("responses-summarize.swift").scan(/\boption\("([A-Z0-9_]+)"\)/).flatten
wrapper_count = 0
Dir[File.join(EXT, "summarize-*.sh")].sort.each do |path|
  wrapper = File.read(path)
  file = File.basename(path)
  # A wrapper may build several engines (e.g. API and CLI backends): pair each
  # run_engine call with the build_cached assignment of the variable it runs.
  sources = wrapper.scan(/(\w+)="\$\(build_cached "\$\{EXT_DIR\}\/([a-z-]+\.swift)"\)"/).to_h
  calls = wrapper.scan(/run_engine "\$(\w+)" "([A-Z0-9_ ]*)"(?: --(provider|cli) ([a-z]+))?/)
  next fail!("#{file}: no run_engine \"$engine\" \"<OPTION IDS>\" call found") if calls.empty?

  calls.each do |var, passed, flag, value|
    wrapper_count += 1
    source = sources[var] or next fail!("#{file}: run_engine runs $#{var}, which isn't assigned from build_cached")
    provider = value if flag == "provider"
    cli = value if flag == "cli"
    if provider && !providers.key?(provider)
      fail!("#{file}: run_engine names unknown provider #{provider}")
      next
    end
    needed = if provider
               providers[provider] + shared_responses
             elsif cli
               engine_reads.fetch(source, []) + cli_models.fetch(cli, { options: [] })[:options]
             else
               engine_reads.fetch(source, [])
             end
    missing = needed.uniq - SHARED_OPTIONS - passed.split
    missing.each { |id| fail!("#{file}: #{source} reads option #{id.downcase} but run_engine doesn't pass it") }
  end
end

if $failures.empty?
  puts "    #{references.size} option references, #{defaults.size} default models, #{blocks.size} prompt blocks, #{wrapper_count} engine calls agree"
else
  $failures.each { |f| warn "    FAIL: #{f}" }
  exit 1
end
