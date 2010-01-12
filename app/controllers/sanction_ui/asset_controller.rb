# This serves up static assets
# it interpolates css files through erb first
#
class SanctionUi::AssetController < SanctionUi::TopLevelController
  # Skip all authorization requirements here
  skip_filter filter_chain
  # This is used to serve up all css, js, and images--you could override
  # it in perms_manager_controller in your app if you wanted to
  #
  def show    
    if params[:relative_path].blank?
      render :text => "You must specify a relative path to vendor/plugins/perms_manager/app/assets/",
             :status => 404 and return
    else
      @relative_path = params[:relative_path].join('/')
      @full_path = "#{SanctionUi.plugin_base_path}/app/assets/#{@relative_path}"
      @overridden_path = "#{SanctionUi.asset_override_base_path}/#{@relative_path}"      
      @file_extention = params[:relative_path].last.split('.').last
      @mime_type = case @file_extention
        when 'gif':
          'image/gif'
        when 'jpg':
          'image/jpeg'
        when 'png':
          'image/png'
        when 'css':
          'text/css'
        when 'html':
          'text/html'
        when 'js':
          'text/javascript'
        else
          render :text => "Invalid type #{@file_extention}", :status => 404 and return
      end
      
      # Use the overriden file first if it exists
      #
      if File.file? @overridden_path
        @the_file_path = @overridden_path
      elsif File.file? @full_path
        @the_file_path = @full_path        
      else
        render :text => "File does not exist.",
               :status => 404 and return
      end
      
      # allows utilization of view helpers to interpolate
      #
      if @file_extention == 'css'
        render :file => @the_file_path
      else
        send_file @the_file_path, :type => @mime_type, :disposition => 'inline'
      end
    end
  end
end