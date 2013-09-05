Dater
=====

Convert a period of time expressed in a literal way like 'in 2 days' to a formatted future date with a given format. It aims to be helpful in regression tests when you have to deal with dinamic dates.

You can also, convert dates from 'dd/mm/yyyy' to 'yyyy-mm-dd' or viceversa.

If you want to pass a formatted date like dd/mm/yyyy to convert to yyyy-mm-dd, you have to take care about only two things with the argument:

	- Year number must have four digits.

	- Month number must be always in the middle.

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

#To get the converted date:

	date.for("in 2 days") # => yyyy-mm-dd (date for 2 days from the date of today)
	date.for("in 10 months") # => yyyy-mm-dd (date for 10 months from the date of today)
	date.for("in 1 year") # => yyyy-mm-dd (date for 1 year from the date of today)

	date.for("today") # => yyyy-mm-dd (date of today)

	date.for("tomorrow") # => yyyy-mm-dd (date of tomorrow)

	date.for("yesterday") # => yyyy-mm-dd (date of yesterday)

If the argument is nil, it will return the date of today.

You'll find format directives at following link:

http://apidock.com/ruby/Time/strftime

It does not work correctly with leap-years and calculates months of 30 days only.

==================================================

Si deseas usar esta gema en español puedes inicializar la clase de la siguiente manera:

	date=Dater::Resolver.new('%Y-%m-%d', "en")

Con eso puedes pasar argumentos en idioma español (por ejemplo 'en 2 días', 'en 10 meses', 'en 1 año')

==================================================

Se você quiser usar esta gem em Português, você pode inicializar a classe da seguinte forma:

	date=Dater::Resolver.new('%Y-%m-%d', "pt")

Com isso você pode passar argumentos em Português (em dois dias, em 10 meses, 1 ano)
## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
