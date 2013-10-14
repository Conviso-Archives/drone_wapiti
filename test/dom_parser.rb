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
require '../lib/parse/dom/tool'

parse = Parse::DOM::Tool.new
xml_files = Dir.glob('./sample/*.xml')

total_time_start = Time.now.tv_sec
xml_files.each do |f|
  puts "Parsing file #{f} ..."

  t_start = Time.now.tv_sec
  struct = parse.parse_file(f)
  t_stop = Time.now.tv_sec

  puts "Was found [#{struct[:issues].size}] issues"
  puts "This file has [#{(File.size(f)/1000.0).to_i}] KB"
  puts "The parser took [#{t_stop - t_start}] seconds"
end

total_time_stop = Time.now.tv_sec
puts "\n"
puts "* Total time: [#{total_time_stop - total_time_start}] seconds"
