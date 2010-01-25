ActionController::Routing::Routes.draw do |map|
  map.namespace :sanction_ui, :path_prefix => SanctionUi.route_url_prefix do |sanction_ui|
    sanction_ui.root :controller => 'main'
    sanction_ui.describe "describe", :controller => 'main', :action => 'describe'
    sanction_ui.asset "asset/*relative_path", :controller => 'asset', :action => 'show'
    sanction_ui.access_denied "denied", :controller => 'access_denied', :action => 'show'
    sanction_ui.resources :roles,
      :only => [:index, :new, :create, :destroy]
  end
end
