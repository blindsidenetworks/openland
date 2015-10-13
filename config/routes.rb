Rails.application.routes.draw do
  devise_for :users
  scope "/admin" do
    resources :users
  end
  get 'users/me'
  get 'users/me/edit', to: 'users#me_edit'

  get 'welcome/index'
  get 'about', to: 'welcome#about'
  get 'contact', to: 'welcome#contact'
  get 'welcome/landing'

  get "dashboard", to: 'dashboard#index'

  resources :rooms

  get    'bbb/enter/:id', to: 'bbb#enter', as: :bbb_room_enter
  post   'bbb/enter/:id', to: 'bbb#enter', as: :bbb_room_enter_post
  get    'bbb/room/:id', to: 'bbb#room_status', as: :bbb_room_status
  delete 'bbb/room/:id', to: 'bbb#room_close', as: :bbb_room_close
  get    'bbb/meetings/:id', to: 'bbb#meeting_list'
  get    'bbb/meeting/:id', to: 'bbb#meeting_info'
  delete 'bbb/meeting/:id', to: 'bbb#meeting_end'
  get    'bbb/recordings/:id', to: 'bbb#recording_list'
  patch  'bbb/recording/:room_id', to: 'bbb#recording_publish', as: :bbb_recording_publish
  delete 'bbb/recording/:room_id', to: 'bbb#recording_delete', as: :bbb_recording_delete
  get    'bbb/close'

  get ':landing_id', to: 'welcome#landing'
  get ':landing_id/:room_id', to: 'welcome#landing'

  root 'welcome#index'
end
