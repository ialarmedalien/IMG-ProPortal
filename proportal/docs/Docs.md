# IMG / ProPortal #

## Controllers and ProPortal Pages ##

Each of the ProPortal queries (clade, ecosystem, data type, etc.) is run by a controller (`ProPortal::Controller::<name>`) that pulls the relevant data, puts it into the appropriate format data structure, and then returns it. Most ProPortal controllers have two methods, `get_data` and `render`; `get_data` pulls the data from the database, and `render` does any data munging, etc., required for output.

## Templates and Template Structure ##

All ProPortal HTML content is stored in template files, held in `proportal/views/`.

Most pages use a template in `views/pages/` with a name that corresponds to the page ID; e.g. the `clade` page (ID `proportal/clade`) uses the template `pages/proportal/clade.tt`, etc. By default, pages use the wrapper `layouts/default.html.tt`, which adds the page header, footer, menus, breadcrumbs, etc., to the page. To specify a different wrapper, set the template variable `page_wrapper` to the appropriate layout.

Reusable page components are stored in `views/inc/`.

## Template Contents ##

Templates are sent query-specific data by the controller, plus a set of common information that is added before template rendering.

The following data is available in the templates:

results         data struct  query results

results.js      data struct  for those pages where the data should be accessible through JavaScript (e.g. for drawing graphs), using the wrapper `scripts/pageload_wrapper.tt` will dump the data structures in `results.js` and `data_filters` as JSON, available through the function `getJson()`.


navigation      data struct  data structure representing menus

sw_version      string       ProPortal software version (`$AppCore::VERSION`)
current_page    string       current page ID
no_sidebar      boolean      true if this page has no sidebar (optional)
breadcrumbs     boolean      true if breadcrumbs should be shown (optional)
server_name     string       host name
ora_service     string       $ENV{ORA_SERVICE}

link            function     generate internal links
ext_link        function     generate external links

page_wrapper    string       the page wrapper to be used (optional)

tmpl_includes   data struct  from controller; page-specific templates to be included

for filtered queries:

data_filters    data struct  filters for this query (optional)

data_filters.active          currently-active filter
data_filters.all             filter schema hashref

Automatically added by Dancer2:

perl_version    string       current version of perl, i.e. $^V.
dancer_version  string       current version of Dancer2, i.e. <Dancer2-VERSION>

settings        hash of the application configuration
session         current session data (if a session exists)
request         current request object
params          hash reference of all the parameters; i.e. $request->params
vars            list of request variables, i.e. result of calling the keyword `vars`