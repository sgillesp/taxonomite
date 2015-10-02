
require 'factory_girl_rails'
require 'faker'

FactoryGirl.define do

  factory :taxonomite_node, :class => 'Taxonomite::Node' do
    # nodes are nameless now
  end

  factory :taxonomite_taxon, :class => 'Taxonomite::Taxon' do
    name { Faker::Lorem.word.capitalize }
  end

  factory :taxonomite_species, :class => 'Taxonomite::Species' do
    name { "#{Faker::Lorem.word.capitalize} #{Faker::Lorem.word}" }
  end

  factory :taxonomite_genus, :class => 'Taxonomite::Genus' do
    name { "#{Faker::Lorem.word.capitalize}" }
  end

  factory :taxonomite_family, :class => 'Taxonomite::Family' do
    name { "#{Faker::Lorem.word.capitalize}" }
  end

  factory :taxonomite_order, :class => 'Taxonomite::Order' do
    name { "#{Faker::Lorem.word.capitalize}" }
  end

  factory :taxonomite_class, :class => 'Taxonomite::Class' do
    name { "#{Faker::Lorem.word.capitalize}" }
  end

  factory :taxonomite_phylum, :class => 'Taxonomite::Phylum' do
    name { "#{Faker::Lorem.word.capitalize}" }
  end

  factory :taxonomite_kingdom, :class => 'Taxonomite::Kingdom' do
    name { "#{Faker::Lorem.word.capitalize}" }
  end

  factory :taxonomite_down_taxonomy, :class => 'Taxonomite::Taxonomy' do
    down_taxonomy { { 'kingdom' => 'phylum', 'phylum' => 'class', 'class' => 'order',
          'order' => 'family', 'family' => 'genus', 'genus' => 'species' } }
  end

  factory :taxonomite_up_taxonomy, :class => 'Taxonomite::Taxonomy' do
    up_taxonomy { { 'kingdom' => 'phylum', 'phylum' => 'class', 'class' => 'order',
          'order' => 'family', 'family' => 'genus', 'genus' => 'species' }.invert }
  end

  factory :taxonomite_empty_taxonomy, :class => 'Taxonomite::Taxonomy' do
  end

  factory :taxonomite_single_wildcard_taxonomy, :class => 'Taxonomite::Taxonomy' do
    down_taxonomy { { 'kingdom' => '*', 'phylum' => 'class' } }
  end

  factory :single_taxonomy_with_multiple, :class => 'Taxonomite::Taxonomy' do
    down_taxonomy { { 'kingdom' => [ "phylum", "class", "order" ] } }
  end


end
