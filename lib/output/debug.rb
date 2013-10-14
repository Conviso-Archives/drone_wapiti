#
# Copyright 2013 by Tiago Ferreira (tferreira@conviso.com.br)
#
# This file is part of the Drone Wapiti project.
# Drone Template is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
require 'net/smtp'

module Output
  class Debug
    @@level = 0
     
    class << self
      attr_accessor 'level'
     end
    
    attr_accessor :level
    def initialize(configuration)
      @config = configuration
      output_file = configuration['log_file'].to_s
      
      begin
        @output = File.exists?(output_file) ? File.open(output_file, 'a') : STDOUT
      rescue Exception => e
        @output = STDOUT
        warning(e.to_s)
        info('Using the default output for all system messages')
      end
    end
    
    def error(msg)
      m = "[E #{__get_time}] #{msg}"
      @output.puts m
      @output.flush
      
      if (@config.has_key?(:smtp) && @config[:smtp].has_key?(:operator) &&  @config[:smtp][:operator].has_key?(:email))
        __send_message(m) 
      end
    end
    
    def warning(msg)
      @output.puts "[W #{__get_time}] #{msg}"
      @output.flush
    end
    
    def info(msg)
      @output.puts "[I #{__get_time}] #{msg}"
      @output.flush
    end
    
    private
    def __get_time
      now = DateTime.now
      "#{now.year}-#{now.month}-#{now.day} #{now.hour}:#{now.min}"
    end
    
    def __send_message(content = '')
        message = <<MESSAGE_END
From: Bot #{@config[:plugin_name]} <#{@config[:plugin_name].gsub(' ', '').downcase}@conviso.com.br>
To: #{@config[:smtp][:operator][:name]} <#{@config[:smtp][:operator][:email]}>
Subject: Algum problema foi detectado com o bot #{@config[:plugin_name]} 

#{content}

MESSAGE_END

        Net::SMTP.start('localhost') do |smtp|
          smtp.send_message message, "#{@config[:plugin_name].gsub(' ', '').downcase}@conviso.com.br", @config[:smtp][:operator][:email]
        end
    end
  end
end