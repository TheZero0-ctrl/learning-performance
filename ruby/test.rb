require 'benchmark'

source = "This [is] a test string with spaces and brackets. " * 10_000

Benchmark.bm do |x|
  x.report("Chained gsub: ") do
    source
      .gsub('%20', ' ')
      .gsub('%5B', '[')
      .gsub('%5D', ']')
      .gsub('&amp;', '&')
      .gsub('&lt;', '<')
      .gsub('&gt;', '>')
  end
  x.report("Single gsub:  ") do
    source.gsub(/[\s\[\]]/, {
      ' ' => '%20',
      '[' => '%5B',
      ']' => '%5D',
      '&' => '&amp;',
      '<' => '&lt;',
      '>' => '&gt;'
    })
  end
end
