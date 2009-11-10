module GoogleClosureCompiler
  class Javascript

    def initialize(content)
      @content = content
    end

    def compiled
      if compiler_cli_installed?
        save_content_to_file
        out_file = File.join(RAILS_ROOT, 'public', 'javascripts', 'google_closure_compiler_tmp_output.js')
        options = {
          :js => content_file_path,
          :js_output_file => out_file,
          :compilation_level => GoogleClosureCompiler.compilation_level,
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
          save_content_to_file
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
      output = `#{GoogleClosureCompiler.java_path} -jar #{GoogleClosureCompiler.compiler_application_path} --helpshort`
      output.include?('Usage: java [jvm-flags...] com.google.javascript.jscomp.CompilerRunner [flags...] [args...]')
    end
    
    def save_content_to_file
      File.open(content_file_path, 'w+') { |file| file.write @content }
    end
    
    def content_file_path
      File.join(RAILS_ROOT, 'public', 'javascripts', 'google_closure_compiler_tmp.js')
    end
    
    def hash_to_options(hash)
      hash.collect{ |key, value| "--#{key} #{value}" }.join(' ')
    end

  end # Javascript
end # GoogleClosureCompiler
