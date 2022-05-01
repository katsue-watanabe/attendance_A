Rails.application.routes.draw do
  
  root 'static_pages#top'
  get '/signup', to: 'users#new'

  # ログイン機能
  get    '/login', to: 'sessions#new'
  post   '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  resources :users do
    collection {post :import}    
    member do      
      get 'attendances/edit_one_month'
      patch 'attendances/update_one_month' 
      get 'list_of_employees'     
    end
    resources :attendances do
      member do 
        get 'edit_overwork'
        patch 'update_overwork'
      end
    end
  end
  
  resources :bases
end