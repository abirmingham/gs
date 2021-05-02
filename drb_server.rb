require 'drb/drb'

puts 'We are the borg.'
puts 'We will add your biological and technological disctinctiveness to our own.'
puts 'Resistance is futile.'
puts '(You can just leave this running)'

class Bandits
  include DRb::DRbUndumped
  def initialize()
    @counts = {}
    @group = []
    @debug = true
  end
  def set_new_group(group)
    @group = group
    clear_counts
  end
  def has_group_registered?
    return @group.all? { |x| @counts[x] }
  end
  def set_count(char, count)
    log "set_count #{char} #{count}" if @debug
    @counts[char] = count
  end
  def get_counts()
    @counts
  end
  def clear_counts()
    log 'clear_counts' if @debug
    @counts = {}
  end
  def log(msg)
    print "BANDITS: #{msg}\n"
  end
end

class ActionQueue
  include DRb::DRbUndumped
  def initialize()
    @actions = {}
    @debug = false
  end
  def init_queue(char)
    if !@actions[char]
      log "Initializing queue for #{char}" if @debug
      @actions[char] = { 'count' => 0, 'queue' => [] }
    end
  end
  def queue_action(char, cmd, args = [])
    init_queue char
    id = @actions[char]['count']
    log "queue_action #{char} #{cmd}" if @debug

    @actions[char]['queue'].push(
      {
        'id' => id,
        'char' => char,
        'cmd' => cmd,
        'args' => args,
        'done' => false,
        'error' => nil
      }
    )
    @actions[char]['count'] = @actions[char]['count'] + 1

    return id
  end
  def get_actions(char)
    # print "get_actions #{char}\n" # TOO NOISY
    init_queue char
    @actions[char]['queue']
  end
  def get_action(char, id)
    log "get_action #{char}, #{id}" if @debug
    init_queue char
    @actions[char]['queue'].find { |x| x['id'] == id }
  end
  def mark_action_done(char, id, error = nil)
    log "mark_action_done #{char}, #{id}" if @debug
    init_queue char
    index = @actions[char]['queue'].find_index { |x| x['id'] == id }
    @actions[char]['queue'][index] =
      @actions[char]['queue'][index].merge({ 'done' => true, 'error' => error })
  end
  def clear_action(char, id)
    log "clear_action #{char}, #{id}" if @debug
    init_queue char
    @actions[char]['queue'] =
      @actions[char]['queue'].reject { |x| x['id'] == id }
  end
  def clear_all_actions()
    log 'clear_all_actions' if @debug
    @actions = {}
  end
  def log(msg)
    print "BANDITS: #{msg}\n"
  end
end

#create shared object to be hosted
shared = { 'bandits' => Bandits.new, 'actions' => ActionQueue.new }

DRb.start_service('druby://localhost:9999', shared)
DRb.thread.join
