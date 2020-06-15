Rails.application.routes.draw do
  resource :setting, only: %i[edit update]
  root 'settings#edit'
end
