# :stopdoc:
# monkey patch Sass to exclude special mixins from it's include loop logic
module Sass
  module Tree
    module Visitors
      class Perform
        def handle_include_loop!(node)
          # a list of exempt mixins
          exempt = %w(to-styles output-style -outputStyle)
          exempts = []

          msg = "An @include loop has been found:"
          content_count = 0
          mixins = @stack.reverse.map {|s| s[:name]}.compact.select do |s|
            if s == '@content'
              content_count += 1
              false
            elsif content_count > 0
              content_count -= 1
              false
            # if the mixin is exempt, keep track of it
            elsif exempt.include?(s.gsub(/_/,'-'))
              exempts.push(s)
              false
            else
              true
            end
          end

          return if mixins.empty? or (mixins.size <= exempts.size)
          raise Sass::SyntaxError.new("#{msg} #{node.name} includes itself") if mixins.size == 1

          msg << "\n" << Sass::Util.enum_cons(mixins.reverse + [node.name], 2).map do |m1, m2|
            "    #{m1} includes #{m2}"
          end.join("\n")
          raise Sass::SyntaxError.new(msg)
        end
      end
    end
  end
end
