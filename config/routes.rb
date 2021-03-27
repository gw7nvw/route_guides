
require 'resque/server'

RouteGuides::Application.routes.draw do
  get "password_resets/new"
  get "password_resets/edit"
  get "password_reset/new"
  get "password_reset/edit"
mount Resque::Server.new, at: "/resque"
resources :comments
resources :account_activations, only: [:edit]
resources :address_auths, only: [:edit]
resources :users
resources :photos
resources :parks, only: [:edit, :show, :index]
resources :routes
resources :reports
resources :beenthere, only: [:new]
resources :sessions, only: [:new, :create, :destroy]
resources :links, only: [:create, :destroy]
resources :places
resources :catchments
resources :maps, only: [:index]
resources :trips
resources :history, only: [:index, :show, :update]
resources :messages, only: [:index, :show, :update]
resources :forums, only: [:index, :show, :update, :approve, :destroy]
resources :password_resets, only: [:new, :create, :edit, :update]

#controller :places do
#    post 'places/:id' => :redisplay
#end

root 'static_pages#home'
  match '/sessions', to: 'static_pages#home',    via:'get'
  match '/comments/page_index', to: 'comments#page_index',    via:'get'
  match '/forums', to: 'forums#update',    via:'post'
  match '/forums/approve', to: "forums#approve", via: 'post'
  match '/forums/destroy', to: "forums#destroy", via: 'post'
  match '/comments/approve', to: "comments#approve", via: 'post'
  match '/comments/destroy', to: "comments#destroy", via: 'post'
  match '/messages', to: 'messages#update',    via:'post'
  match '/trips/move', to: 'trips#move', via: 'post'
  get 'beenthere/delete', to: 'beenthere#delete'
  get 'trips/:id/delete', to: 'trips#delete'
  get 'trips/:id/copy', to: 'trips#copy'
  get 'trips/:id/move', to: 'trips#move'
  get 'users/:id/beenthere', to: 'users#beenthere'
  match '/places/select', to: 'places#select', via: 'post'
  match '/routes/find', to: 'routes#find', via: 'post'
  match '/addtrip', to: 'routes#addtrip', via: 'get'
  match '/adj_route', to: 'places#adj_route', via: 'get'
  match '/find', to: 'search#find', via: 'get'
  match '/find', to: 'search#findresults', via: 'post'
  match '/search', to: 'search#search', via: 'get'
  match '/search', to: 'search#searchresults', via: 'post'
  match '/wishlist', to: 'trips#wishlist', via: 'get'
  match '/drafts', to: 'users#drafts', via: 'get'
  match '/currenttrip', to: 'trips#currenttrip', via: 'get'
  match '/redisplay', to: 'places#redisplay',    via:'post'
  match '/legs',    to: 'routes#leg_index',     via:'get'
  match '/site_index',    to: 'routes#site_index',     via:'get'
  match '/signup',  to: 'users#new',            via: 'get'
  match '/signin',  to: 'sessions#new',         via: 'get'
  match '/signout', to: 'sessions#destroy',     via: 'delete'
  match '/about',   to: 'static_pages#about',   via: 'get'
  match '/reload',   to: 'static_pages#reload',   via: 'get'
  match 'layerswitcher', to: "maps#layerswitcher", via: 'get'
  match 'print', to: "maps#print", via: 'get'
  match 'legend', to: "maps#legend", via: 'get'
  match '/styles.js', to: "maps#styles", via: 'get', as: "styles", defaults: { format: "js" }
  match '/sitemap.xml', to: 'sitemaps#index', via: 'get', as: "sitemap", defaults: { format: "xml" }
  match '/hb_extract.xml', to: 'extracts#index_brief', via: 'get', as: "extract", defaults: { format: "xml" }
  match '/hb_extract_full.xml', to: 'extracts#index_full', via: 'get', as: "extract_full", defaults: { format: "xml" }
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
#   resources :posts, concerns: :toggleable
#   resources :photos, concerns: :toggleable

# Example resource route within a namespace:
#   namespace :admin do
#     # Directs /admin/products/* to Admin::ProductsController
#     # (app/controllers/admin/products_controller.rb)
#     resources :products
end
