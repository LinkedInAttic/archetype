# :stopdoc:
# monkey patch Sass to exclude special mixins from it's include loop logic
module Sass
  module Tree
    module Visitors
      class Perform
        def handle_include_loop!(node)
          # do nothing
        end
      end
    end
  end
end
