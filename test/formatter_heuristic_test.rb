require 'test/unit'
require 'rcov-cobertura'
require 'tmpdir'

class FormatterHeuristicTest < Test::Unit::TestCase

  def get_output(file, lines, coverage, counts)
    Dir.mktmpdir('rcov_cobertura_formatter_test') do |dir|
      fmt = Rcov::Cobertura::Formatter.new(:destdir => dir)
      fmt.add_file(file, lines, coverage, counts)
      fmt.execute
      IO.read File.join(dir, 'cobertura.xml')
    end
  end

  def assert_line_rate(file, expected_rate, xml)
    assert xml =~ /\bfilename="#{Regexp.escape(file)}" line-rate="([0-9.]+)"/,
      "expected line rate of #{expected_rate} for #{file}, but no line rate found"

    assert_equal expected_rate, $1, "line rate for #{file} differs from expected"
  end

  def get_lines(xml)
    xml.split("\n").select{|l| l =~ /<line /}.map do |l|
      assert l =~ %r{<line number="(\d+)" hits="(\d+)"/>}
      [$1.to_i, $2.to_i]
    end
  end

  def test_comments_are_ignored
    output = get_output('comments_ignored.rb', (<<-'endcode').split("\n"),
# line 1 should not be counted.
puts "but this line should count"; return
"this line is dead, making the LOC coverage 50%"
endcode
      [false,true,false], [0, 1, 0])

    assert_line_rate 'comments_ignored.rb', '0.5', output
    assert_equal [[2,1], [3,0]], get_lines(output)
  end

  def test_empty_lines_are_ignored
    output = get_output('empty_lines_ignored.rb', (<<-'endcode').split("\n"),

puts "above, empty line should be ignored"; return
"this line is dead, making the LOC coverage 50%"
endcode
      [false,true,false], [0, 1, 0])

    assert_line_rate 'empty_lines_ignored.rb', '0.5', output
    assert_equal [[2,1], [3,0]], get_lines(output)
  end

  def test_end_inherits_previous_line
    output = get_output('end.rb', (<<-'endcode').split("\n"),
begin
  "although rcov reports the 'end' line is not covered, we flip it to covered"
end # because the prior line was covered

begin
  "and if the prior line was not covered, neither is end"
end
endcode
      [true,true,true,false,true,false,false],
      [   1,   1,   1,    0,   1,    0,    0])

    assert_line_rate 'end.rb', '0.666666666666667', output
    assert_equal [[1,1], [2,1], [3,1], [5,1], [6,0], [7,0]], get_lines(output)
  end

end
