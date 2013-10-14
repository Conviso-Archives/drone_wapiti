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
require 'base64'
require 'builder'

module Parse
  module Writer
    class Conviso
      def self.build_xml(issue, config)
        xml = Builder::XmlMarkup.new( :ident => 2)
        xml.instruct! :xml, :encoding => 'UTF-8'

        xml.scan do |s|
          s.header do |h|
            h.tool config['tool_name']
            h.project config['project_id']
            h.timestamp Time.now
          end

          s.vulnerabilities do |vs|
            vs.vulnerability do |v|
              v.hash issue[:_hash]
              v.title Base64.encode64(issue[:name].to_s)
              v.description Base64.encode64("#{issue[:description]}")
              v.optional do |vo|
                vo.affected_component Base64.encode64(issue[:affected_component].to_s)
                vo.control Base64.encode64("#{issue[:remedy_guidance]}")
                vo.reference Base64.encode64(issue[:reference].to_s)
                vo.exploitability issue[:severity].to_s.downcase
                vo.template_id issue[:template_id].to_s.downcase
              end # optional
            end # vulnerability
          end # vulnerabilities
        end # scan

      end

    end
  end
end
