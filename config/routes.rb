Rails.application.routes.draw do
  
  get 'errors/file_not_found'

  get 'errors/unprocessable'

  get 'errors/internal_server_error'

  # Note: Resource "faxes" removed at the moment, may be reinserted later. 
  # resources :faxes

  resources :subscriptions do
    get "create"
  end

  resources :companies, only: [:show, :edit, :update]

  devise_for :users, controllers: { sessions: 'users/sessions',  registrations: 'users/registrations', confirmations: 'users/confirmations' }

  resources :purchase_orders
  resources :vendors
  resources :addresses
  resources :settings
  resources :charges 

  resources :marketing


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  
	get '/pricing' => 'marketing#pricing'
	get '/features' => 'marketing#features'
  get '/login' => 'marketing#login'
  get '/signup' => 'marketing#signup'

	match '/404', to: 'errors#file_not_found', via: :all
	match '/422', to: 'errors#unprocessable', via: :all
	match '/500', to: 'errors#internal_server_error', via: :all

  # You can have the root of your site routed with "root"
  #http://stackoverflow.com/questions/3791096/devise-logged-in-root-route-rails-3
  authenticated :user do
    root 'purchase_orders#index', as: :authenticated_root
  end

  devise_scope :user do
    post "/users/confirmations" => "users/confirmations#resend_confirmation_email"
  end


  unauthenticated :user do
    devise_scope :user do 
      get '/' => 'marketing#index'
    end
  end
  
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
  #   end
end
