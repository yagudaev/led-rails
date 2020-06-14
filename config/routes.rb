Rails.application.routes.draw do
  resource :setting
  root 'settings#show'
end
