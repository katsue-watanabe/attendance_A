Rails.application.routes.draw do
  get 'static_pages/top'
  root 'static_pages#top'
end