
include Taxonomite

Rails.application.routes.draw do
  resources :taxonomite

  get 'taxonomite/breakparent/:id' => 'taxonomite#breakparent', as: 'node_breakparent'
  get 'taxonomite/addchild/:id' => 'taxonomite#addchild', as: 'node_addchild'
  get 'taxonomite/remchild/:id' => 'taxonomite#remchild', as: 'node_remchild'
end
