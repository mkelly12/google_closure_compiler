module GoogleClosureHelper
  
  def closure_include_tag(file_path)
    out = ''
    unless ActionController::Base.perform_caching
      closure_base_path = File.join(GoogleClosureCompiler.closure_library_path, 'goog')
      out << "<script src='#{File.join('/javascripts', closure_base_path, 'base.js')}' type='text/javascript'></script>"
      out << "<script type='text/javascript'>goog.require('goog.events');</script>"
    end
    out << javascript_include_tag(file_path, :cache => "cache/closure/#{file_path.delete('.js')}")
    out
  end

end