Rails.application.routes.draw do
  get '/cheeses/:id', to: 'cheeses#show'
end
