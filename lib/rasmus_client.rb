require 'redis'
require 'securerandom'
require 'json'

class RasmusClient
  attr_accessor :redis, :timeout

  def initialize(redis, *namespace)
    @redis = redis
    @namespace = namespace
    @timeout = 60
  end

  def read(path)
    request(command: 'read', path: path)
  end

  def write(path, mode, data)
    request(command: 'write', path: path, input: data, mode: mode)
  end

  def list(path)
    request(command: 'list', path: path)
  end
  
  def execute(cmd, input, *params)
    request(command: 'execute', path: cmd, input: input, params: params)
  end

  def request(args={})
    uuid = SecureRandom.uuid
    @redis.lpush(key('req'), args.merge(uuid: uuid).to_json)
    if raw_response = @redis.brpop(key('resp', uuid), @timeout)
      JSON.parse raw_response.last
    else
      nil
    end
  end

  def key(*strings)
    [*@namespace, 'rasmus', *strings].compact.map(&:to_s).join ':'
  end
end
