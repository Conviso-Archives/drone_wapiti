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
require "rubygems"
require 'xmpp4r/client'


module Communication

  class XMPP
    def initialize(config = nil, debug = nil) # user,pass)
      @config = config
      @debug = debug
      @cl = Jabber::Client.new(Jabber::JID.new(@config['xmpp']['username']))
      
      @msg_queue = []

      @cl.add_message_callback do |m|
        if m.type != :error && m.body.to_s.size > 1
          @msg_queue << m.body
        end
      end
      
      @active = false
      __connenct()
    end

    # TODO: Fazer com que esse metodo apenas receba uma string com um payload
    def send_msg(payload = nil)
      @debug.info('Sending message ...')
      return false if !self.active?
      begin
        msg = Jabber::Message.new(@config['xmpp']['importer_address'], payload)
        msg.type = :normal
        @cl.send(msg)
      rescue
        @debug.error('Send message error')
        return false
      end

      sleep 2
      return true
    end
    
    def receive_msg
      (1..@msg_queue.size).to_a.collect{@msg_queue.pop}.join('_')
    end

    def active?
      @active
    end

    private
    def __connenct
      begin
        @cl.connect
        @cl.auth(@config['xmpp']['password'])
        @cl.send(Jabber::Presence.new.set_type(:available))
        @active = true
      rescue
        @debug.error('Cannot connect to XMPP server. Please check network connection and XMPP credentials.')
      end 
    end
  end

end