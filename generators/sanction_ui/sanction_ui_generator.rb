class SanctionUiGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      # Copy all sub-dirs into app that can be overridden when files
      # with same rel paths are dropped in
      #
      require 'find'
      Find.find("#{SanctionUi.plugin_base_path}/app/views", "#{SanctionUi.plugin_base_path}/app/assets") do |path|
        if FileTest.directory?(path)
          if File.basename(path)[0] == ?.
            Find.prune       # Don't look any further into this directory.
          else
            final_target = SanctionUi.override_base_path + '/' + path.gsub(/^#{SanctionUi.plugin_base_path}\//,'')
            m.directory final_target
          end
        end
      end
      m.file 'sanction_ui_overrides/README.txt', "#{SanctionUi.override_base_path}/README.txt"
    end
  end
end
