require 'drb/drb'

puts 'We are the borg.'
puts 'We will add your biological and technological disctinctiveness to our own.'
puts 'Resistance is futile.'
puts '(You can just leave this running)'

class Bandits
  include DRb::DRbUndumped
  def initialize()
    @counts = {}
  end
  def set_count(name, count)
    @counts[name] = count
  end
  def get_counts()
    @counts
  end
  def clear_counts()
    @counts = {}
  end
end

#create shared object to be hosted
shared = { 'bandits' => Bandits.new }

DRb.start_service('druby://localhost:9999', shared)
DRb.thread.join

DRb.start_service
