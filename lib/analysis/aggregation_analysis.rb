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
require 'digest/sha1'

module Analysis
  class Aggregation < Analysis::Interface::Bulk
    def analyse(issues = [])
      new_issues = {}
      issues.each do |i|
        if new_issues[i[:name]].nil?
          new_issues[i[:name]] = i
          new_issues[i[:name]][:affected_component] = [new_issues[i[:name]][:affected_component]]
        else
          @debug.info('Aggregating issue ...')
          new_issues[i[:name]][:url] += "\n#{i[:url].to_s}"
          new_issues[i[:name]][:affected_component] = [] if new_issues[i[:name]][:affected_component].nil?
          new_issues[i[:name]][:affected_component]  << i[:affected_component]

          new_issues[i[:name]][:_hash] = Digest::SHA1.hexdigest(new_issues[i[:name]][:_hash].to_s + i[:_hash].to_s)
        end
      end
      
      return_issues = new_issues.values
      return_issues.each do |i| 
        i[:affected_component] = i[:affected_component].join("\n\n")
      end
      return return_issues
    end
  end
end
