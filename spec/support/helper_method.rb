# Hash#diff is depreciated in rails 4
def diff(h1,h2)
  h1.dup.delete_if { |k, v|
    h2[k] == v
  }.merge!(h2.dup.delete_if { |k, v| h1.has_key?(k) })
end
