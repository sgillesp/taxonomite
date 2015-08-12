
require 'faker'

FactoryGirl.define do
  factory :taxonomite_node, :class => 'Taxonomite::Node' do
    name { Faker::Lorem.word.capitalize }
    description { Faker::Lorem.paragraph }
  end

  factory :taxonomite_species, :class => 'Taxonomite::Species' do
    name { "#{Faker::Lorem.word.capitalize} #{Faker::Lorem.word}" }
    description { Faker::Lorem.paragraph }
  end

  factory :taxonomite_genus, :class => 'Taxonomite::Genus' do
    name { "#{Faker::Lorem.word.capitalize} #{Faker::Lorem.word}" }
    description { Faker::Lorem.paragraph }
  end

  factory :taxonomite_family, :class => 'Taxonomite::Family' do
    name { "#{Faker::Lorem.word.capitalize} #{Faker::Lorem.word}" }
    description { Faker::Lorem.paragraph }
  end

  factory :taxonomite_order, :class => 'Taxonomite::Order' do
    name { "#{Faker::Lorem.word.capitalize} #{Faker::Lorem.word}" }
    description { Faker::Lorem.paragraph }
  end

  factory :taxonomite_class, :class => 'Taxonomite::Class' do
    name { "#{Faker::Lorem.word.capitalize} #{Faker::Lorem.word}" }
    description { Faker::Lorem.paragraph }
  end

  factory :taxonomite_phylum, :class => 'Taxonomite::Phylum' do
    name { "#{Faker::Lorem.word.capitalize} #{Faker::Lorem.word}" }
    description { Faker::Lorem.paragraph }
  end

  factory :taxonomite_kingdom, :class => 'Taxonomite::Kingdom' do
    name { "#{Faker::Lorem.word.capitalize} #{Faker::Lorem.word}" }
    description { Faker::Lorem.paragraph }
  end

end
