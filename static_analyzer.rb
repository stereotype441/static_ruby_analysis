require 'rubygems'
require 'parse_tree'

class Node
  attr_reader :children

  def initialize(children)
    @children = children
  end
end

class Node_op_asgn2 < Node
end

class Node_until < Node
end

class Node_not < Node
end

class Node_evstr < Node
end

class Node_ivar < Node
end

class Node_call < Node
end

class Node_dot2 < Node
end

class Node_svalue < Node
end

class Node_match3 < Node
end

class Node_rescue < Node
end

class Node_iasgn < Node
end

class Node_if < Node
end

class Node_arglist < Node
end

class Node_op_asgn_and < Node
end

class Node_dregx < Node
end

class Node_attrasgn < Node
end

class Node_masgn < Node
end

class Node_gvar < Node
end

class Node_iter < Node
end

class Node_class < Node
end

class Node_defn < Node
end

class Node_next < Node
end

class Node_cdecl < Node
end

class Node_case < Node
end

class Node_resbody < Node
end

class Node_lit < Node
end

class Node_cvar < Node
end

class Node_to_ary < Node
end

class Node_for < Node
end

class Node_sclass < Node
end

class Node_lasgn < Node
end

class Node_op_asgn_or < Node
end

class Node_cvasgn < Node
end

class Node_block_pass < Node
end

class Node_when < Node
end

class Node_dstr < Node
end

class Node_return < Node
end

class Node_ensure < Node
end

class Node_break < Node
end

class Node_defined < Node
end

class Node_nth_ref < Node
end

class Node_args < Node
end

class Node_colon2 < Node
end

class Node_cvdecl < Node
end

class Node_xstr < Node
end

class Node_defs < Node
end

class Node_and < Node
end

class Node_yield < Node
end

class Node_hash < Node
end

class Node_const < Node
end

class Node_colon3 < Node
end

class Node_alias < Node
end

class Node_op_asgn1 < Node
end

class Node_dxstr < Node
end

class Node_while < Node
end

class Node_or < Node
end

class Node_array < Node
end

class Node_lvar < Node
end

class Node_module < Node
end

class Node_str < Node
end

class Node_match2 < Node
end

class Node_super < Node
end

class Node_gasgn < Node
end

class Node_splat < Node
end

class Node_scope < Node
end

class Node_block < Node
end

class Node_true < Node
end

class Node_false < Node
end

class Node_nil < Node
end

class Node_zsuper < Node
end

class Node_self < Node
end

class Node_retry < Node
end

NODE_CLASSES = Hash.new { |hash, key| hash[key] = Kernel.const_get("Node_#{key}") }

class Analyzer
  def initialize
    @node_types = Hash.new { |hash, key| hash[key] = [] }
  end

  attr_reader :node_types

  def check_patterns(node)
    if node.class == Node_array and node.children.length > 25
      puts "Found one: #{node}"
    end
  end

  def traverse(node)
    check_patterns node
    type = node.class
    node.children.each_with_index do |x, i|
      @node_types[type][i] ||= Hash.new { |hash, key| hash[key] = 0 }
      if x.is_a? Node
        @node_types[type][i][x.class] += 1
        traverse x
      else
        @node_types[type][i][x.class] += 1
      end
    end
  end

  def convert_to_nodes(sexp)
    if sexp.is_a? Sexp
      cls = NODE_CLASSES[sexp.sexp_type]
      children = sexp.sexp_body.map { |child| convert_to_nodes(child) }
      cls.new(children)
    else
      sexp
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
      traverse(convert_to_nodes(sexp)) if sexp # empty files yield nil, heh.
    end
  end
end

analyzer = Analyzer.new
analyzer.investigate_path(ARGV[0])
require 'pp'
pp analyzer.node_types
