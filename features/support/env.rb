require_relative '../../lib/ruby-adjudicator'

Diplomacy.logger = Logger.new RUBY_PLATFORM =~ /mswin|mingw/ ? 'NUL:' : '/dev/null'
