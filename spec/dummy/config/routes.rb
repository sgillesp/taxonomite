
include Taxonomite

Rails.application.routes.draw do
  resources :taxonomite

  get 'taxonomite/breakparent/:id' => 'taxonomite#breakparent', as: 'taxon_breakparent'
  get 'taxonomite/addchild/:id' => 'taxonomite#addchild', as: 'taxon_addchild'
  get 'taxonomite/remchild/:id' => 'taxonomite#remchild', as: 'taxon_remchild'
end
