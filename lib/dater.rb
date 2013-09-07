# coding: utf-8
require 'date'
require_relative "dater/version"

module Dater
  
	class Resolver
		
		attr_accessor :format, :lang

		DICTIONARY = {
			day:  		{ "en"=>/day(s)?/, 	"es" => /d(i|í)a(s)?/,"pt" => /dia(s)?/},
			week: 		{ "en"=>/week(s)?/, "es" => /semana(s)?/, "pt" => /semana(s)?/},
			month: 		{ "en"=>/month(s)?/,"es" => /mes(es)?/, 	"pt" => /mes(es)?/},
			year: 		{ "en"=>/year(s)?/, "es" => /año(s)?/, 		"pt" => /ano(s)?/},
			today: 		{ "en"=>'today', 		"es" => 'hoy', 				"pt" => 'hoje'},
			tomorrow: { "en"=>'tomorrow', "es" => 'mañana',			"pt" => 'manhã'},
			yesterday:{ "en"=>'yesterday',"es" => 'ayer', 			"pt" => 'ontem'}
		}

		# Creates a Dater::Resolver object
		#
		# Param [String] format = date format
		# Param [String] lang = languaje for matching (en=english, es=spanish, pt=portuguese)
		def initialize(format='%Y-%m-%d', lang="en")
			@format=format
			@lang=lang if ["en","es","pt"].include? lang
		end

		# Convert the period of time passed as argument to the configured format
		#
		# Param [String] period = a period of time like "in 3 days" or "in 10 months" or "in 2 years". It could be a formatted date to convert to the wanted format
		# Return [String] converted date to the configured format. If period is nil, returns date for tomorrow 
		def for(period=nil)
			return (Time.now).strftime(@format) if period.nil?
			case period.downcase 	
			when DICTIONARY[:today][@lang]
				return (Time.now).strftime(@format)
			when DICTIONARY[:tomorrow][@lang]
				return (Time.now+(3600*24)).strftime(@format)
			when DICTIONARY[:yesterday][@lang]
				return (Time.now-(3600*24)).strftime(@format)
			when /\d+\/\d+\/\d+/
				parts=period.split('/')
			when /\d+\-\d+\-\d+/
				parts=period.split('-')
			when /\d+/
				@date=Time.now+period.scan(/\d+/)[0].to_i*self.multiply_by(period,@lang)
			else
				return period
			end
			@date=time_from_date(parts) unless parts.nil?
			return @date.strftime(@format)
		end

		# Set true the matched keyword in a given string
		# 
		# Param [String] period = the period of time expressed in a literal way
		# Param [String] lang = the languaje to eval
		# Return [Hash] times
		def multiply_by(period, lang)
			day=3600*24
			return day 				if period.scan(DICTIONARY[:day][lang]).size>0
			return day*7			if period.scan(DICTIONARY[:week][lang]).size>0
			return day*30			if period.scan(DICTIONARY[:month][lang]).size>0
			return day*30*12	if period.scan(DICTIONARY[:year][lang]).size>0
			return 1
		end

		# Return the Time object according to the splitted date in the given array  
		# 
		# Param [Array] date = date splitted
		# Return [Time] 
		def time_from_date(date)
			date.map!{|i| i.to_i}
			if date.first.to_s.size==4
				return Date.new(date[0],date[1],date[2]).to_time
			else
				return Date.new(date[2],date[1],date[0]).to_time
			end
		end

		def para(period)
			self.for(period)
		end
	end
end
