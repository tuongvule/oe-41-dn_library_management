Rails.application.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
    resources :books
    root to: "static_pages#home"
    get "static_pages/list_books"

    get "sessions/login"
    post "sessions/login" ,to: "sessions#create"
    delete "sessions/logout", to: "sessions#destroy"
    get "sessions/sign_up"

    resources :users do
        resources :borrowing_books
    end
    post "destroy_request", to: "borrowing_book#destroy_request"
  end
end
