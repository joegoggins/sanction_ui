class SanctionUiGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.directory "app/views/sanction_ui"
      m.directory "public/sanction_ui_asset_overrides"
      m.directory "public/sanction_ui_asset_overrides/images"
      m.directory "public/sanction_ui_asset_overrides/js"
      m.directory "public/sanction_ui_asset_overrides/css"
      m.file 'public/sanction_ui_asset_overrides/README.txt', "public/sanction_ui_asset_overrides/README.txt"
    end
  end
end
