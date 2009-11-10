module GoogleClosureCompiler
  class Request
    attr_accessor :code_url

    def initialize(content)
      @content = content
      @request = Net::HTTP::Post.new('/compile', 'Content-type' => 'application/x-www-form-urlencoded')
    end
    
    def send
      params = {
        'compilation_level' => GoogleClosureCompiler.compilation_level,
        'output_format' => 'xml',
        'output_info' => 'compiled_code'
      }
      if @code_url
        params['code_url'] = @code_url
      else
        params['js_code'] = @content
      end
      @request.set_form_data(params)
      begin
        res = Net::HTTP.new('closure-compiler.appspot.com', 80).start {|http| http.request(@request) }
        case res
        when Net::HTTPSuccess
          GoogleClosureCompiler::Response.new(res.body)
        else
          GoogleClosureCompiler::Response.new
        end
      rescue
        GoogleClosureCompiler::Response.new
      end
    end

  end # Request
end # GoogleClosureCompiler
