require 'rubygems'
require 'parse_tree'

class Analyzer
  def initialize
    @sexp_types = Hash.new { |hash, key| hash[key] = [] }
  end

  attr_reader :sexp_types

  def check_patterns(sexp)
    if sexp.sexp_type == :array and sexp.sexp_body.length > 25
      puts "Found one: #{sexp}"
    end
  end

  def traverse(sexp)
    check_patterns sexp
    type = sexp.sexp_type
    sexp.sexp_body.each_with_index do |x, i|
      @sexp_types[type][i] ||= Hash.new { |hash, key| hash[key] = 0 }
      if x.is_a? Sexp
        @sexp_types[type][i][x.sexp_type] += 1
        traverse x
      else
        @sexp_types[type][i][x.class] += 1
      end
    end
  end

  def investigate_path(path)
    if File.directory?(path)
      return if File.basename(path) == '.git'
      Dir.foreach(path) do |x|
        next if ['.', '..'].include? x
        investigate_path File.join(path, x)
      end
    else
      return if File.extname(path) != '.rb' # TODO: handle shebang files
      contents = File.read path
      parser = ParseTree.new(false) # true = include newlines
      sexp = parser.process(contents, nil, path)
      puts "Analyzing #{path}"
      traverse(sexp) if sexp # empty files yield nil, heh.
    end
  end
end

analyzer = Analyzer.new
analyzer.investigate_path(ARGV[0])
require 'pp'
pp analyzer.sexp_types
