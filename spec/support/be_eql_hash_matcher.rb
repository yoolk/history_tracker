# be_eql_hash
RSpec::Matchers.define :be_eql_hash do |expected|
  match do |actual|
    expected = expected.stringify_keys.dup
    if expected.keys.length != actual.keys.length
      false
    else
      diff = diff(expected, actual)
      if diff.blank?
        true
      else
        # http://railsware.com/blog/2014/04/01/time-comparison-in-ruby/
        result = diff.collect do |k, v|
          Time.at(actual[k].to_i) == Time.at(expected[k].to_i)
        end
        result.all? { |item| item == true }
      end
    end
  end
end