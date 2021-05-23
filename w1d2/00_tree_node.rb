module Searchable # these are nodes
  # I wrote this as a mixin in case I wanted to later write another
  # TreeNode class (e.g., BinaryTreeNode). All I need is `#children` and
  # `#value` for `Searchable` to work.

  def dfs(target = nil, &prc)
  
      raise "need a prc or a value " if [target,prc].none? # this iwll be reaised if we dont have a targhet or if we dont jave a prc
      prc ||= Proc.new{|node| node.value == target} 
      return  self if prc.call(self) 

      children.each do |child|
        result = child.dfs(&prc) # you call it again without the value recursive step above is the base case
        return result unless result.nil?
      end

      nil
  
  end

    def bfs(target = nil, &prc)
        raise "need a proc or a taget" if [value,prc].none?
        prc ||= Proc.new{|node| node.value == target } # they both taske in default procs 

        nodes = [self]
        until nodes.empty?
          node = nodes.shift # nodes is an array node is  single element 
          return node if prc.call(node) # this is like checking the value
          node.concat(node.children)n # pushing the nodes children to the end of the array
        end
        nil
    end

    def count
      1 + children.map(&:count).inject(:+)
    end
end

class PolyTreeNode
  include Searchable

  attr_accessor :value
  attr_reader :parent

  def initialize(value = nil)
    @value, @parent, @children = value, nil, []
  end

  def children
    # We dup to avoid someone inadvertently trying to modify our
    # children directly through the children array. Note that
    # `parent=` works hard to make sure children/parent always match
    # up. We don't trust our users to do this.
    @children.dup
  end

  def parent=(parent)
    return if self.parent == parent

    # First, detach from current parent.
    if self.parent
      self.parent._children.delete(self)
    end

    # No new parent to add this to.
    @parent = parent
    self.parent._children << self unless self.parent.nil?

    self
  end

  def add_child(child)
    # Just reset the child's parent to us!
    child.parent = self
  end

  def remove_child(child)
    # Thanks for doing all the work, `parent=`!
    if child && !self.children.include?(child)
      raise "Tried to remove node that isn't a child"
    end

    child.parent = nil
  end

  protected
  
  # Protected method to give a node direct access to another node's
  # children.
  def _children
    @children
  end
end
