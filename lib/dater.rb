# encoding: utf-8
require 'date'

require_relative 'translator'

module Dater
  
	class Resolver
		
		attr_accessor :format, :last_date


		# Creates a Dater::Resolver object
		#
		# @param [String] format = date format | Format : "%Y-%m-%dT%H:%M:%SZ"
		# @param [String] lang = languaje for matching (en=english, es=spanish, pt=portuguese)
		# @param [Boolean] today_for_nil = Indicates if must return today's date if given argument is nil
		def initialize(format='%Y-%m-%d', lang="en", today_for_nil=false)
			@today_for_nil=today_for_nil
			@format=format
			@translate=Dater::Translator.new(lang) 
		end



		# Convert the period of time passed as argument to the configured format
		#
		# @param [String] period = a period of time expreseed in a literal way to convert to the configured format (@format)
		# @return [String] converted date to the configured format. If period is nil and @today_for_nil is true, returns date for tomorrow. Else returns nil
		def for(period=nil)
			if period.nil? or period == ""
				period = now.strftime(@format) if today_for_nil
				return period
			else
				translated = @translate.this period
 				@last_date = time_for_period(translated)
 				@last_date = @last_date.getgm if utc?
				@last_date.strftime(@format)
			end
		end

		# Spanish and portuguese equivalent for 'for' method
		# 
		def para(period)
			self.for(period)
		end

		def lang= lang
			@translate=Dater::Translator.new(lang) 
		end

		def utc?
			@utc
		end

		def use_utc!
			@utc = true
		end

		def utc= boolean=false
			if [true,false].include? boolean
				@utc = boolean
			else
				raise "utc= must be boolean"
			end
		end

		private 


		TIME_IN_SECONDS = {
			minute: 60,
			hour: 3600,
			day: 86400,
			week: 604800,
			month: 2592000,
			year: 31536000
		}

		WEEKDAYS 	= [	"sunday",	"monday", "tuesday", "wednesday", "thursday", "friday", "saturday"]

		

		# Returns the formatted date according to the given period of time expresed in a literal way
		# 
		# @param [String] period = time expressed literally (e.g: in 2 days)
		# @return [String] formatted time
		def time_for_period(string=nil)
			
			
			@last_date = case string
			
			when /today/,/now/
				now

			when /tomorrow/
				tomorrow_time

			when /yesterday/
				yesterday_time

			when /sunday/, /monday/, /tuesday/, /wednesday/, /thursday/, /friday/, /saturday/ 				
				time_for_weekday(string)

			when /next/
				now + period_of_time_from_string(string.gsub("next","1"))

			when /last/
				now - period_of_time_from_string(string.gsub("last","1"))				

			when /\d[\sa-zA-Z]+\sbefore/
				@last_date ||= now 
				@last_date -=  period_of_time_from_string(string)

			when /\d[\sa-zA-Z]+\sago/
				@last_date  ||= now 
				now - period_of_time_from_string(string)

			when /\d[\sa-zA-Z]+\slater/
				@last_date ||= now
				@last_date +=  period_of_time_from_string(string)

			when /in/,/\d\sminutes?/,/\d\shours?/,/\d\sdays?/, /\d\smonths?/, /\d\sweeks?/, /\d\syears?/
				now + period_of_time_from_string(string)

			when /\d+.\d+.\d+/
				time_from_date(string)	

			when /rand/,/future/
				now + rand(100_000_000)

			when /past/
				now - rand(100_000_000)
			end
				
				return @last_date
		end
		
		# Returns now time
		# @return [Time] @last_date = today's time
		def now
			@last_date=Time.now
		end

		def yesterday_time
			@last_date = Time.now - TIME_IN_SECONDS[:day]
		end

		def tomorrow_time
			@last_date = Time.now + TIME_IN_SECONDS[:day]
		end

		
		# Returns one week/month/year of difference from today's date. Formatted or not according to formatted param
		#
		# @param [String] period = the factor of difference (day, week, month, year) from today's date
		# @return [Time]
		def next(period)
			Time.now + multiply_by(period)
		end

		# Returns one week/month/year of difference from today's date. Formatted or not according to formatted param
		#
		# @param [String] period = the factor of difference (day, week, month, year) from today's date
		# @return [Time]
		def last(period)
			Time.now - multiply_by(period)
		end

		# Returns the number of seconds for the given string to add or substract according to argument
		# If argument has the word 'last' it goes backward, else forward
		def move_to(word)
			word.scan(/last/i).size>0 ? self.last(word) : self.next(word)
		end

		def time_for_weekday(word)
			day = extract_day_from word
			@count = Time.now
			begin
				@count+= move_a_day(word)
			end until is_required_day?(@count, day)
			@count
		end

		def extract_day_from word
			WEEKDAYS.select{ |day| day if day==word.scan(/[a-zA-Z]+/).last }.join
		end

		# Method to know if the day is the required day
		# 
		# @param [Time] time
		# @param [String] day = to match in case statement
		# @return [Boolean] = true if day is the required day
		def is_required_day?(time, day)
			day_to_ask = "#{day}?"
			result = eval("time.#{day_to_ask}") if time.respond_to? day_to_ask.to_sym
			return result
		end

		# Return a day to add or substrac according to the given word
		# Substract if word contains 'last' word
		# @return +/-[Fixnum] time in seconds for a day (+/-)
		def move_a_day(word)
			word.scan(/last/i).size > 0 ? a_day_backward : a_day_forward
		end

		# Returns the amount in seconds for a day (positive)
		def a_day_forward
			TIME_IN_SECONDS[:day]
		end

		# Returns the amount in seconds for a day (negative)
		def a_day_backward
			-TIME_IN_SECONDS[:day]
		end

		# Scans if period has day hour
		# 
		# @param [String] period 
		# @return [Boolean] true if perdiod contains the word hour
		def is_hour?(period)
			period.scan(/hour/i).size > 0
		end

		# Multiplication factor for a day
		# 
		# @param [String] period 
		# @return [Fixnum] multiplication factor for a day
		def hour_mult(period)
			TIME_IN_SECONDS[:hour] if is_hour? period		 
		end

		# Scans if period has day minute
		# 
		# @param [String] period 
		# @return [Boolean] true if perdiod contains the word minute
		def is_minute?(period)
			period.scan(/minute/i).size > 0
		end

		# Multiplication factor for a day
		# 
		# @param [String] period 
		# @return [Fixnum] multiplication factor for a day
		def minute_mult(period)
			TIME_IN_SECONDS[:minute] if is_minute? period		 
		end

		# Scans if period has day word
		# 
		# @param [String] period 
		# @return [Boolean] true if perdiod contains the word day
		def is_day?(period)
			period.scan(/day/i).size > 0
		end

		# Multiplication factor for a day
		# 
		# @param [String] period 
		# @return [Fixnum] multiplication factor for a day
		def day_mult(period)
			TIME_IN_SECONDS[:day] if is_day? period		 
		end

		# Scans if period has week word
		# 
		# @param [String] period 
		# @return [Boolean] true if perdiod contains the word week
		def is_week?(period)
			period.scan(/week/i).size > 0
		end

		# Multiplication factor for a week
		# 
		# @param [String] period 
		# @return [Fixnum] multiplication factor for a week
		def week_mult(period)
			TIME_IN_SECONDS[:week] if is_week? period
		end

		# Scans if period has month word
		# 
		# @param [String] period 
		# @return [Boolean] true if perdiod contains the word month
		def is_month?(period)
			period.scan(/month/).size > 0
		end
		
		# Multiplication factor for a month
		# 
		# @param [String] period 
		# @return [Fixnum] multiplication factor for a month
		def month_mult(period)
			TIME_IN_SECONDS[:month] if is_month? period
		end

		# Scans if period string contain year word
		# 
		# @param [String] period to scan
		# @return [Boolean] true if perdiod contains the word year
		def is_year?(period)
			period.scan(/year/i).size > 0
		end

		# Multiplication factor for a year
		# 
		# @param [String] period = the string to convert to
		# @return [Fixnum] multiplication factor for a year
		def year_mult(period)
			TIME_IN_SECONDS[:year] if is_year? period
		end

		# Returns seconds to multiply by for the given string
		# 
		# @param [String] period = the period of time expressed in a literal way
		# @return [Fixnum] number to multiply by
		def multiply_by(string)
			return minute_mult(string) || hour_mult(string) || day_mult(string) || week_mult(string) || month_mult(string) || year_mult(string) || 1
		end
	
		

		# Return the Time object according to the splitted date in the given array  
		# 
		# @param [String] date
		# @return [Time] 
		def time_from_date(date)
			numbers=date.scan(/\d+/).map!{|i| i.to_i}
			day=numbers[2-numbers.index(numbers.max)]
			Date.new(numbers.max,numbers[1],day).to_time 
		end

		
		# Returns the time according to the given string
		#
		# @param [String] word = period of time in literal way
		# @return [Fixnum] multiplication factor (seconds)
		def period_of_time_from_string(word)
			word.scan(/\d+/)[0].to_i * multiply_by(word)
		end

		# Try to convert Missing methods to string and call to for method with converted string
		# 
		# 
		def method_missing(meth)
			self.class.send :define_method, meth do
				string = meth.to_s.gsub("_"," ")
				self.for("for('#{string}')")
			end
			begin
				self.send(meth.to_s)
			rescue
				raise "Method does not exists (#{meth})."
			end
		end

	end
end
