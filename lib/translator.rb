# encoding: utf-8

module Dater
  
	class Translator

		SUPPORTED_LANGUAGES = ["en","es","pt"]
		
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

		def initialize(lang)
			raise "Languaje #{lang} not supported" unless SUPPORTED_LANGUAGES.include? lang
			@lang = lang
			@dictionary = @lang == "es" ? SPANISH : PORTUGUESE
		end

		def this word
			return word if @lang=="en"
			mapper word
		end

		def mapper word
			word.split(" ").map do |word|
				get_english_for word				
			end.join(" ")
		end
		
		def get_english_for word
			@dictionary.each_pair do |k,v|
				return k.to_s if word =~ v
			end
			word
		end




		# def english_for(word=nil)
			
		# 	case @lang
		# 	when "es"
		# 		spanish_translator word				
		# 	when "pt"
		# 		portuguese_translator word
		# 	else
		# 		word
		# 	end
		# end

		# def spanish_translator word
		# 	word.split(" ").map do |word|
		# 		translate_from_spanish word				
		# 	end.join(" ")
		# end
		
		# def translate_from_spanish word
		# 	SPANISH.each_pair do |k,v|
		# 		return k.to_s if word =~ v
		# 	end
		# 	word
		# end

		# def portuguese_translator word
		# 	word.split(" ").map do |word|
		# 		translate_from_portuguese word				
		# 	end.join(" ")
		# end

		# def translate_from_portuguese word
		# 	PORTUGUESE.each_pair do |k,v|
		# 		return k.to_s if word =~ v
		# 	end
		# 	word
		# end


	end
end