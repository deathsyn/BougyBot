module BougyBot
  module Plugins
    # Bot Functions
    class Functions
      include ::Cinch::Plugin
      match(/^\.chug ?(\d+)?$/, method: :chug, use_prefix: false)
      match(/^\.pouring ?(.+)?/, method: :pouring, use_prefix: false)
      match(/^\.done/, method: :done, use_prefix: false)
      match(/^\.ready (in \d+)/, method: :ready, use_prefix: false)
      match(/^\.ready(\s+)?$/, method: :ready, use_prefix: false)
      match(/^.op (.+)/, method: :op, use_prefix: false)
      match(/^.drinkers/, method: :drinkers, use_prefix: false)
      match(/^.reset/, method: :reset, use_prefix: false)

      def reset(_ = nil)
        @timer = nil
        @drinkers = nil
        @chugging = nil
      end

      def drinkers(m)
        return unless check_perms(m)
        m.reply "Drinkers are #{@drinkers.map { |k, v| format('%s (%s)', k, v) }
          .join(', ')}"
      end

      def op(m, target)
        return unless m.user.nick.match(/bougyman|death_syn/i)
        return unless m.user.host.match(/we\.rubyists\.com|deathsyn\.com/)
        m.channel.op(User(target))
      end

      def pouring(m, target)
        return unless check_perms(m)
        if @drinkers.nil? or @drinkers.size == 0
          reset
          @chugging = nil
          m.reply "PREPARE! #{m.user.nick} is Pouring #{target}"
          @drinkers = {m.user.nick => target}
        else
          ready(m, "#{target}")
        end
      end

      def ready(m, target = nil)
        return unless check_perms(m)
        if @drinkers.nil? or @drinkers.size == 0
          m.reply "No one has poured yet!"
          return
        end
        if @chugging
          m.reply "Too late, #{m.user.nick}, already chugging"
          return
        end
        target ||= "something"
        extra = ""
        if target
          extra = " (#{target})"
        end
        if @drinkers.keys.include?(m.user.nick)
          m.reply "#{m.user.nick} is ready#{extra}"
        else
          m.reply "#{m.user.nick} is in and ready#{extra}"
          @drinkers[m.user.nick] = target
        end
      end

      def chug(m, target)
        return unless check_perms(m)
        return if @drinkers.nil? or @drinkers.size == 0
        if target.to_i < 1
          count = 5
        else 
          count = target.to_i
          count = 10 if count > 10
        end
        @chugging = true
        m.reply "#{@drinkers.map { |k,v| "%s (%s)" % [k,v] }.join(", ")}: Chugging in #{count} seconds!"
        (1 .. count).to_a.reverse.each do |num|
          m.reply num.to_s
          sleep 0.75
        end
        m.reply "#{@drinkers.keys.join(", ")}: CHUG!"
        @time = Time.now.to_i
        @timer = Time.now.to_i
        Timer(300, :shots => 1) { if @timer.nil? or @drinkers.nil? or @drinkers.size == 0;nil;else;m.reply "#{@drinkers.keys.join(', ')} took too long, resetting!"; reset; m.reply "Chugging is complete";end }
      end

      def done(m)
        return unless @chugging
        return unless check_perms(m)
        return if @drinkers.nil? or @drinkers.size == 0
        return unless @drinkers.keys.include?(m.user.nick)
        drink = @drinkers.delete(m.user.nick)
        m.reply "#{m.user.nick}: #{Time.now.to_i - @time} seconds for #{drink}" 
        if @drinkers.size == 0
          m.reply "Chugging is complete"
          @chugging = nil
        end
      end
      private
      def check_perms(m)
        return false unless m.channel.name.match(/#subgenii|#pho|#philrobot/)
        true
      end
    end
  end
end
