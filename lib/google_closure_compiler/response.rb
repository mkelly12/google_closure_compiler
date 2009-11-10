module GoogleClosureCompiler
  class Response

    def initialize(response=nil)
      @doc = REXML::Document.new(response)
    end
    
    def success?
      @doc.root && @doc.root.elements['serverErrors'].nil?
    end
    
    def compiled_code
      @doc.root.elements['compiledCode'].text
    end
    
    def file_too_big?
      @doc.root && @doc.root.elements["serverErrors/error[@code='8']"] != nil
    end

  end # Response
end # GoogleClosureCompiler
