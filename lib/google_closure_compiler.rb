require "rexml/document"
require "app/helpers/google_closure_helper" 

require 'google_closure_compiler/javascript'

ActionView::Base.send :include, GoogleClosureHelper

# Adapted from Smurf plugin http://github.com/thumblemonks/smurf/
if Rails.version =~ /^2\.2\./
  # Support for Rails >= 2.2.x
  module GoogleClosureCompiler

    module JavaScriptSources
    private
      def joined_contents; GoogleClosureCompiler::Javascript.new(super).compiled; end
    end # JavaScriptSources

  end # GoogleClosureCompiler
  ActionView::Helpers::AssetTagHelper::JavaScriptSources.send(
    :include, GoogleClosureCompiler::JavaScriptSources)
else
  # Support for Rails <= 2.1.x
  module ActionView::Helpers::AssetTagHelper
  private
    def join_asset_file_contents_with_compilation(files)
      content = join_asset_file_contents_without_compilation(files)
      if !files.grep(%r[/javascripts]).empty?
        content = GoogleClosureCompiler::Javascript.new(content).compiled
      end
      content
    end
    alias_method_chain :join_asset_file_contents, :compilation
  end # ActionView::Helpers::AssetTagHelper
end

module GoogleClosureCompiler
  class << self
    attr_accessor :compilation_level, :compiler_application_path, :java_path, :closure_library_path
    def configure
      yield self
    end
    
    def compiler_application_path
      @compiler_application_path || File.join(File.dirname(__FILE__), '..', 'bin', 'compiler.jar')
    end
  
    def compilation_level
      @compilation_level || 'SIMPLE_OPTIMIZATIONS'
    end
    
    def java_path
      @java_path || 'java'
    end
    
    def closure_library_path
      @closure_library_path || 'closure'
    end
    
    def closure_library_full_path
      File.join(RAILS_ROOT, 'public', 'javascripts', closure_library_path)
    end
  end
end