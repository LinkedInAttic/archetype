# :stopdoc:
# monkey patch Sass to exclude special mixins from it's include loop logic
module Sass
  module Tree
    module Visitors
      class Perform
        def handle_include_loop!(node)
          # PATCH: a list of exempt mixins
          exempt = %w(to-styles output-style -outputStyle bem)
          exempts = []

          msg = "An @include loop has been found:"
          content_count = 0
          mixins = @environment.stack.frames.select {|f| f.is_mixin?}.reverse!.map! {|f| f.name}
          mixins = mixins.select do |name|
            if name == '@content'
              content_count += 1
              false
            elsif content_count > 0
              content_count -= 1
              false
            # if the mixin is exempt, keep track of it
            elsif exempt.include?(name.gsub(/_/,'-'))
              exempts.push(name)
              false
            else
              true
            end
          end

          return if (mixins.size <= exempts.size) # Archetype PATCH: return if the mixins stack is exempt
          return unless mixins.include?(node.name)
          raise Sass::SyntaxError.new("#{msg} #{node.name} includes itself") if mixins.size == 1

          msg << "\n" << Sass::Util.enum_cons(mixins.reverse + [node.name], 2).map do |m1, m2|
            " #{m1} includes #{m2}"
          end.join("\n")
          raise Sass::SyntaxError.new(msg)
        end
      end
    end
  end
end
