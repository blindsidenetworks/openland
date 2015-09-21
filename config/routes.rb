Rails.application.routes.draw do
  devise_for :users
  scope "/admin" do
    resources :users
  end
  get 'users/me'

  get 'welcome/index'
  get 'about', to: 'welcome#about'
  get 'contact', to: 'welcome#contact'
  get 'welcome/landing'

  get "dashboard", to: 'dashboard#index'
  get 'dashboard/index'

  get 'settings/index'

  resources :rooms

  get    'bbb/enter/:id', to: 'bbb#enter', as: :bbb_room_enter
  get    'bbb/room/:id', to: 'bbb#room_status', as: :bbb_room_status
  delete 'bbb/room/:id', to: 'bbb#room_close', as: :bbb_room_close
  get    'bbb/meetings/:id', to: 'bbb#meeting_list'
  get    'bbb/meeting/:id', to: 'bbb#meeting_info'
  delete 'bbb/meeting/:id', to: 'bbb#meeting_end'
  get    'bbb/recordings/:id', to: 'bbb#recording_list'
  get    'bbb/recording/:id', to: 'bbb#recording_info'
  patch  'bbb/recording/:id', to: 'bbb#recording_publish'
  delete 'bbb/recording/:id', to: 'bbb#recording_delete'
  get    'bbb/close'

  get ':landing_id', to: 'welcome#landing'
  get ':landing_id/:room_id', to: 'welcome#landing'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#index'

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
