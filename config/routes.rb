RouteGuides::Application.routes.draw do
resources :users
resources :routes
resources :reports
resources :sessions, only: [:new, :create, :destroy]
resources :places
resources :maps, only: [:index]
resources :trips
resources :history, only: [:index, :show, :update]
resources :messages, only: [:index, :show, :update]
resources :forums, only: [:index, :show, :update]
#controller :places do
#    post 'places/:id' => :redisplay
#end

root 'static_pages#home'
  match '/messages', to: 'messages#update',    via:'post'
  match '/forums', to: 'forums#update',    via:'post'
  match '/trips/move', to: 'trips#move', via: 'post'
  match '/routes/find', to: 'routes#find', via: 'post'
  match '/routes/many', to: 'routes#many', via: 'post'
  match 'search', to: 'routes#search', via: 'get'
  match '/wishlist', to: 'trips#wishlist', via: 'get'
  match '/currenttrip', to: 'trips#currenttrip', via: 'get'
  match '/redisplay', to: 'places#redisplay',    via:'post'
  match '/legs',    to: 'routes#leg_index',     via:'get'
  match '/site_index',    to: 'routes#site_index',     via:'get'
  match '/signup',  to: 'users#new',            via: 'get'
  match '/signin',  to: 'sessions#new',         via: 'get'
  match '/signout', to: 'sessions#destroy',     via: 'delete'
  match '/about',   to: 'static_pages#about',   via: 'get'
  match '/disclaimer', to: 'static_pages#disclaimer', via: 'get'
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
