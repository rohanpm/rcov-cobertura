require 'test/unit'
require 'rcov-cobertura'
require 'tmpdir'

require 'mocha'
require 'mocha/test_unit'

class FormatterBaselineTest < Test::Unit::TestCase

  FILE1 = <<-'endcode'
def method_with_dead_code
  # jump out here
  return true
  # we don't get here
  puts(
    "Thou shalt never see this!")
end

def unused_method(x)
  # never executed
  x*x
end

method_with_dead_code()
endcode

  FILE2 = <<-'endcode'
small
file
endcode

  EXPECTED_XML = <<-"endxml"
<?xml version="1.0" ?>
<!DOCTYPE coverage
  SYSTEM 'http://cobertura.sourceforge.net/xml/coverage-03.dtd'>
<coverage branch-rate="1.0" line-rate="0.454545454545455"
 timestamp="1000000" version="rcov-cobertura #{Rcov::Cobertura::VERSION}">
 <sources>
  <source>.</source>
 </sources>
 <packages>
  <package branch-rate="1.0" complexity="0.0"
   line-rate="0.454545454545455" name="">
   <classes>
    <class branch-rate="1.0" complexity="0.0"
     filename="some/file.rb" line-rate="0.444444444444444" name="some_file_rb">
     <methods/>
     <lines>
      <line number="1" hits="1"/>
      <line number="3" hits="1"/>
      <line number="5" hits="0"/>
      <line number="6" hits="0"/>
      <line number="7" hits="0"/>
      <line number="9" hits="1"/>
      <line number="11" hits="0"/>
      <line number="12" hits="0"/>
      <line number="14" hits="0"/>
     </lines>
    </class>
    <class branch-rate="1.0" complexity="0.0"
     filename="other/file.rb" line-rate="0.5" name="other_file_rb">
     <methods/>
     <lines>
      <line number="1" hits="0"/>
      <line number="2" hits="1"/>
     </lines>
    </class>
   </classes>
  </package>
 </packages>
</coverage>
endxml

  def test_typical_against_baseline
    out_xml = Dir.mktmpdir('rcov_cobertura_formatter_test') do |dir|
      fmt = Rcov::Cobertura::Formatter.new(:destdir => dir)

      fmt.add_file("some/file.rb", FILE1.split("\n"),
        [true,true,true,false,false,false,false,false,true,false,false,false,false,false,true],
        [   1,   1,   1,    0,    0,    0,    0,    0,   1,    0,    0,    0,    0,    0,   1]
      )
      fmt.add_file('other/file.rb', FILE2.split("\n"), [false, true], [0, 1])

      Time.stubs(:now => 1000000)
      fmt.execute

      IO.read File.join(dir, 'cobertura.xml')
    end

    assert_equal EXPECTED_XML, out_xml
  end

end
