require 'spec_helper'
require 'models/taxonomite/zoology'

module Taxonomite
    RSpec.describe Tree, type: :model do
        describe 'enforce hierarchy' do
            context 'without Taxonomy object' do
                before(:each) do
                    @family = FactoryGirl.build(:taxonomite_family)
                    @genus = FactoryGirl.build(:taxonomite_genus)
                    @species = FactoryGirl.build(:taxonomite_species)
                end

                it 'to allow species in genus when no taxonomy present' do
                    expect { @genus.add_child(@species) }.not_to raise_error
                end

                it 'to allow genus in family when no taxonomy present' do
                    expect { @family.add_child(@genus) }.not_to raise_error
                end

                it 'to allow genus in species when no taxonomy present' do
                    expect { @species.add_child(@genus) }.not_to raise_error
                end

                it 'to allow species in family when no taxonomy present' do
                    expect { @family.add_child(@species) }.not_to raise_error
                end
            end

            context 'with Taxonomy object' do
              before(:each) do
                  @taxonomy = FactoryGirl.build(:taxonomite_taxonomy)
                  @family = FactoryGirl.build(:taxonomite_family)
                  @genus = FactoryGirl.build(:taxonomite_genus)
                  @species = FactoryGirl.build(:taxonomite_species)
              end

              it 'to allow species in genus with taxonomy present' do
                  expect { @genus.add_child(@species, @taxonomy) }.not_to raise_error
              end

              it 'to allow genus in family with taxonomy present' do
                  expect { @family.add_child(@genus, @taxonomy) }.not_to raise_error
              end

              it 'not to allow genus in species with taxonomy present' do
                  expect { @species.add_child(@genus, @taxonomy) }.to raise_error
              end

              it 'not to allow species in family with taxonomy present' do
                  expect { @family.add_child(@species, @taxonomy) }.to raise_error
              end
            end
      end
    end
end
