require 'ruby-adjudicator'

Diplomacy.logger = Logger.new RUBY_PLATFORM =~ /mswin|mingw/ ? 'NUL:' : '/dev/null'
