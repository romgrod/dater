# coding: utf-8
require 'date'
require_relative "dater/version"

module Dater
  
	class Resolver
		
		attr_accessor :format, :lang

		DICTIONARY = {
			day:  		{ "en"=>/day/, 			"es" => /(dia|día)/,  "pt" => /dia/, 	:mult =>	86400},
			week: 		{ "en"=>/week/, 		"es" => /semana/, 		"pt" => /semana/, :mult =>	604800},
			month: 		{ "en"=>/month/,		"es" => /mes/, 				"pt" => /mes/, 	:mult =>  2592000},
			year: 		{ "en"=>/year/, 		"es" => /año/, 				"pt" => /ano/, 	:mult =>  31536000},
			today: 		{ "en"=>'today', 		"es" => 'hoy', 				"pt" => 'hoje' 	},
			tomorrow: { "en"=>'tomorrow', "es" => 'mañana',			"pt" => 'manhã' 	},
			yesterday:{ "en"=>'yesterday',"es" => 'ayer', 			"pt" => 'ontem' 	}
		}

		# Creates a Dater::Resolver object
		#
		# @param [String] format = date format
		# @param [Boolean] today_for_nil = Indicates if must return today'd date if argument in for method is nil
		# @param [String] lang = languaje for matching (en=english, es=spanish, pt=portuguese)
		def initialize(format='%Y-%m-%d', today_for_nil=false, lang="en")
			@today_for_nil=today_for_nil
			@format=format
			@lang=lang if ["en","es","pt"].include? lang
		end

		# Convert the period of time passed as argument to the configured format
		#
		# @param [String] period = a period of time like "in 3 days" or "in 10 months" or "in 2 years". It could be a formatted date to convert to the wanted format
		# @return [String] converted date to the configured format. If period is nil, returns date for tomorrow 
		def for(period=nil)
			if period.nil?
				return  @today_for_nil ? (Time.now).strftime(@format) : nil
			end
			@date=case period.downcase 	
			when DICTIONARY[:today][@lang]
				self.today(false)
			when DICTIONARY[:tomorrow][@lang]
				self.tomorrow(false)
			when DICTIONARY[:yesterday][@lang]
				self.yesterday(false)
			when /\d+.\d+.\d+/
				time_from_date(period)	
			when /\d+\s.+/
				Time.now+period.scan(/\d+/)[0].to_i*multiply_by(period)
			else
				return period
			end
			 # unless parts.nil?
			return @date.strftime(@format)
		end

		# Spanish for 'for' method
		#
		#
		def para(period)
			self.for(period)
		end

		# Returns the time for today
		#
		# @param [Boolean] formatted = indicates if has to return today time in configured format
		# @return [Time] today's time (formatted or not)
		def today(formatted=true)
			time=Time.now
			time=time.strftime(@format) if formatted
			time
		end

		# Spanish for today method
		def hoy
			self.today(true)
		end

		# Portuguese for today method
		#
		#
		def hoje
			self.today(true)
		end

		# Returns the time for yesterday.
		# 
		# @param [Boolean] formatted = indicates if has to return the value in configured format
		# @return [Time] time for yesterday (formatted or not)
		def yesterday(formatted=true)
			time = one_day_diff(false)
			time = time.strftime(@format) if formatted
			time
		end

		# Spanish for yesterday method
		#
		#
		def ayer
			self.yesterday(true)
		end

		# Portuges for yesterday method
		#
		#
		def ontem
			self.yesterday(true)
		end


		# Returns time value for tomorrow. Formated or not according to formatted param
		#
		# @param [Boolean] formatted = if true time is returned with format
		#
		def tomorrow(formatted=true)
			time = one_day_diff(true)
			time=time.strftime(@format) if formatted
			time
		end

		# Spanish for tomorrow method
		#
		# 
		def mañana
			self.tomorrow(true)
		end

		# Portugues for tomorrow method
		#
		#
		def manhã
			self.tomorrow(true)
		end

		# Return one day of difference. One day more or less according to plus param. It is used by tomorrow and yesterday methods
		#
		# @param [Boolean] plus = if true, return one day more, else one day before
		# @return [Time]
		def one_day_diff(plus=true)
			time=Time.now
			diff = DICTIONARY[:day][:mult]
			plus ? time+diff : time-diff
		end

	private

		# Scans if period has day word
		# 
		# @param [String] period = a string to convert to configured format
		# @return [Boolean] true if perdiod contains the word day
		def is_day?(period)
			true if period.scan(DICTIONARY[:day][@lang]).size > 0
		end

		# Multiplication factor for a day
		# 
		# @param [String] period = the string to convert to
		# @return [Fixnum] multiplication factor for a day
		def day_mult(period)
			DICTIONARY[:day][:mult] if is_day?(period)			 
		end

		# Scans if period has week word
		# 
		# @param [String] period = a string to convert to configured format
		# @return [Boolean] true if perdiod contains the word week
		def is_week?(period)
			true if period.scan(DICTIONARY[:week][@lang]).size > 0
		end

		# Multiplication factor for a week
		# 
		# @param [String] period = the string to convert to
		# @return [Fixnum] multiplication factor for a week
		def week_mult(period)
			DICTIONARY[:week][:mult] if is_week?(period)
		end

		# Scans if period has week month
		# 
		# @param [String] period = a string to convert to configured format
		# @return [Boolean] true if perdiod contains the word month
		def is_month?(period)
			true if period.scan(DICTIONARY[:month][@lang]).size > 0
		end
		
		# Multiplication factor for a month
		# 
		# @param [String] period = the string to convert to
		# @return [Fixnum] multiplication factor for a month
		def month_mult(period)
			DICTIONARY[:month][:mult] if is_month?(period)
		end

		# Scans if period has week year
		# 
		# @param [String] period = a string to convert to configured format
		# @return [Boolean] true if perdiod contains the word year
		def is_year?(period)
			true if period.scan(DICTIONARY[:year][@lang]).size > 0
		end

		# Multiplication factor for a year
		# 
		# @param [String] period = the string to convert to
		# @return [Fixnum] multiplication factor for a year
		def year_mult(period)
			DICTIONARY[:year][:mult] if is_year?(period)
		end


		# Set true the matched keyword in a given string
		# 
		# @param [String] period = the period of time expressed in a literal way
		# @param [String] lang = the languaje to eval
		# @return [Hash] times
		def multiply_by(period)
			return day_mult(period) || week_mult(period) || month_mult(period) || year_mult(period) || 1
		end

		
		# Return the Time object according to the splitted date in the given array  
		# |
		# @param [Array] date = date splitted
		# @return [Time] 
		def time_from_date(date)
			numbers=date.scan(/\d+/).map!{|i| i.to_i}
			day=numbers[2-numbers.index(numbers.max)]
			Date.new(numbers.max,numbers[1],day).to_time 
		end
	end
end