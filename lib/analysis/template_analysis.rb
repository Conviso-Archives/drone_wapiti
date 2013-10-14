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
require File.join(File.dirname(__FILE__), 'interface')
require 'digest/md5'

module Analysis
  class Template < Analysis::Interface::Individual
    def analyse(issue = nil)
      return issue if @config.nil?
      @config.keys.each do |k|
        if Digest::MD5.hexdigest(issue[:name]) =~ /#{k}/i
          issue[:template_id] = @config[k]
        end
      end
      return issue
    end

  end
end