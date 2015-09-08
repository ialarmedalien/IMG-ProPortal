{
# configuration file for development environment

# the logger engine to use
# console: log messages to STDOUT (your console where you started the
#          application server)
# file:    log message to a file in log/
	logger => "console",

# the log level for this environment
# core is the lowest, it shows Dancer2's core log messages as well as yours
# (debug, info, warning and error)
	log => "core",

# should Dancer2 consider warnings as critical errors?
	warnings => 1,

# should Dancer2 show a stacktrace when an error is caught?
# if set to yes, public/500.html will be ignored and either
# views/500.tt, 'error_template' template, or a default error template will be used.
	show_errors => 1,

# print the banner
	startup_info => 1,

	# home of css, js, images folders. Should end with "/"
	pp_assets => "https://img-proportal-dev.jgi-psf.org/proportal/",
	# URL of the ProPortal app
	pp_app => "https://img-proportal-dev.jgi-psf.org/proportal/",

	# main.cgi location
	main_cgi_url => 'http://localhost:5000/cgi-bin/main.cgi',
	base_url => 'http://localhost:5000',

	engines => {
		template => {
			template_toolkit => {
				INCLUDE_PATH => 'views:views/pages:views/layouts:views/inc:public',
				RELATIVE => 1,
			}
		}
	},

	googlemapsapikey => 'AIzaSyDrPC70YP1ZyZT-YIFXnol96In-3LKbn7w',

	db => {
		version_year => "Version 4.3 January 2014",
		server_name => "Server name",
		build_date => "Build date",
	},

	plugins => {
		Database => {
			dsn => 'dbi:SQLite:dbname=:memory:',
			connection_check_threshold => 0.001,
			dbi_params => {
				RaiseError => 1,
				on_connect_do => [
					"SET NAMES 'utf8'",
					"SET CHARACTER SET 'utf8'"
				],
			},
			log_queries => 1,
		},
	}
}
