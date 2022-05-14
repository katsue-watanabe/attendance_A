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
    resources :attendances, only: [:update] do
      member do
        # 残業申請 
        get 'edit_overwork'
        patch 'update_overwork'
        # 残業申請お知らせモーダル
        get 'edit_overwork_notice'
        patch 'update_overwork_notice'
      end
    end
  end
  
  resources :bases
end