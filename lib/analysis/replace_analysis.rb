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

module Analysis
  class Replace < Analysis::Interface::Individual

    def analyse(issue = nil)
      return issue if @config.nil?
      @config.select{|k,v| v == 'none'}.each {|k,v| @config[k] = ''}
      issue.keys.each do |k|
        @config.each {|k2,v| issue[k].to_s.gsub!(/#{k2.to_s}/i, v)} 
      end
      return issue
    end
    
  end
end