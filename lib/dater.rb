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


		TIME_IN_SECONDS = {
			day: 86400,
			week: 604800,
			month: 2592000,
			year: 31536000
		}

		WEEKDAYS 	= [	"sunday",	"monday", "tuesday", "wednesday", "thursday", "friday", "saturday"]

		PORTUGUESE = {
			day:/dia/,
			week:/semana/,
			month:/mes/,
			year:/ano/,
			today:/hoje/,
			tomorrow:/amanhã/,
			yesterday:/ontem/,
			in:/em/,
			next:/prox/,
			later:/depois/,
			ago:/atras/, 
			before:/antes/,
			monday:/segunda/,
			tuesday:/terca/,
			wednesday:/quarta/,
			thursday:/quinta/,
			friday:/sexta/,
			saturday:/sabado/,
			sunday:/domingo/,
			rand:/acaso/,
			futura:/futur/,
			past:/passad/
		}

		SPANISH = {
			day:/dia/,
			week:/semana/,
			month:/mes/,
			year:/año/,
			today:/hoy/,
			tomorrow:/mañana/,
			yesterday:/ayer/,
			in:/en/,
			next:/prox/,
			later:/despues/,
			ago:/atras/,
			before:/antes/,
			monday:/lunes/,
			tuesday:/martes/,
			wednesday:/miercoles/,
			thursday:/jueves/,
			friday:/viernes/,
			saturday:/sabado/,
			sunday:/domingo/,
			rand:/aleator/,
			future:/futur/,
			past:/pasad/
		}

		def english_for(word=nil)
			unless word.nil?
				word = no_special_chars(word.downcase)
			end
			case @lang
			when "es"
				spanish_translator word				
			when "pt"
				portuguese_translator word
			else
				word
			end
		end

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
			
			@last_date = case word.downcase
			
			when /today/,/now/
				now

			when /tomorrow/
				tomorrow_time

			when /yesterday/
				yesterday_time

			when /sunday/, /monday/, /tuesday/, /wednesday/, /thursday/, /friday/, /saturday/ 				
				time_for_weekday(word)

			when /next/
				now + period_of_time_from_string(word.gsub("next","1"))

			when /last/
				now - period_of_time_from_string(word.gsub("last","1"))				

			when /\d[\sa-zA-Z]+\sbefore/
				@last_date ||= now 
				@last_date -=  period_of_time_from_string(word)

			when /\d[\sa-zA-Z]+\sago/
				@last_date  ||= now 
				now - period_of_time_from_string(word)

			when /\d[\sa-zA-Z]+\slater/
				@last_date ||= now
				@last_date +=  period_of_time_from_string(word)

			when /in/,/\d\sdays?/, /\d\smonths?/, /\d\sweeks?/, /\d\syears?/
				now + period_of_time_from_string(word)

			when /\d+.\d+.\d+/
				time_from_date(word)	

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
			arg.gsub(/(á|Á)/, 'a').gsub(/(é|É)/, 'e').gsub(/(í|Í)/, 'i').gsub(/(ó|Ó)/, 'o').gsub(/(ú|Ú)/, 'u').gsub(/(ç|Ç)/, 'c')
		end
	end
end
