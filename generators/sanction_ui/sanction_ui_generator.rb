class SanctionUiGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      SANCTION_UI_PLUGIN_BASE_PATH ||= "#{RAILS_ROOT}/vendor/plugins/sanction_ui"
      SANCTION_UI_OVERRIDE_BASE_PATH ||= "#{RAILS_ROOT}/app/plugins/sanction_ui"
      
=begin
      app/views/sanction_ui
        assets
        views

      SANCTION_UI_PLUGIN_BASE_PATH ||=       
      require 'find'
      Find.find('vendor/plugins/sanction-ui/app/assets', 'vendor/plugins/sanction-ui/app/views') do |path|
        if FileTest.directory?(path)
          if File.basename(path)[0] == ?.
            Find.prune       # Don't look any further into this directory.
          else
            puts "DIR #{path}"
          end
        end
      end
        
=end
      m.directory "app/views/sanction_ui"
      m.directory "public/sanction_ui_asset_overrides"
      m.directory "public/sanction_ui_asset_overrides/images"
      m.directory "public/sanction_ui_asset_overrides/js"
      m.directory "public/sanction_ui_asset_overrides/css"
      m.file 'public/sanction_ui_asset_overrides/README.txt', "public/sanction_ui_asset_overrides/README.txt"
    end
  end
end
