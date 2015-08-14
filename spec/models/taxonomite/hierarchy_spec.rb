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
                    expect { @genus.children << @species }.not_to raise_error
                end

                it 'to allow genus in family when no taxonomy present' do
                    expect { @family.children << @genus }.not_to raise_error
                end

                it 'to allow genus in species when no taxonomy present' do
                    expect { @species.children << @genus }.not_to raise_error
                end

                it 'to allow species in family when no taxonomy present' do
                    expect { @family.children << @species }.not_to raise_error
                end
            end

            context 'with Taxonomy object' do
              before(:each) do
                  @family = FactoryGirl.build(:taxonomite_family)
                  @genus = FactoryGirl.build(:taxonomite_genus)
                  @species = FactoryGirl.build(:taxonomite_species)
              end

              it 'to allow species in genus when no taxonomy present' do
                  expect { @genus.children << @species }.not_to raise_error
              end

              it 'to allow genus in family when no taxonomy present' do
                  expect { @family.children << @genus }.not_to raise_error
              end

              it 'to allow genus in species when no taxonomy present' do
                  expect { @species.children << @genus }.to raise_error
              end

              it 'to allow species in family when no taxonomy present' do
                  expect { @family.children << @species }.to raise_error
              end
            end
      end
    end
end
