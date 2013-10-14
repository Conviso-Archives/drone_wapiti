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
module Analysis
  module Interface
    class Bulk
      attr_accessor :config, :debug
      def initialize (config = nil, debug = nil)
        @config = config
        @debug = debug
      end

      def _analyse(issues = [])
        begin
          raise AnalyseException, "[#{self.class}] Parameter should be an Array" unless (issues.instance_of?(Array))
          return analyse(issues)
        rescue => e
          raise AnalyseException, "[#{self.class}] Error during a bulk analysis"
        end
      end
      
      def analyse(issues = [])
        raise raise AnalyseException, "analyse() method should be implemented"
      end
    end
    
    class Individual
      attr_accessor :config, :debug
      def initialize (config = nil, debug = nil)
        @config = config
        @debug = debug
      end

      def _analyse(issue = nil)
        begin
          raise AnalyseException, "[#{self.class}] Parameter should be a Hash" unless (issue.instance_of?(Hash))
          return analyse(issue)
        rescue => e
          raise AnalyseException, "[#{self.class}] Error during an individual analysis"
        end
      end

      def analyse(issue = nil)
        raise raise AnalyseException, "analyse() method should be implemented"
      end
    end
    
  end
  
  class AnalyseException < Exception
  end
end