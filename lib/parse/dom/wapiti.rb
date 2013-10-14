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
require 'rexml/document'

module Parse
  module DOM
    class Wapiti
      def parse_file(xml_file)
        struct = nil
        begin
	        struct = __extract_xml(xml_file)
        rescue Exception => e
          raise Exception.new 'XML with invalid format'
        end
        return struct
      end
     
     
      private
      def __extract_xml(xml_file)
        doc = REXML::Document.new File.new(xml_file)
        output = {}
        output[:issues] = []
        duration='N/A'

        toolname=doc.elements['//report/generatedBy'].attributes['id']
        start='N/A'

        path="//report/bugTypeList/bugType" 
        output[:issues] = doc.elements.collect(path) do |issue|  
          url=""
          parameter=""
          description=""
          solution=""
          references=""
          issue.elements.each('bugList/bug/') {|vuln| 
            url << vuln.elements['url'].text 
            parameter << vuln.elements['parameter'].text 
          }
          issue.elements.each('references/reference') {|ref| references << ref.elements['title'].text}
          issue.elements.each('description') {|desc| description << desc.cdatas().join}
          issue.elements.each('solution') {|remedy| solution << remedy.cdatas().join}
          {
            :name => issue.attributes['name'],
            :url =>  url,
            :description => description,
            :remedy_guidance => solution,
            :affected_component => url,
            :reference => references,
            :_hash => issue.attributes['name']
          }
        end 

        output[:duration]=duration
        output[:start_datetime]=start
        output[:toolname]=toolname

        # eliminando repetidos
        output[:issues].uniq!
        
        return output
      end
    end
  end
end
