Rails.application.routes.draw do
  root 'welcome#index'

  get 'welcome/index' => "welcome#index"

  # user authentication
  get 'users/signup' => 'users#signup_form', as: :signup
  post 'users/signup' => 'users#signup'
  get 'users/signin' => 'users#signin_form', as: :signin
  post 'users/signin' => 'users#signin'
  post 'users/signout' => 'users#signout', as: :signout
  get 'users/:id' => 'users#show', as: :show_user

  # item type
  get 'item_types/suggestions'

  # tag
  get 'tags/suggestions'

  # expense entry
  get 'expense_entries/create' => 'expense_entries#create_form',
    as: :create_expense_entry
  post 'expense_entries/create' => 'expense_entries#create'

  # expense report
  get 'expense_reports/criteria_form' => 'expense_reports#criteria_form',
    as: :expense_report_form
  get 'expense_reports/aggregate_by_day' => 'expense_reports#aggregate_by_day',
    as: :create_expense_report

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
