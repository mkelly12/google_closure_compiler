# GoogleClosureCompiler

Makes integrating the Google JavaScript Compiler with your Rails deployment process dead simple. [Read why compressing your JavaScript is important](http://www.zurb.com/article/311/shrink-your-javascript-with-the-google-compiler-rails-plugin)

Both the Google Closure Compiler API and Application are supported. Sensible defaults are provided.

## Installing the plugin

	script/plugin install git://github.com/mkelly12/google_closure_compiler.git
	
## Requirements

Any version of Rails `2.x`; including Rails `2.3.4` and `2.1.2`.

## So how does it work?

[Read how this integrates with your workflow](http://www.zurb.com/article/311/shrink-your-javascript-with-the-google-compiler-rails-plugin)

The plugin uses the Google Closure Compiler to optimize JavaScript files cached by Rails.

Anytime you use the `javascript_include_tag` with the `:cache => true` or `:cache => 'bundle_name'` the resulting JavaScript file will be compiled. [Read more about Rails asset caching](http://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#M001713)

You will also need this in your production.rb (and in your development.rb only when testing):

	config.action_controller.perform_caching = true

Keep in mind that cached files are saved to your public directory and only generated when needed. If you forget to delete them in the development environment they can lead to some serious headaches. It's a good practice to use a naming scheme like `'cache/bundle_name'` so you can easily remove the cached files and add ignore rules to your version control.

## How does it work with the Google Closure Compiler?

There are three ways to integrate with the Google Closure Compiler which are attempted in the following order: 

1. If you have the Closure Compiler Application properly installed (yes we check this) then that is always used. 
2. If the Application is not detected then the API is used with your JavaScript embeded in the POST data. 
3. If your JavaScript file is larger then POST data will allow then a link to your JavaScript is sent to the API. If your host is not specified or not reachable by the Google service then no compilation is performed.

### Application

The preferred method is to use the [compile.jar](http://closure-compiler.googlecode.com/files/compiler-latest.zip) file which is included in this plugin.

You will need the Java Runtime Environment version 6.

If you are on OS X with the latest updates you will need to specify the path to the 1.6 JRE since `/usr/bin/java` still point to 1.5.

Add the following to `/config/google_closure_compiler.yml`

	development:
		java_path: '/System/Library/Frameworks/JavaVM.framework/Versions/1.6/Commands/java'

### API with code in request

You don't need anything besides an outgoing internet connection. However you JavaScript needs to fit in the POST data.

### API with code urls

This works well if your server is accessible to the world and you specified your host name using the following:

	config.action_mailer.default_url_options = { :host => HOST_NAME }
	
The only limitation is that cached JavaScript files larger then 500k cannot be processed with this method.

## Using the Google Closure Library

If you are using the Google Closure Library use the following view helper to include your Closure JavaScript:

	closure_include_tag "wooly_zurbian.js"
	
In this example `wooly_zurbian.js` is a JavaScript file in `/public/javascripts/`.

This helper inserts the Google Closure Library base.js and events.js scripts when `perform_caching` is false. When `perform_caching` is true these files are not required since they are added using the `calcdeps.py` script.

The Google Closure Library is required and is assumed to be in `public/javascripts/closure`. If you put it somewhere else in `/public/javascripts` specify the relative path from `/public/javascripts/` using `closure_library_path` in `google_closure_compiler.yml`. 

The `wooly_zurbian.js` script is inserted and cached in `/public/javascripts/cache/closure/wooly_zurbian.js`.

## Using the Dependency Calculation Script

If any of your cached JavaScript files contain a call to `goog.require()` then that cached file will be expanded using the `calcdeps.py` script. This requires Python 2.4 or greater and the Google Closure Library (see Using the Google Closure Library).

`calcdeps.py` takes each `goog.require()` calls and replaces it with the required libraries. [Read more](http://code.google.com/closure/library/docs/calcdeps.html) about `calcdeps.py` and why it is important when using the Google Closure Library.

`ADVANCED_OPTIMIZATIONS` is used for the compilation of cached file that are expanded with `calcdeps.py` regardless of what is specified in the `/config/google_closure_compiler.yml` file.

## FAQ

#### Can I change the compilation level?
Yes, you can specify it in the `config/google_closure_compiler.yml` file.

	development:
		compilation_level: 'ADVANCED_OPTIMIZATIONS'
	
The default is `SIMPLE_OPTIMIZATIONS`. Other options are `WHITESPACE_ONLY` and `ADVANCED_OPTIMIZATIONS`.

Make sure you read the [documentation on Advanced Optimizations](http://code.google.com/closure/compiler/docs/api-tutorial3.html) before enabling them.

#### What happens if there is an error or the API is down?
If all compilation methods fail then the original JavaScripts are used in the bundles.

#### Does this play nice with Smurf?
It sure does. If you have [Smurf](http://gusg.us/code/ruby/smurf-rails-autominifying-js-css-plugin.html) installed then CSS minification works as expected and JavaScript files are processed by both [Smurf](http://gusg.us/code/ruby/smurf-rails-autominifying-js-css-plugin.html) and the Google Closure Compiler.

Copyright (c) 2009 Matt Kelly - [ZURB](http://www.zurb.com), released under the MIT license
