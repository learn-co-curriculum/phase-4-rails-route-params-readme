Rails.application.routes.draw do
  get '/cheeses', to: 'cheeses#index'
end
