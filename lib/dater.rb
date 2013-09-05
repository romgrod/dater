# coding: utf-8
require_relative "dater/version"

module Dater
  
	class Resolver
		
		# Creates a Dater::Resolver object
		#
		# Param [String] format = date format
		# Param [String] lang = languaje for matching (en=english, es=spanish, pt=portuguese)
		def initialize(format='%Y-%m-%d', lang="en")
			@format=format
			@lang=lang
		end

		# Convert the period of time passed as argument to the configured format
		#
		# Param [String] period = a period of time like "in 3 days" or "in 10 months" or "in 2 years". It could be a formatted date to convert to the wanted format
		# Return [String] converted date to the configured format 
		def for(period)
			return (Time.now+(3600*24)).strftime(@format) if period.nil?
			if period.include?('/')
				date=period.split('/')
				return date.join('-') if date[0].size==4
				return "#{date[2]}-#{date[1]}-#{date[0]}"
			elsif period.include?('-')
				date=period.split('-')
				return date.join('-') if date[0].size==4
				return "#{date[2]}-#{date[1]}-#{date[0]}"
			elsif (amount=period.scan(/\d+/)).size>0
				case @lang
				when 'es'
					days=true if period.scan(/dia(s)?/).size>0
					months=true if period.scan(/mes(es)?/).size>0
					year=true if period.scan(/año(s)?/).size>0
				when 'en'
					days=true if period.scan(/day(s)?/).size>0
					months=true if period.scan(/month(s)?/).size>0
					year=true if period.scan(/year(s)?/).size>0
				when 'pt'
					days=true if period.scan(/dia(s)?/).size>0
					months=true if period.scan(/mes(es)?/).size>0
					year=true if period.scan(/ano(s)?/).size>0
				end	
				if year
					multiply_by=3600*24*30*12
				elsif months
					multiply_by=3600*24*30
				else
					multiply_by=3600*24
				end
				additional=amount[0].to_i*multiply_by
				@date=Time.now+additional
				@date=@date.strftime(@format)			
			else
				return period
			end
			return @date
		end
	end
end
