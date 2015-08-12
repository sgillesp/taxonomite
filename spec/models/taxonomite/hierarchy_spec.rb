require 'spec_helper'
require 'models/taxonomite/zoology'

module Taxonomite
    RSpec.describe Tree, type: :model do

      context 'sample hierarchy enforcement' do
          before(:each) do
              @family = FactoryGirl.build(:taxonomite_family)
              @genus = FactoryGirl.build(:taxonomite_genus)
              @species = FactoryGirl.build(:taxonomite_species)
          end

          it 'to allow species in genus' do
              expect { @genus.children << @species }.not_to raise_error
          end

          it 'to allow genus in family' do
              expect { @family.children << @genus }.not_to raise_error
          end

          it 'not to allow genus in species' do
              expect { @species.children << @genus }.to raise_error
          end

          it 'not to allow species in family' do
              expect { @family.children << @species }.to raise_error
          end

      end

    end

end
