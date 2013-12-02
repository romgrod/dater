<a href="https://codeclimate.com/repos/522a36ddf3ea0037550215e4/feed"><img src="https://codeclimate.com/repos/522a36ddf3ea0037550215e4/badges/776a40c87545905e8195/gpa.png" /></a>

Dater
=====

Convert a period of time expressed in a literal way like 'in 2 days' to a formatted future date with a given format. It aims to be helpful in regression tests when you have to deal with dinamic dates.

You can also, convert dates from 'dd/mm/yyyy' to 'yyyy-mm-dd' or viceversa.

If you want to pass a formatted date like dd/mm/yyyy to convert to yyyy-mm-dd, you have to take care about only two things with the argument:

1. Year number must have four digits.

2. Month number must be always in the middle.

## Installation

Add this line to your application's Gemfile:

    gem 'dater'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dater

## Usage

	#Require gem

	require 'dater'

	#Initialize a dater object with a format to convert to:

	date=Dater::Resolver.new('%Y-%m-%d')

	# Look at the initiliza that we pass the working date format ('%Y-%m-%d'). This will be the returned date formate in every methods.

	#To get the converted date:

	# date.for(String) 

	=begin
	String could be:
	"in 4 days" # => yyyy-mm-dd (date for 4 days from the date of today)

	"in 2 weeks" 		# => yyyy-mm-dd (date for 2 weeks from the date of today)

	"in 10 months" 	# => yyyy-mm-dd (date for 10 months from the date of today)

	"in 1 year" 		# => yyyy-mm-dd (date for 1 year from the date of today)

	"today" 				# => yyyy-mm-dd (date of today)

	"tomorrow" 			# => yyyy-mm-dd (date of tomorrow)

	"yesterday" 		# => yyyy-mm-dd (date of yesterday)

	"next monday" 	# => yyyy-mm-dd (next monday date from the date of today).

	"next week" 		# => yyyy-mm-dd (adds a period of time for a week and returns the result date)

	"next month" 		# => yyyy-mm-dd (Same for 'next week but adding a period of time for a month')

	"next year" 		# => yyyy-mm-dd (Same for next month adding the period of time for a year)

	"<a_week_day>" 	# => a_week_day: sunday, monday, thuesday and so on. (It Works as 'next monday')

	Some equivalent methods you can use

	date.today
	date.tomorrow
	date.yesterday
	date.next_day
	date.next_week
	date.next_month
	date.next_year
	date.next_sunday
	date.next_monday
	date.next_thuesday
	date.next_wednesday
	date.next_thursday
	date.next_friday
	date.next_saturday
	date.sunday
	date.monday
	date.thuesday
	date.wednesday
	date.thursday
	date.friday
	date.saturday
  =end

Special feature:
	
	later and ago

	Giving the keywords 'later' or 'ago' at the end of the string, Dater allows you to request dates from the last date requested. If there isn't any date requested previously, it takes as last requested date today's date

	date.for("2 days later") # => You will get the date for two days later from the last requested date.

	Example: Supose that the last requested date was 10/12/2013 (dd/mm/YYYY), using '2 days later' will give the result '12/12/2013'. 

	date.for("1 month ago") # => You will get the date for one month ago from the last requested date.

If the argument is nil, it will return nil. But you can initialize Dater object with 'today_for_nil' flag like:

	date = Dater::Resolver.new("%Y-%m-%d", true)

	date.for #=> yyyy-mm-dd (date of today)

You'll find format directives at following link:

http://apidock.com/ruby/Time/strftime

It does not work correctly with leap-years and calculates months of 30 days only.

==================================================

Si deseas usar esta gema en español puedes inicializar la clase de la siguiente manera:

	date=Dater::Resolver.new('%Y-%m-%d', false "es")

Con eso puedes pasar argumentos en idioma español (por ejemplo 'en 2 días', 'en 10 meses', 'en 1 año')

==================================================

Se você quiser usar esta gem em Português, você pode inicializar a classe da seguinte forma:

	date=Dater::Resolver.new('%Y-%m-%d', "pt")

Com isso você pode passar argumentos em Português (em 2 dias, em 10 meses, 1 ano)
## Contributing


All methods are performed to work with the supported languages: English, Spanish and Portuguese.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
