#!/usr/bin/ruby

AUTHOR = {:first_name => 'Tiago', :surname => 'Ferreira', :email => 'tferreira@conviso.com.br'}
PROJECT = {:name => 'Drone Wapiti'}

LICENSE = <<END_STRING
#
# Copyright #{Time.now.year} by #{AUTHOR[:first_name]} #{AUTHOR[:surname]} (#{AUTHOR[:email]})
#
# This file is part of the #{PROJECT[:name]} project.
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
END_STRING

# STEP 01: List .rb files
def scan_for_rb_files(dir)
  return [Dir.glob("#{dir}/*.rb")] if Dir.glob("#{dir}/*").select{|f| Dir.exists?(f)}.empty?
  return Dir.glob("#{dir}/*.rb") + Dir.glob("#{dir}/*").select{|f| Dir.exists?(f)}.collect{ |d| scan_for_rb_files(d)}.flatten
end


if ARGV.size.zero?
  puts "\n.:[ License Manager #{Time.now.year} - Conviso Application Security ]:.\n\n"
  puts "Usage: ruby #{$0} <directory>\n\n"
  exit 0
end

ruby_files = scan_for_rb_files(ARGV.first).select {|f| f !~ /#{$0}/}

# STEP 02: insert the license term; The first 20 lines are reserved for licensing
ruby_files.each do |rfile|
  line_counter = 0
  fd = File.open(rfile)
  fd_new = File.open("#{rfile}.1", "a")
  
  # clean old lisence
  while !fd.eof?
    line_counter += 1
    line = fd.readline
    next if line_counter < 20 && line =~ /^#/ && line !~ /^#!(.+)\/ruby/
    fd_new.write(line)
  end
  
  fd.close
  fd_new.close
  
  fd = File.open("#{rfile}.1")
  fd_new = File.open("#{rfile}", 'w')
  first_line = fd.readline if !fd.eof?
  
  if first_line =~ /^#!(.+)\/ruby/
    fd_new.write(first_line)
  else
    fd.rewind
  end
  
  fd_new.write(LICENSE)
  
  while !fd.eof?
    line = fd.readline
    fd_new.write(line)
  end
  
  fd.close
  fd_new.close
  File.unlink("#{rfile}.1")
end
