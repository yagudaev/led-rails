Rails.application.routes.draw do
  resource :setting, only: %i[show create edit update]
  root 'settings#edit'
end
