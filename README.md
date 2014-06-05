<a href="https://codeclimate.com/repos/522a36ddf3ea0037550215e4/feed"><img src="https://codeclimate.com/repos/522a36ddf3ea0037550215e4/badges/776a40c87545905e8195/gpa.png" /></a>

Dater
=====

Dater

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

    require 'dater'

    date=Dater::Resolver.new('%Y-%m-%d %H:%M')

    #date.for(String) 
    #Example:
    date.for("in 2 weeks")
    =begin
    String could be:

    "in 5 minutes"  # => yyyy-mm-dd hh:mm (date for 5 minutes from the timestamp of now)
    "in 2 hours"    # => yyyy-mm-dd hh:mm (date for 2 hours from the timestamp of now)
    "in 4 days"     # => yyyy-mm-dd hh:mm (date for 4 days from the date of today)
    "in 2 weeks"    # => yyyy-mm-dd hh:mm (date for 2 weeks from the date of today)
    "in 10 months"  # => yyyy-mm-dd hh:mm (date for 10 months from the date of today)
    "in 1 year"     # => yyyy-mm-dd hh:mm (date for 1 year from the date of today)
    "next day"      # => yyyy-mm-dd hh:mm (date for tomorrow from the date of today)
    "next week"     # => yyyy-mm-dd hh:mm (adds a period of time for a week and returns the date)
    "next month"    # => yyyy-mm-dd hh:mm (adds a period of time for a month and returns the date)
    "next year"     # => yyyy-mm-dd hh:mm (adds a period of time for a year and returns the date)
    "yesterday"     # => yyyy-mm-dd hh:mm (date of yesterday)
    "today"         # => yyyy-mm-dd hh:mm (date of today)
    "tomorrow"      # => yyyy-mm-dd hh:mm (date of tomorrow)
    "2 days ago"	# => yyyy-mm-dd hh:mm (N days ago from today)
    "3 weeks ago"	# => yyyy-mm-dd hh:mm (N weeks ago from today)
    "4 months ago"	# => yyyy-mm-dd hh:mm (N months ago from today)
    "1 year ago"	# => yyyy-mm-dd hh:mm (N year ago from today)

    #Some equivalent methods you can use:
    date.yesterday
    date.today
    date.tomorrow
    date.sunday
    date.monday
    date.thuesday
    date.wednesday
    date.thursday
    date.friday
    date.saturday
    date.next_day
    date.next_week
    date.next_month
    date.next_year
    =end

# Special feature

later and before

Giving the keywords 'later' or 'before' at the end of the string, Dater allows you to request dates from the last date requested. If there isn't any date requested previously, it takes as last requested date today's date

    date.for("2 days later") # => You will get the date for two days later from the last requested date.
Example: Supose that the last requested date was 10/12/2013 (dd/mm/YYYY), using '2 days later' will give the result '12/12/2013'. 

    date.for("1 month before") # => You will get the date for one month before from the last requested date.

If the argument is nil, it will return nil. But you can initialize Dater object with 'today_for_nil' flag like:

    date = Dater::Resolver.new("%Y-%m-%d", true)

    date.for #=> yyyy-mm-dd (date of today)

You'll find format directives at following link:

http://apidock.com/ruby/Time/strftime

It does not work correctly with leap-years and calculates months of 30 days only.


It supports following languages: English (lang='en'), Spanish (lang='es') and Portuguese (lang='pt')

***


Si deseas usar esta gema en español puedes inicializar la clase de la siguiente manera:

    fecha=Dater::Resolver.new('%Y-%m-%d', "es", false)
    fecha.para("en 1 semana")
    fecha.ayer
    fecha.hoy
    fecha.mañana


Con eso puedes pasar argumentos en idioma español (por ejemplo 'en 2 días', 'en 10 meses', 'en 1 año')


***

Se você quiser usar esta gem em Português, você pode inicializar a classe da seguinte forma:

    data=Dater::Resolver.new('%Y-%m-%d', "pt", false)
    data.para("em 2 dias")

## Contributor

Federico Hertzulis


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
