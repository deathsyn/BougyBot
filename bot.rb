#!/usr/bin/env ruby
require 'sequel'
require_relative './lib/bougy_bot'
DB = Sequel.connect BougyBot.options[:db]
DB.extension :pg_array
BougyBot::M 'user'
BougyBot::M 'mask'
BougyBot::M 'channel'
BougyBot::M 'log'
BougyBot::M 'url'
BougyBot::M 'quote'
BougyBot::L 'cinch'

def phillip(h = {})
  channels = h[:channels] || BougyBot.options.channels
  b = BougyBot::Cinch.new((h[:server] || 'irc.shaw.ca'), channels)
  b.bot.loggers << ::Cinch::Logger::FormattedLogger.new(File.open('bot.log', 'w'))
  b.bot.loggers = b.bot.loggers.last
  b
end

if $PROGRAM_NAME == __FILE__
  require 'pry'
  BougyBot.pry
end
