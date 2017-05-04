Rails.application.routes.draw do
  resources :articles
  get '/', to: "pages#welcome"
end
