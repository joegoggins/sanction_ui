ActionController::Routing::Routes.draw do |map|
  map.namespace :sanction_ui do |sanction_ui|
    sanction_ui.root :controller => 'main'
    sanction_ui.describe "describe", :controller => 'main', :action => 'describe'
    sanction_ui.asset "asset/*relative_path", :controller => 'asset', :action => 'show'
    sanction_ui.resources :roles,
      :only => [:index, :new, :create, :destroy]
  end
  # for css, js, and images
#  map.asset "agents/asset/*relative_path", :controller => 'perms_manager_asset', :action => 'show'
#  map.resources :agents, 
#                :only => [:index, :new, :create, :destroy], 
#                :member => {:disable => :get, :activate => :get, :expire => :get, :update_expire => :put},
#                :collection => {:filtered => :post } do |agent|
#    agent.resources :global_roles, :only => [:new, :create, :destroy]
#    agent.resources :permissionable_roles, :only => [:new, :create, :destroy]
#  end
end
