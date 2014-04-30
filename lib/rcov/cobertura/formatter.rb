require 'erb'

module Rcov
  module Cobertura
    class Formatter
      TEMPLATE_FILE = File.join(File.dirname(File.expand_path(__FILE__)), 'cobertura.xml.erb')
  
      def initialize(args={})
        @destdir = args[:destdir] || 'coverage'
        @ignore = args[:ignore] || []
        @dont_ignore = args[:dont_ignore] || []
        @covdata = []
        @total_loc = 0
        @total_covered_loc = 0
      end
  
      def add_file(filename, lines, covered, counts)
        return if should_ignore?(filename)
  
        loc = lines.count{|l| is_loc?(l)}
        @total_loc += loc
  
        # fixup covered for 'end'.
        # This is a heuristic seemingly used by rcov:
        # for an 'end' line, count the line as covered iff the previous line was covered.
        covered.each_with_index do |c,idx|
          next if idx == 0
          next if c
          if covered[idx-1] && lines[idx] =~ /^\s*end\s*(#.*)?$/
            covered[idx] = true
            counts[idx] = counts[idx-1]
            if counts[idx] == 0
              counts[idx] = 1
            end
          end
        end
  
        i = 0
        covered_loc = covered.count do |c|
          i += 1
          c && is_loc?(lines[i-1])
        end
        @total_covered_loc += covered_loc
  
        @covdata << {
          :name => filename,
          :lines => lines,
          :covered => covered,
          :counts => counts,
          :branch_rate => 1.0,
          :line_rate => covered_loc.to_f / loc
        }
      end
  
      def execute
        src = IO.read TEMPLATE_FILE
        erb = ERB.new(src, nil, '%-<>')
        erb.filename = TEMPLATE_FILE
        out = erb.result(get_binding)
  
        File.open(File.join(@destdir, 'cobertura.xml'), 'w') do |f|
          f.write out
        end
      end
  
      private
  
      def should_ignore?(file)
        @ignore.any?{|rx| file =~ rx} && !@dont_ignore.any?{|rx| file =~ rx}
      end
  
      # FIXME: just a hueristic, doesn't quite seem right.
      # Compare with rcov.
      def is_loc?(line)
        line !~ /^\s*(#.*)?$/
      end
      
      def get_binding
        branch_rate = 1.0
        line_rate = @total_covered_loc.to_f / @total_loc
        covered_files = @covdata
        binding()
      end
    end
  end
end
