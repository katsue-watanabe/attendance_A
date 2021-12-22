Rails.application.routes.draw do
  root 'static_pages#top'
  get 'static_pages/top'
  get '/signup', to: 'users#new'
end