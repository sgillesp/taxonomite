
require 'faker'
require 'factory_girl_rails'

FactoryGirl.define do
  factory :taxonomite_beingrep, :class => 'Taxonomite::BeingRep' do
    name { Faker::Lorem.word.capitalize }
  end

  factory :taxonomite_genusrep, :class => 'Taxonomite::GenusRep' do
    name { Faker::Lorem.word.capitalize }
  end

end
