module GoogleClosureCompiler
  class Javascript

    def initialize(content)
      @content = content
    end

    def compiled
      save_content_to_file
      expand_closure_dependencies if closure_require_statements_used?
      
      if compiler_cli_installed?
        out_file = File.join(RAILS_ROOT, 'public', 'javascripts', 'google_closure_compiler_tmp_output.js')
        options = {
          :js => content_file_path,
          :js_output_file => out_file,
          :compilation_level => closure_require_statements_used? ? 'ADVANCED_OPTIMIZATIONS' : GoogleClosureCompiler.compilation_level,
          :warning_level => 'QUIET',
          :summary_detail_level => '0',
          :third_party => 'true'
        }
        `#{GoogleClosureCompiler.java_path} -jar #{GoogleClosureCompiler.compiler_application_path} #{hash_to_options(options)}`
        content = $?.success? ? File.read(out_file) : @content
        File.delete content_file_path
        File.delete(out_file) if File.exists?(out_file)
        content
      else
        response = GoogleClosureCompiler::Request.new(@content).send
        if response.success?
          response.compiled_code
        elsif response.file_too_big? && ActionMailer::Base.default_url_options[:host]
          request = GoogleClosureCompiler::Request.new(@content)
          request.code_url = "http://#{ActionMailer::Base.default_url_options[:host]}/javascripts/google_closure_compiler_tmp.js"
          response = request.send
          File.delete content_file_path
          if response.success?
            response.compiled_code
          else
            @content
          end
        else
          @content
        end
      end
    end
    
    def compiler_cli_installed?
      return unless GoogleClosureCompiler.compiler_application_path
      debugger
      output = `#{GoogleClosureCompiler.java_path} -jar #{GoogleClosureCompiler.compiler_application_path} --helpshort`
      output.include?('Usage: java [jvm-flags...] com.google.javascript.jscomp.CompilerRunner [flags...] [args...]')
    end
    
    def save_content_to_file
      File.open(content_file_path, 'w+') { |file| file.write @content }
    end
    
    def content_file_path
      File.join(RAILS_ROOT, 'public', 'javascripts', 'google_closure_compiler_tmp.js')
    end
    
    def expanded_content_file_path
      "#{content_file_path}.expanded"
    end
    
    def hash_to_options(hash)
      hash.collect{ |key, value| "--#{key} #{value}" }.join(' ')
    end
    
    def closure_require_statements_used?
      @content.include?('goog.require')
    end
    
    def expand_closure_dependencies
      `#{GoogleClosureCompiler.python_path} #{closure_expand_script} -i #{content_file_path} -p #{GoogleClosureCompiler.closure_library_full_path} -o script > #{expanded_content_file_path}`
      if $?.success?
        File.delete(content_file_path)
        File.move(expanded_content_file_path, content_file_path)
        @content = File.read(content_file_path)
      else
        File.delete(expanded_content_file_path)
      end
    end
    
    def closure_expand_script
      File.join(GoogleClosureCompiler.closure_library_full_path, 'bin', 'calcdeps.py')
    end

  end # Javascript
end # GoogleClosureCompiler
