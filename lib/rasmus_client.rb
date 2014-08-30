require 'redis'
require 'securerandom'
require 'json'

class RasmusClient
  attr_accessor :redis

  def initialize(redis, namespace=nil)
    @redis = redis
    @namespace = namespace
  end
  
  def read(path)
  end
  
  def write(path, mode, data)
  end
  
  def list(path)
  end
  
  def execute(cmd, input, *params)
  end
  
  def request(args={})
    uuid = SecureRandom.uuid
    @redis.lpush(key('req'), args.merge(uuid: uuid).to_json)
    if raw_response = @redis.brpop(key('resp', uuid), 60)
      JSON.parse raw_response.last
    else
      # timeout
    end
  end
  
  def key(*strings)
    [@namespace, 'rasmus', *strings].compact.join ':'
  end
end
