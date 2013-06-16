require 'logger'

module Diplomacy
  def self.logger
    return @log if @log
    if defined? Rails and defined? config
      log_path = File.join(config.paths['log'].first, 'adjudicator.log')
    else
      log_path = STDOUT
    end
    @log = Logger.new log_path, 'daily'
  end

  def self.logger=(logger)
    @log = logger
  end
end

require 'adjudicator/adjudicator'
require 'graph/map_reader'
