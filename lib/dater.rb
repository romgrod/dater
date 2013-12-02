# encoding: utf-8
require 'date'

module Dater
  
	class Resolver
		
		attr_accessor :format, :lang


		# Creates a Dater::Resolver object
		#
		# @param [String] format = date format
		# @param [String] lang = languaje for matching (en=english, es=spanish, pt=portuguese)
		# @param [Boolean] today_for_nil = Indicates if must return today's date if given argument is nil
		def initialize(format='%Y-%m-%d', lang="en", today_for_nil=false)
			@today_for_nil=today_for_nil
			@format=format
			@lang=lang if ["en","es","pt"].include? lang 
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
 				@last_date = @date = time_for_period(period)
				@date.strftime(@format) if @date.respond_to? :strftime
			end
		end

		# Spanish and portuguese equivalent for 'for' method
		# 
		def para(period)
			self.for(period)
		end


		private 

		PORTUGUESE = {
			day:/dia/i,
			week:/semana/i,
			month:/mes/i,
			year:/ano/i,
			today:/hoje/,
			tomorrow:/amanhã/i,
			yesterday:/ontem/i,
			in:/em/i,
			next:/prox/i,
			later:/depois/i,
			ago:/atras/i, 
			before:/antes/i,
			monday:/segunda/i,
			tuesday:/terca/i,
			wednesday:/quarta/i,
			thursday:/quinta/i,
			friday:/sexta/i,
			saturday:/sabado/i,
			sunday:/domingo/i
		}

		SPANISH = {
			day:/dia/i,
			week:/semana/i,
			month:/mes/i,
			year:/año/i,
			today:/hoy/i,
			tomorrow:/mañana/i,
			yesterday:/ayer/i,
			in:/en/i,
			next:/prox/i,
			later:/despues/i,
			ago:/atras/i,
			before:/antes/i,
			monday:/lunes/i,
			tuesday:/martes/i,
			wednesday:/miercoles/i,
			thursday:/jueves/i,
			friday:/viernes/i,
			saturday:/sabado/i,
			sunday:/domingo/i
		}

		TIME_IN_SECONDS = {
			day: 86400,
			week: 604800,
			month: 2592000,
			year: 31536000
		}

		WEEKDAYS 	= [	"sunday",	"monday", "tuesday", "wednesday", "thursday", "friday", "saturday"]

		def spanish_translator word
			word.split(" ").map do |word|
				translate_from_spanish word				
			end.join(" ")
		end
		
		def translate_from_spanish word
			SPANISH.each_pair do |k,v|
				return k.to_s if word =~ v
			end
			word
		end

		def portuguese_translator word
			word.split(" ").map do |word|
				translate_from_portuguese word				
			end.join(" ")
		end

		def translate_from_portuguese word
			PORTUGUESE.each_pair do |k,v|
				return k.to_s if word =~ v
			end
			word
		end

		# Returns the formatted date according to the given period of time expresed in a literal way
		# 
		# @param [String] period = time expressed literally (e.g: in 2 days)
		# @return [String] formatted time
		def time_for_period(period=nil)
			word = english_for no_special_chars(period)
			
			@last_date = case word
			
			when /today/i
				now

			when /tomorrow/i
				tomorrow_time

			when /yesterday/i
				yesterday_time

			when /sunday/i, /monday/i, /tuesday/i, /wednesday/i, /thursday/i, /friday/i, /saturday/i 				
				time_for_weekday(word)

			when /next/i
				now + period_of_time_from_string(word.gsub("next","1"))

			when /last/i
				now - period_of_time_from_string(word.gsub("last","1"))				

			when /before/i
				@last_date ||= now 
				@last_date -=  period_of_time_from_string(word)

			when /ago/i
				@last_date  ||= now 
				now - period_of_time_from_string(word)

			when /later/i
				@last_date ||= now
				@last_date +=  period_of_time_from_string(word)

			when /in/i
				now + period_of_time_from_string(word)

			when /day/i, /month/i, /week/i, /year/i
				move_to(word)

			when /\d+.\d+.\d+/
				time_from_date(word)	
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

		def english_for(word=nil)
			unless word.nil?
				word = no_special_chars(word.downcase)
			end
			case @lang
			when /es/,/sp/
				spanish_translator word				
			when /pt/,/port/
				portuguese_translator word
			else
				word
			end
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
			day = WEEKDAYS.select{ |day| day if day==word.scan(/[a-zA-Z]+/).last }.join
			@count = Time.now
			
			# Add one day if today is the same required week day 
			@count += move_a_day(word) if is_required_day?(@count, day)
			
			until is_required_day?(@count, day)
				@count+= move_a_day(word)
			end
			@count

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
			TIME_IN_SECONDS[:day] if is_day?(english_for period)		 
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
			TIME_IN_SECONDS[:week] if is_week?(english_for period)
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
			TIME_IN_SECONDS[:month] if is_month?(english_for period)
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
			TIME_IN_SECONDS[:year] if is_year?(english_for period)
		end

		# Returns seconds to multiply by for the given string
		# 
		# @param [String] period = the period of time expressed in a literal way
		# @return [Fixnum] number to multiply by
		def multiply_by(period)
			return day_mult(period) || week_mult(period) || month_mult(period) || year_mult(period) || 1
		end
	
		# Method to know if the day is the required day
		# 
		# @param [Time] time
		# @param [String] day = to match in case statement
		# @return [Boolean] = true if day is the required day
		def is_required_day?(time, day)
			case english_for(day).to_s
			when /monday/i
				time.monday? 
			when /tuesday/i
				time.tuesday? 
			when /wednesday/i
				time.wednesday? 
			when /thursday/i
				time.thursday? 
			when /friday/i
				time.friday? 
			when /saturday/i
				time.saturday? 
			when /sunday/i
				time.sunday? 
			else
				false
			end
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
			# if meth.to_s =~ /^(next_|próximo_|proximo_|last_|último_|ultimo_|in_|\d_|for).+$/i
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

		def no_special_chars(arg)
			arg.\
			gsub('á', 'a').\
			gsub('é', 'e').\
			gsub('í', 'i').\
			gsub('ó', 'o').\
			gsub('ú', 'u').\
			gsub('ç', 'c').\
			gsub('Á', 'a').\
			gsub('É', 'e').\
			gsub('Í', 'i').\
			gsub('Ó', 'o').\
			gsub('Ú', 'u').\
			gsub('Ñ', 'n').\
			gsub('Ç', 'c')
		end
	end
end
