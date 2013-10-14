#!/usr/bin/ruby
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


require 'rubygems'
require 'yaml'
require 'fileutils'
require 'zip/zip'

PATH = File.dirname(__FILE__)
LIB_PATH = File.join(File.dirname(__FILE__), 'lib')
DEBUG = false
CONFIG_FILE = File.join(PATH, 'config.yml')

require File.join(LIB_PATH, 'parse/dom/Wapiti')
require File.join(LIB_PATH, 'parse/writer/conviso')
require File.join(LIB_PATH, 'communication/xmpp')
require File.join(LIB_PATH, 'output/debug')



# PARSING CONFIGURATION FILE
if !File.exists?(CONFIG_FILE)
  puts('Configuration file is missing.')
  exit
end

configuration = YAML.load_file(CONFIG_FILE)

# SETUPING LOG FILE
debug = Output::Debug.new(configuration)
Output::Debug::level = configuration['debug_level'].to_i || 0

# LOADING ANALYSIS MODULES
analysis_modules = []
Dir.glob(File.join(LIB_PATH, 'analysis/*_analysis.rb')).each do |a| 
  debug.info("Loading analysis module:  [#{a}]")
  begin 
    require a
    a =~ /analysis\/(\w+)_analysis.rb/
    am = eval("Analysis::#{$1.capitalize}.new()")
    am.config = configuration['analysis'][$1.downcase]
    am.debug = debug
    analysis_modules << am
  rescue Exception => e
    debug.error("Error loading analysis module:  [#{a}]")
  end
end

module Drone
  class Wapiti
    def initialize(config = '', debug = nil, analyses = [])
      @config, @debug, @analyses = config, debug, analyses
      
      # INITIALIZING A NEW XMPP COMMUNICATION CHANNEL 
      @comm = Communication::XMPP.new(@config, @debug)
      
      # PERFORMING MINNOR CHECKS BEFORE STARTS OPPERATING
      __validate_configuration
    end


    def run
      # VERIFY IF THE CONNECTION IS STILL ACTIVE
      if @comm.active?
        
        # SCAN ALL SOURCES SPECIFIED IN THE CONFIGURATION FILE
        @config['sources'].each do |s|

          # SETUP A COLLECTION OF ALL XMLs FOUND INSIDE THE CURRENT SOURCE INPUT DIRECTORY
	        xml_files = __scan_input_directory(s)

          # FOR EACH XML 
	        xml_files.each do |xml_file|
            begin
              # PARSING THE CURRENT XML USING THE SPECIFIC PARSER FOR THE TOOL OUTPUT FORMAT
	            structure = __parse_file(xml_file)
            rescue Exception => e
              @debug.error("Error parsing XML file: [#{xml_file}]")
              next
            end

	          # Try to send all vulnerabilities then, if had success, compress and 
	          # archive the XML file otherwise does not touch the original file
	          if __sent_structure(structure, s)
              compressed_file = __compress_file(xml_file)
              __archive_file(compressed_file) unless @config['archive_directory'].to_s.empty?
	          end
	        end
        end
      end
    end
    
    private
    def __sent_structure(tool_structure, source)
      # EXECUTES ALL BULK ANALYSES
      @analyses.select {|a| a.class.superclass == Analysis::Interface::Bulk}.each {|a| tool_structure[:issues] = a._analyse(tool_structure[:issues])}
      # SEND EACH ISSUE INDIVIDUALLY TO THE SERVER
      # THE "source" STRUCTURE CONTAINS A TUPLE WITH (CLIENT_ID, PROJECT_ID)
      response = tool_structure[:issues].collect do |issue|
        # EXECUTES ALL INDIVIDUAL ANALYSES
        @analyses.select {|a| a.class.superclass == Analysis::Interface::Individual}.each {|a| issue = a._analyse(issue)}

        # SEND THE MSG WITH THE ISSUE
        source['tool_name'] = @config['tool_name']
        ret = @comm.send_msg(Parse::Writer::Conviso.build_xml(issue, source))
        if @config['xmpp']['importer_address'] =~ /validator/
          msg = @comm.receive_msg
          ret = false

          if msg =~ /\[OK\]/
            @debug.info('VALIDATOR - THIS MESSAGE IS VALID')
          else
            @debug.info('VALIDATOR - THIS MESSAGE IS INVALID')
          end
        end
        
        ret
      end
      
      # JUST IN CASE THE RESPONSE ARRAY COMES EMPTY
      response = response + [true]
      
      # IF ALL ISSUES WERE SUCCESSFULLY SENT TO THE SERVER RETURN TRUE
      response.inject{|a,b| a & b}
    end
    
    #TODO: Criar classes de excecões para todos esses erros
    def __validate_configuration
      
      # VALIDATES IF INPUT DIRECTORIES FOR ALL SOURCES
      @config['sources'].each do |s|
        if !Dir.exists?(s['input_directory'].to_s)
	        @debug.error("Input directory #{s['input_directory']} does not exist.")
	        @config['sources'].delete(s['input_directory'].to_s)
        end
      end
      
      # VALIDATES THE ARCHIVE DIRECTORY
      if !@config['archive_directory'].nil? && !Dir.exists?(@config['archive_directory'].to_s)
	      @debug.error('Archive directory does not exist.')
	      exit
      end
    end
    
    def __scan_input_directory(source)
      @debug.info("Pooling input directory ...")
      files = Dir.glob(File.join(source['input_directory'], '*.xml'))
      @debug.info("##{files.size} files were found.")
      return files
    end

    def __parse_file (xml_file = '')
      @debug.info("Parsing xml file [#{xml_file}].")
      parse = Parse::DOM::Wapiti.new()  
      parse.parse_file(xml_file)
    end
    
    def __archive_file (zip_file = '')
      @debug.info("Archiving xml file [#{zip_file}].")
      FileUtils.mv(zip_file, @config['archive_directory'])
    end
    
    def __compress_file (xml_file = '')
      @debug.info("Compressing xml file [#{xml_file}].")
      zip_file_name = xml_file + ".zip"
      File.unlink(zip_file_name) if File.exists?(zip_file_name)
      zip = Zip::ZipFile.new(zip_file_name, true)
      zip.add(File.basename(xml_file), xml_file)
      zip.close
      File.unlink(xml_file)
      return zip_file_name
    end
    
  end
end

# Creating an instance of Drone::NewTool Object
drone = Drone::Wapiti.new(configuration, debug, analysis_modules)
debug.info("Starting #{configuration['plugin_name']} Drone ...")
drone.run
